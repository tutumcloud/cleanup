#!/bin/bash

echo "=> Building the binary"
docker run \
  -v $(pwd):/src \
  -v /var/run/docker.sock:/var/run/docker.sock \
  centurylink/golang-builder \
  sut
