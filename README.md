tutum/image-cleanup
=========================

```
    docker run -d \
      -v /var/run:/var/run:rw \
      -v /usr/lib/tutum/docker:/usr/bin/docker:r \
      -e CLEAN_PERIOD=1800 \
      -e DELAY_TIME=1800 \
      -e KEEP_IMAGES="ubuntu:trusty, ubuntu:latest" \
      tutum/image-cleanup
```

**Arguments**

```
    CLEAN_PERIOD    how many seconds to run the clean script, 1800 by default.
    DELAY_TIME      how many seconds delay to remove docker images, 1800 by default.
    KEEP_IMAGES     A list of Images that will not be cleaned by this container, separated by ","
```
