#!/usr/bin/env bash

echo "docker-credential-desktop:"
which docker-credential-desktop

# Catch errors
set -e
set -o pipefail

# Switch to build directory (if available)
if [[ ! -z "${GITHUB_WORKSPACE}" ]]; then
    cd "${GITHUB_WORKSPACE}"
# Otherwise switch to root
else
    cd "${0%/*}/../"
fi

## TODO: Why would be always build all images on PRs and non-master branches?
# Check if this is a pull request
# if [[ ! -z ${GITHUB_PULL_REQUEST+x} && "${GITHUB_PULL_REQUEST}" != "false" ]]; then
#     echo ""
#     echo "NOTICE: Pull request detected, building all images.."
#     UPDATE_UBUNTU_16_04=1
#     UPDATE_UBUNTU_18_04=1
#     UPDATE_UBUNTU_20_04=1
#     UPDATE_ALPINE_3_5=1
#     UPDATE_ALPINE_3_10=1
#     UPDATE_ALPINE_3_12=1
#     UPDATE_ALPINE_3_14=1
#     UPDATE_ALPINE_EDGE=1
# elif [[ ! -z ${GITHUB_BRANCH+x} && "${GITHUB_BRANCH}" != "master" ]]; then
#     echo ""
#     echo "NOTICE: Branch is not 'master', building all images.."
#     UPDATE_UBUNTU_16_04=1
#     UPDATE_UBUNTU_18_04=1
#     UPDATE_UBUNTU_20_04=1
#     UPDATE_ALPINE_3_5=1
#     UPDATE_ALPINE_3_10=1
#     UPDATE_ALPINE_3_12=1
#     UPDATE_ALPINE_3_14=1
#     UPDATE_ALPINE_EDGE=1
# fi

# Build the images
echo ""
echo "Building images.."

## TODO: Figure out how to properly redirect docker-make's output to /dev/null

echo ""
echo "  * Ubuntu 16.04"
if [ "$UPDATE_UBUNTU_16_04" == "1" ]; then
    echo ""
    eval $(./docker-make.sh --no-push --detailed --file .docker-make.ubuntu-16-04.yml) >/dev/null 2>&1
else
    echo -n "    > No build necessary, skipping.."
fi
echo ""

echo ""
echo "  * Ubuntu 18.04"
if [ "$UPDATE_UBUNTU_18_04" == "1" ]; then
    echo ""
    eval $(./docker-make.sh --no-push --detailed --file .docker-make.ubuntu-18-04.yml) >/dev/null 2>&1
else
    echo -n "    > No build necessary, skipping.."
fi
echo ""

echo ""
echo "  * Ubuntu 20.04"
if [ "$UPDATE_UBUNTU_18_04" == "1" ]; then
    echo ""
    eval $(./docker-make.sh --no-push --detailed --file .docker-make.ubuntu-20-04.yml) >/dev/null 2>&1
else
    echo -n "    > No build necessary, skipping.."
fi
echo ""

echo ""
echo "  * Alpine 3.5"
if [ "$UPDATE_ALPINE_3_5" == "1" ]; then
    echo ""
    eval $(./docker-make.sh --no-push --detailed --file .docker-make.alpine-3-5.yml) >/dev/null 2>&1
else
    echo -n "    > No build necessary, skipping.."
fi
echo ""

echo ""
echo "  * Alpine 3.10"
if [ "$UPDATE_ALPINE_3_10" == "1" ]; then
    echo ""
    eval $(./docker-make.sh --no-push --detailed --file .docker-make.alpine-3-10.yml) >/dev/null 2>&1
else
    echo -n "    > No build necessary, skipping.."
fi
echo ""

echo ""
echo "  * Alpine 3.12"
if [ "$UPDATE_ALPINE_3_12" == "1" ]; then
    echo ""
    eval $(./docker-make.sh --no-push --detailed --file .docker-make.alpine-3-12.yml) >/dev/null 2>&1
else
    echo -n "    > No build necessary, skipping.."
fi
echo ""

echo ""
echo "  * Alpine 3.14"
if [ "$UPDATE_ALPINE_3_14" == "1" ]; then
    echo ""
    eval $(./docker-make.sh --no-push --detailed --file .docker-make.alpine-3-14.yml) >/dev/null 2>&1
else
    echo -n "    > No build necessary, skipping.."
fi
echo ""

echo ""
echo "  * Alpine Edge"
if [ "$UPDATE_ALPINE_EDGE" == "1" ]; then
    echo ""
    eval $(./docker-make.sh --no-push --detailed --file .docker-make.alpine-edge.yml) >/dev/null 2>&1
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
