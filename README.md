tutum/cleanup
=============

[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)

System container used by [Tutum](http://www.tutum.co/) to remove unused images and volumes. System containers are launched, configured and managed automatically by Tutum.

## Usage

Docker < 1.9

    docker run -d \
      --privileged \
      -v /var/run/docker.sock:/var/run/docker.sock:rw \
      -v /var/lib/docker:/var/lib/docker:rw \
      [-e IMAGE_CLEAN_INTERVAL=1] \
      [-e IMAGE_CLEAN_DELAYED=1800] \
      [-e VOLUME_CLEAN_INTERVAL=1800] \
      [-e IMAGE_LOCKED="ubuntu:trusty, tutum/curl:trusty"] \
      tutum/cleanup

Docker >= 1.9

    docker run -d \
      -v /var/run/docker.sock:/var/run/docker.sock:rw \
      [-e IMAGE_CLEAN_INTERVAL=1] \
      [-e IMAGE_CLEAN_DELAYED=1800] \
      [-e IMAGE_LOCKED="ubuntu:trusty, tutum/curl:trusty"] \
      tutum/cleanup



## Environment variables

Key | Description
----|------------
IMAGE_CLEAN_INTERVAL | (optional) How long to wait between cleanup runs (in seconds), 1 by default.
IMAGE_CLEAN_DELAYED | (optional) How long to wait to consider an image unused (in seconds), 1800 by default.
VOLUME_CLEAN_INTERVAL | (optional) How long to wait to consider a volume unused (in seconds), 1800 by default.
IMAGE_LOCKED | (optional) A list of images that will not be cleaned by this container, separated by `,`


## Notice:

From docker 1.9 onwards, volumes are a top level entity and can be removed using `docker volume rm <name>`. This image will not cleanup volumes when connected to a docker engine 1.9+ to avoid potential data loss.
