#!/bin/bash

# Handle errors
set -e
set -o pipefail

# Switch to root
cd "${0%/*}"/../

UPDATE_UBUNTU_16_04=0
UPDATE_UBUNTU_14_04=0
UPDATE_ALPINE_3_5=0

echo ""
echo "Removing dangling images.."
docker rmi $(docker images -f dangling=true -q) 2>/dev/null || true 
echo ""

# Check each image for updates, then locally remove them to force an update if necessary
docker pull didstopia/base:ubuntu-16.04
if docker run --name test -it --rm didstopia/base:ubuntu-16.04 bash -c "apt-get update > /dev/null && apt-get --just-print upgrade | grep \"Inst \"" | grep "Inst "
then
	echo ""
    echo "Updates available for Ubuntu 16.04, marking as dirty.."
    UPDATE_UBUNTU_16_04=1
    #docker rmi -f didstopia/base:ubuntu-16.04
    echo ""
else
	echo ""
	echo "No updates available for Ubuntu 16.04, skipping.."
	echo ""
fi

docker pull didstopia/base:ubuntu-14.04
if docker run --name test -it --rm didstopia/base:ubuntu-14.04 bash -c "apt-get update > /dev/null && apt-get --just-print upgrade | grep \"Inst \"" | grep "Inst "
then
	echo ""
    echo "Updates available for Ubuntu 14.04, marking as dirty.."
    UPDATE_UBUNTU_14_04=1
    #docker rmi -f didstopia/base:ubuntu-14.04
    echo ""
else
	echo ""
	echo "No updates available for Ubuntu 14.04, skipping.."
	echo ""
fi

# TODO: Implement
#docker pull didstopia/base:alpine-3.5

# Build the images
#./docker-make.sh --no-push

# TODO: Push changes
