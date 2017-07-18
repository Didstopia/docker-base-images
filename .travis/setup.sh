#!/bin/bash

# Catch errors
set -e
set -o pipefail

# Switch to Travis build directory (if available)
if [[ ! -z "${TRAVIS_BUILD_DIR}" ]]; then
    cd "${TRAVIS_BUILD_DIR}"
# Otherwise switch to root
else
    cd "${0%/*}/../"
fi

echo ""

# Check if this is not pull request and is on the master branch
if [[ ! -z ${TRAVIS_PULL_REQUEST+x} && "${TRAVIS_PULL_REQUEST}" = "false" && ! -z ${TRAVIS_BRANCH+x} && "${TRAVIS_BRANCH}" = "master" ]]; then
    # Setup the repo for deployment
    if [[ ! -z "${GITHUB_REPO}" ]]; then
        echo "Setting up git.."
        git remote set-url origin $GITHUB_REPO > /dev/null
        git config --global user.email "builds@travis-ci.com" > /dev/null
        git config --global user.name "Travis CI" > /dev/null
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

# Ubuntu 14.04
echo ""
echo "  * Ubuntu 14.04"
echo -n "    > ubuntu-14.04.. "
docker pull didstopia/base:ubuntu-14.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-ubuntu-14.04.. "
docker pull didstopia/base:nodejs-ubuntu-14.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > steamcmd-ubuntu-14.04.. "
docker pull didstopia/base:steamcmd-ubuntu-14.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-steamcmd-ubuntu-14.04.. "
docker pull didstopia/base:nodejs-steamcmd-ubuntu-14.04 > /dev/null
echo -n "done"
echo ""

# Ubuntu 16.04
echo ""
echo "  * Ubuntu 16.04"
echo -n "    > ubuntu-16.04.. "
docker pull didstopia/base:ubuntu-16.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-ubuntu-16.04.. "
docker pull didstopia/base:nodejs-ubuntu-16.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > steamcmd-ubuntu-16.04.. "
docker pull didstopia/base:steamcmd-ubuntu-16.04 > /dev/null
echo -n "done"
echo ""
echo -n "    > nodejs-steamcmd-ubuntu-16.04.. "
docker pull didstopia/base:nodejs-steamcmd-ubuntu-16.04 > /dev/null
echo -n "done"
echo ""

# Alpine
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
