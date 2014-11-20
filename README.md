tutum/image-cleanup
=========================

```
    docker run -d \
      -v /var/run:/var/run:rw \
      -v /usr/lib/tutum/docker:/usr/bin/docker:r \
      -e CLEAN_PERIOD=600 \
      -e DELAY_TIME=600 \
      tutum/utils:image-cleanup
```

**Arguments**

```
    CLEAN_PERIOD    how many seconds to run the clean script, 600 by default.
    DELAY_TIME      how many seconds delay to remove docker images, 600 by default.
```
