#!/bin/bash
docker login -u $DOCKER_USER -p $DOCKER_PASS -e a@a.com
docker build -t sut .
docker tag sut $1
docker push $1
