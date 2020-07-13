#!/usr/bin/env bash

# Catch errors
set -e
set -o pipefail

set -x

# Switch to build directory (if available)
if [[ ! -z "${GITHUB_WORKSPACE}" ]]; then
    cd "${GITHUB_WORKSPACE}"
# Otherwise switch to root
else
    cd "${0%/*}/../"
fi

echo ""

# Check if this is not pull request and is on the master branch
if [[ ! -z ${GITHUB_PULL_REQUEST+x} && "${GITHUB_PULL_REQUEST}" = "false" && ! -z ${GITHUB_BRANCH+x} && "${GITHUB_BRANCH}" = "master" ]]; then
    # Setup the repo for deployment
    if [[ ! -z "${GITHUB_REPO}" ]]; then
        echo "Setting up git.."
        git remote set-url origin $GITHUB_REPO > /dev/null
        git config --global user.email "no-reply@github.com" > /dev/null
        git config --global user.name "GitHub Actions" > /dev/null
        echo ""
    fi
    
    # Login to Docker Hub
    if [[ ! -z "${DOCKER_USERNAME}" && ! -z "${DOCKER_PASSWORD}" ]]; then
        echo "Logging in to Docker Hub.."
        docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD" > /dev/null
        echo ""
    fi
fi

## Remove dangling images, just in case
echo -n "Removing dangling images.."
docker rmi $(docker images -f dangling=true -q > /dev/null) 2>/dev/null || true
echo -n " done!"
echo ""

## Pull latest versions of all images
echo ""
echo "Pulling latest images.."

# Ubuntu 16.04
echo ""
echo "  * Ubuntu 16.04"
echo -n "    > ubuntu-16.04.. "
docker pull didstopia/base:ubuntu-16.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-10-ubuntu-16.04.. "
docker pull didstopia/base:nodejs-10-ubuntu-16.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-12-ubuntu-16.04.. "
docker pull didstopia/base:nodejs-12-ubuntu-16.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > steamcmd-ubuntu-16.04.. "
docker pull didstopia/base:steamcmd-ubuntu-16.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-10-steamcmd-ubuntu-16.04.. "
docker pull didstopia/base:nodejs-10-steamcmd-ubuntu-16.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-12-steamcmd-ubuntu-16.04.. "
docker pull didstopia/base:nodejs-12-steamcmd-ubuntu-16.04 > /dev/null
echo -n "done"
echo ""

# Ubuntu 18.04
echo ""
echo "  * Ubuntu 18.04"
echo -n "    > ubuntu-18.04.. "
docker pull didstopia/base:ubuntu-18.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-10-ubuntu-18.04.. "
docker pull didstopia/base:nodejs-10-ubuntu-18.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-12-ubuntu-18.04.. "
docker pull didstopia/base:nodejs-12-ubuntu-18.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > steamcmd-ubuntu-18.04.. "
docker pull didstopia/base:steamcmd-ubuntu-18.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-10-steamcmd-ubuntu-18.04.. "
docker pull didstopia/base:nodejs-10-steamcmd-ubuntu-18.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-12-steamcmd-ubuntu-18.04.. "
docker pull didstopia/base:nodejs-12-steamcmd-ubuntu-18.04 > /dev/null
echo -n "done"
echo ""

# Alpine 3.5
echo ""
echo "  * Alpine 3.5"
echo -n "    > alpine-3.5.. "
docker pull didstopia/base:alpine-3.5 > /dev/null > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-alpine-3.5.. "
docker pull didstopia/base:nodejs-alpine-3.5 > /dev/null
echo -n "done"
echo ""
echo -n "    > go-alpine-3.5.. "
docker pull didstopia/base:go-alpine-3.5 > /dev/null
echo -n "done"
echo ""

# Alpine 3.10
echo ""
echo "  * Alpine 3.10"
echo -n "    > alpine-3.10.. "
docker pull didstopia/base:alpine-3.10 > /dev/null > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-alpine-3.10.. "
docker pull didstopia/base:nodejs-alpine-3.10 > /dev/null
echo -n "done"
echo ""
echo -n "    > go-alpine-3.10.. "
docker pull didstopia/base:go-alpine-3.10 > /dev/null
echo -n "done"
echo ""

# Alpine Edge
echo ""
echo "  * Alpine Edge"
echo -n "    > alpine-edge.. "
docker pull didstopia/base:alpine-edge > /dev/null > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-alpine-edge.. "
docker pull didstopia/base:nodejs-alpine-edge > /dev/null
echo -n "done"
echo ""
echo -n "    > go-alpine-edge.. "
docker pull didstopia/base:go-alpine-edge > /dev/null
echo -n "done"
echo ""

# Utilities
echo ""
echo "  * Utilities"
echo -n "    > docker-make.. "
docker pull jizhilong/docker-make > /dev/null > /dev/null
echo -n "done"
echo ""

# Disable error handling (useful when running with "source")
set +e
set +o pipefail

echo ""
echo "Setup completed successfully."
echo ""
