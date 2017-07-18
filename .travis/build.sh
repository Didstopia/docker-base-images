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

# Check if this is a pull request
if [ "$TRAVIS_PULL_REQUEST" == "true" ]; then
    echo ""
    echo "NOTICE: Pull request detected, building all images.."
    ## TODO: Enable the rest of these
    UPDATE_UBUNTU_16_04=1
    UPDATE_UBUNTU_14_04=0
    UPDATE_ALPINE_3_5=0
fi

# Build the images
echo ""
echo "Building images.."

## TODO: Figure out how to properly redirect docker-make's output to /dev/null

echo ""
echo "  * Ubuntu 14.04"
if [ "$UPDATE_UBUNTU_14_04" == "1" ]; then
    #echo -n "    > Building.. "
    echo ""
    eval $(./docker-make.sh --no-push --detailed -f .docker-make.ubuntu-14-04.yml) >/dev/null 2>&1
    #echo -n "done!"
else
    echo -n "    > No build necessary, skipping.."
fi
echo ""

echo ""
echo "  * Ubuntu 16.04"
if [ "$UPDATE_UBUNTU_16_04" == "1" ]; then
    #echo -n "    > Building.. "
    echo ""
    eval $(./docker-make.sh --no-push --detailed -f .docker-make.ubuntu-16-04.yml) >/dev/null 2>&1
    #echo -n "done!"
else
    echo -n "    > No build necessary, skipping.."
fi
echo ""

echo ""
echo "  * Alpine 3.5"
if [ "$UPDATE_ALPINE_3_5" == "1" ]; then
    #echo -n "    > Building.. "
    echo ""
    eval $(./docker-make.sh --no-push --detailed -f .docker-make.alpine-3-5.yml) >/dev/null 2>&1
    #echo -n "done!"
else
    echo -n "    > No build necessary, skipping.."
fi
echo ""

# Disable error handling (useful when running with "source")
set +e
set +o pipefail

echo ""
echo "Build completed successfully."
echo ""
