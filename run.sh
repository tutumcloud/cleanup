#!/bin/bash

if [ ! -e "/var/run/docker.sock" ]; then
    echo "=> Cannot find docker socket(/var/run/docker.sock), please check the command!"
    exit 1
fi

if [ "${CLEAN_PERIOD}" == "**None**" ]; then
    echo "=> CLEAN_PERIOD not defined, use the default value."
    CLEAN_PERIOD=600
fi

if [ "${DELAY_TIME}" == "**None**" ]; then
    echo "=> DELAY_TIME not defined, use the default value."
    DELAY_TIME=600
fi

echo "=> Run the clean script every ${CLEAN_PERIOD} seconds and delay ${DELAY_TIME} seconds to clean."

trap '{ echo "User Interupt."; exit 1; }' INT
while [ 1 ]
do
    ALL_LAYER_NUM=$(docker images -a | tail -n +2 | wc -l)
    docker images -q --no-trunc | sort -o ImageIdList
    CONTAINER_ID_LIST=$(docker ps -aq --no-trunc)
    IFS='
    '
    rm -f ContainerImageIdList
    for CONTAINER_ID in ${CONTAINER_ID_LIST}; do
        LINE=$(docker inspect ${CONTAINER_ID} | grep "\"Image\": \"[0-9a-fA-F]\{64\}\"")
        IMAGE_ID=$(echo ${LINE} | awk -F '"' '{print $4}')
        echo "${IMAGE_ID}" >> ContainerImageIdList
    done
    sort ContainerImageIdList -o ContainerImageIdList
    comm -23 ImageIdList ContainerImageIdList > ToBeCleanedImageIdList

    echo "=> About to clean images after ${DELAY_TIME} seconds"
    sleep ${DELAY_TIME}
    CONTAINER_ID_LIST=$(docker ps -aq --no-trunc)
    rm -f ContainerImageIdList
    for CONTAINER_ID in ${CONTAINER_ID_LIST}; do
        LINE=$(docker inspect ${CONTAINER_ID} | grep "\"Image\": \"[0-9a-fA-F]\{64\}\"")
        IMAGE_ID=$(echo ${LINE} | awk -F '"' '{print $4}')
        echo "${IMAGE_ID}" >> ContainerImageIdList
    done
    sort ContainerImageIdList -o ContainerImageIdList
    comm -23 ToBeCleanedImageIdList ContainerImageIdList > ToBeCleaned
    
    if [ -s ToBeCleaned ]; then
        echo "=> Start to clean $(cat ToBeCleaned | wc -l) images"
        docker rmi $(cat ToBeCleaned) 2>/dev/null
        (( DIFF_LAYER=${ALL_LAYER_NUM}- $(docker images -a | tail -n +2 | wc -l) ))
        (( DIFF_IMG=$(cat ImageIdList | wc -l) - $(docker images | tail -n +2 | wc -l) ))
        if [ ! ${DIFF_LAYER} -gt 0 ]; then
                DIFF_LAYER=0
        fi
        if [ ! ${DIFF_IMG} -gt 0 ]; then
                DIFF_IMG=0
        fi
        echo "=> Done! ${DIFF_IMG} images and ${DIFF_LAYER} layers have been cleaned."
    else
        echo "No images need to be cleaned"
    fi
    
    rm -f ToBeCleanedImageIdList ContainerImageIdList ToBeCleaned ImageIdList
    echo "=> Next clean will be started in ${CLEAN_PERIOD} seconds"
    sleep ${CLEAN_PERIOD}
done
