#!/bin/bash

# Catch errors
set -e
set -o pipefail

# Switch to root
cd "${0%/*}"

docker run --rm -w /usr/src/app -v ~/.docker:/root/.docker -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)":/usr/src/app jizhilong/docker-make docker-make -rm "$@"
