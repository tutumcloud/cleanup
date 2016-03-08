#!/bin/sh

if [ ! -e "/var/run/docker.sock" ]; then
    echo "=> Cannot find docker socket(/var/run/docker.sock), please check the command!"
    exit 1
fi

if [ "${IMAGE_LOCKED}" == "**None**" ]; then
    exec /cleanup \
        -imageCleanInterval ${IMAGE_CLEAN_INTERVAL} \
        -imageCleanDelayed ${IMAGE_CLEAN_DELAYED}
else
    exec /cleanup \
        -imageCleanInterval ${IMAGE_CLEAN_INTERVAL} \
        -imageCleanDelayed ${IMAGE_CLEAN_DELAYED} \
        -imageLocked "${IMAGE_LOCKED}" 
fi
