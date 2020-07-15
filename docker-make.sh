#!/usr/bin/env bash

# Catch errors
set -e
set -o pipefail

# Switch to build directory (if available)
if [[ ! -z "${GITHUB_WORKSPACE}" ]]; then
    cd "${GITHUB_WORKSPACE}"
# Otherwise switch to root
else
    cd "${0%/*}"
fi

docker pull didstopia/docker-make:latest
docker run --rm -w /usr/src/app -v ~/.docker:/root/.docker -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)":/usr/src/app didstopia/docker-make:latest docker-make -rm "$@"

# Disable error handling (useful when running with "source")
set +e
set +o pipefail
