tutum/image-cleanup
=========================

```
    docker run -d \
      -v /var/run:/var/run:rw \
      -v /usr/lib/tutum/docker:/usr/bin/docker:r \
      -e CLEAN_PERIOD=3000 \
      -e DELAY_TIME=3000 \
      -e KEEP_IMAGES="ubuntu:trusty, ubuntu"
      tutum/utils:image-cleanup
```

**Arguments**

```
    CLEAN_PERIOD    how many seconds to run the clean script, 600 by default.
    DELAY_TIME      how many seconds delay to remove docker images, 600 by default.
    KEEP_IMAGES     A list of Images that will not be cleaned by this container, separated by ","
```
