package main //import "github.com/tutumcloud/cleanup"

import (
	"flag"
	"io/ioutil"
	"log"
	"os"
	"path"
	"regexp"
	"runtime"
	"strings"
	"sync"
	"time"

	docker "github.com/fsouza/go-dockerclient"
)

var (
	pDockerHost          = flag.String("dockerHost", "unix:///var/run/docker.sock", "docker host")
	pImageCleanInterval  = flag.Int("imageCleanInterval", 1, "interval to run image cleanup")
	pImageCleanDelayed   = flag.Int("imageCleanDelayed", 1800, "delayed time to clean the images")
	pVolumeCleanInterval = flag.Int("volumeCleanInterval", 1800, "interval to run volume cleanup")
	pImageLocked         = flag.String("imageLocked", "", "images to avoid being cleaned")
	pDockerRootDir       = flag.String("dockerRootDir", "/var/lib/docker", "root path of docker lib")
	wg                   sync.WaitGroup
)

func init() {
	runtime.GOMAXPROCS(4)
}

func main() {
	flag.Parse()

	client, err := getDockerClient(*pDockerHost)
	if err != nil {
		log.Fatalf("Docker %s:%s", err, *pDockerHost)
	}

	wg.Add(1)
	go cleanImages(client)
	go cleanVolumes(client)
	wg.Wait()
}

func getDockerClient(host string) (*docker.Client, error) {
	client, err := docker.NewClient(host)
	if err != nil {
		return nil, err
	}
	return client, nil
}

func cleanImages(client *docker.Client) {
	defer wg.Done()

	log.Printf("Img Cleanup: the following images will be locked: %s", *pImageLocked)
	log.Println("Img Cleanup: starting image cleanup ...")
	for {
		// imageIdMap[imageID] = isRemovable
		imageIdMap := make(map[string]bool)

		// Get the image ID list before the cleanup
		images, err := client.ListImages(docker.ListImagesOptions{All: false})
		if err != nil {
			log.Println("Img Cleanup: cannot get images list", err)
			time.Sleep(time.Duration(*pImageCleanInterval+*pImageCleanDelayed) * time.Second)
			continue
		}

		for _, image := range images {
			imageIdMap[image.ID] = true
		}

		// Get the image IDs used by all the containers
		containers, err := client.ListContainers(docker.ListContainersOptions{All: true})
		if err != nil {
			log.Println("Img Cleanup: cannot get container list", err)
			time.Sleep(time.Duration(*pImageCleanInterval+*pImageCleanDelayed) * time.Second)
			continue
		} else {
			inspect_error := false
			for _, container := range containers {
				containerInspect, err := client.InspectContainer(container.ID)
				if err != nil {
					inspect_error = true
					log.Println("Img Cleanup: cannot get container inspect", err)
					break
				}
				delete(imageIdMap, containerInspect.Image)
			}
			if inspect_error {
				time.Sleep(time.Duration(*pImageCleanInterval+*pImageCleanDelayed) * time.Second)
				continue
			}
		}

		// Get all the locked image ID
		if *pImageLocked != "" {
			lockedImages := strings.Split(*pImageLocked, ",")
			for _, lockedImage := range lockedImages {
				imageInspect, err := client.InspectImage(strings.Trim(lockedImage, " "))
				if err == nil {
					delete(imageIdMap, imageInspect.ID)
				}

			}
		}

		// Sleep for the delay time
		log.Printf("Img Cleanup: wait %d seconds for the cleaning", *pImageCleanDelayed)
		time.Sleep(time.Duration(*pImageCleanDelayed) * time.Second)

		// Get the image IDs used by all the containers again after the delay time
		containersDelayed, err := client.ListContainers(docker.ListContainersOptions{All: true})
		if err != nil {
			log.Println("Img Cleanup: cannot get container list", err)
			time.Sleep(time.Duration(*pImageCleanInterval) * time.Second)
			continue
		} else {
			inspect_error := false
			for _, container := range containersDelayed {
				containerInspect, err := client.InspectContainer(container.ID)
				if err != nil {
					inspect_error = true
					log.Println("Img Cleanup: cannot get container inspect", err)
					break
				}
				delete(imageIdMap, containerInspect.Image)
			}
			if inspect_error {
				time.Sleep(time.Duration(*pImageCleanInterval) * time.Second)
				continue
			}
		}

		// Remove the unused images
		counter := 0
		for id, removable := range imageIdMap {
			if removable {
				log.Printf("Img Cleanup: removing image %s", id)
				err := client.RemoveImage(id)
				if err != nil {
					log.Printf("Img Cleanup: %s", err)
				}
				counter += 1
			}
		}
		log.Printf("Img Cleanup: %d images have been removed", counter)

		// Sleep again
		log.Printf("Img Cleanup: next cleanup will be start in %d seconds", *pImageCleanInterval)
		time.Sleep(time.Duration(*pImageCleanInterval) * time.Second)
	}
}

func cleanVolumes(client *docker.Client) {
	defer wg.Done()

	log.Println("Vol Cleanup: starting volume cleanup ...")
	re := regexp.MustCompile(".*/([0-9a-fA-F]{64}).*")

	// volumesMap[id] = weight
	// weight = 0 ~ 99, increace on every iteration if it is not used
	// weight = 100, remove it
	volumesMap := make(map[string]int)
	volumeDir := path.Join(*pDockerRootDir, "volumes")
	for {
		containers, err := client.ListContainers(docker.ListContainersOptions{All: true})
		if err != nil {
			log.Println("Vol Cleanup: cannot get container list", err)
			time.Sleep(time.Duration(*pVolumeCleanInterval) * time.Second)
			continue
		} else {
			inspect_error := false
			for _, container := range containers {
				containerInspect, err := client.InspectContainer(container.ID)
				if err != nil {
					inspect_error = true
					log.Println("Vol Cleanup: cannot get container inspect", err)
					break
				}
				for _, volPath := range containerInspect.Volumes {
					terms := re.FindStringSubmatch(volPath)
					if len(terms) == 2 {
						id := terms[1]
						volumesMap[id] = 0
					}
				}
			}
			if inspect_error {
				time.Sleep(time.Duration(*pVolumeCleanInterval) * time.Second)
				continue
			}
		}

		files, err := ioutil.ReadDir(volumeDir)
		if err != nil {
			log.Printf("Vol Cleanup: %s", err)
		} else {
			for _, f := range files {
				id := f.Name()
				weight := volumesMap[id]
				volumesMap[id] = weight + 1
			}
		}

		// Remove the unused volumes
		counter := 0
		for id, weight := range volumesMap {
			if weight >= 100 {
				volPath := path.Join(volumeDir, id)
				log.Printf("Vol Cleanup: removing volume %s", volPath)
				err := os.RemoveAll(volPath)
				if err != nil {
					log.Printf("Vol Cleanup: %s", err)
				} else {
					delete(volumesMap, id)
					counter += 1
				}
			}
		}
		log.Printf("Vol Cleanup: %d volumes have been removed", counter)

		// Sleep
		log.Printf("Vol Cleanup: next cleanup will be start in %d seconds", *pVolumeCleanInterval)
		time.Sleep(time.Duration(*pVolumeCleanInterval) * time.Second)
	}
}
