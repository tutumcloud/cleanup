#!/bin/bash

if [ ! -e "/var/run/docker.sock" ]; then
    echo "=> Cannot find docker socket(/var/run/docker.sock), please check the command!"
    exit 1
fi

if [ "${IMAGE_LOCKED}" == "**None**" ]; then
    exec /image-cleanup -imageCleanInterval ${IMAGE_CLEAN_INTERVAL} \
        -imageCleanDelayed ${IMAGE_CLEAN_DELAYED} \
        -volumeCleanInterval ${VOLUME_CLEAN_INTERVAL} \
        -dockerRootDir ${DOCKER_ROOT_DIR}
else
    exec /image-cleanup -imageCleanInterval ${IMAGE_CLEAN_INTERVAL} \
        -imageCleanDelayed ${IMAGE_CLEAN_DELAYED} \
        -volumeCleanInterval ${VOLUME_CLEAN_INTERVAL} \
        -imageLocked "${IMAGE_LOCKED}" \
        -dockerRootDir ${DOCKER_ROOT_DIR}
fi
