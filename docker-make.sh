#!/bin/bash

docker run --rm=true -w /usr/src/app -v ~/.docker:/root/.docker -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)":/usr/src/app jizhilong/docker-make docker-make "$@"
