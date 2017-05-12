#!/bin/bash

docker run --rm -w /usr/src/app -v ~/.docker:/root/.docker -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)":/usr/src/app jizhilong/docker-make docker-make "$@"

## TODO: Remove once Docker Make is not generating leftover containers
docker rm $(docker ps -a -q) >/dev/null 2>&1
