tutum/image-cleanup
=========================

```
    docker run -d \
      --privileged \
      -v /var/run:/var/run:rw \
      -v /usr/lib/tutum/docker:/usr/bin/docker:r \
      -v /var/lib/docker:/var/lib/docker:rw \
      -e IMAGE_CLEAN_INTERVAL=1 \
      -e IMAGE_CLEAN_DELAYED=1800 \
      -e VOLUME_CLEAN_INTERVAL=1800 \
      -e IMAGE_LOCKED="ubuntu:trusty, tutum/curl:trusty" \
      tutum/image-cleanup
```

**Arguments**

```
    IMAGE_CLEAN_INTERVAL	    how many seconds to clean the images, 1 by default.
    IMAGE_CLEAN_DELAYED      how many seconds delay to clean docker images, 1800 by default.
    VOLUME_CLEAN_INTERVAL    how many seconde to clean docker volumes, 1800 by default.
    IMAGE_LOCKED             A list of Images that will not be cleaned by this container, separated by ","
```
