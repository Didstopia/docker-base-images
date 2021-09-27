#!/usr/bin/env bash

# Handle errors
set -e
set -o pipefail

# Switch to build directory (if available)
if [[ ! -z "${GITHUB_WORKSPACE}" ]]; then
    cd "${GITHUB_WORKSPACE}"
# Otherwise switch to root
else
    cd "${0%/*}/../"
fi

# Check if this is a pull request
if [[ ! -z ${GITHUB_PULL_REQUEST+x} && "${GITHUB_PULL_REQUEST}" != "false" ]]; then
    echo ""
    echo "NOTICE: Pull request detected, skipping update check.."
    echo ""
elif [[ ! -z ${GITHUB_BRANCH+x} && "${GITHUB_BRANCH}" != "master" ]]; then
    echo ""
    echo "NOTICE: Branch is not 'master', skipping update check.."
    echo ""
else
    # Environment variables exported at the end of the script
    UPDATE_UBUNTU_16_04=0
    UPDATE_UBUNTU_18_04=0
    UPDATE_UBUNTU_20_04=0
    UPDATE_ALPINE_3_5=0
    UPDATE_ALPINE_3_10=0
    UPDATE_ALPINE_3_12=0
    UPDATE_ALPINE_3_14=0
    UPDATE_ALPINE_EDGE=0

    # Check each image for updates and set an environment
    # variable that's then used in the build script
    echo ""
    echo "Checking images for updates.."

    echo ""
    echo "  * Ubuntu 16.04"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --tty --rm --entrypoint="/bin/bash" didstopia/base:ubuntu-16.04 -c "apt-get update > /dev/null && apt-get --just-print upgrade | grep \"Inst \"" | grep "Inst " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_UBUNTU_16_04=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo "  * Ubuntu 18.04"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --tty --rm --entrypoint="/bin/bash" didstopia/base:ubuntu-18.04 -c "apt-get update > /dev/null && apt-get --just-print upgrade | grep \"Inst \"" | grep "Inst " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_UBUNTU_18_04=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo "  * Ubuntu 20.04"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --tty --rm --entrypoint="/bin/bash" didstopia/base:ubuntu-20.04 -c "apt-get update > /dev/null && apt-get --just-print upgrade | grep \"Inst \"" | grep "Inst " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_UBUNTU_20_04=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo "  * Alpine 3.5"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --tty --rm --entrypoint="/bin/bash" didstopia/base:alpine-3.5 -c "apk update > /dev/null && apk upgrade | grep \"Upgrading \"" | grep "Upgrading " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_ALPINE_3_5=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo "  * Alpine 3.10"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --tty --tty --rm --entrypoint="/bin/bash" didstopia/base:alpine-3.10 -c "apk update > /dev/null && apk upgrade | grep \"Upgrading \"" | grep "Upgrading " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_ALPINE_3_10=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo "  * Alpine 3.12"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --tty --tty --rm --entrypoint="/bin/bash" didstopia/base:alpine-3.12 -c "apk update > /dev/null && apk upgrade | grep \"Upgrading \"" | grep "Upgrading " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_ALPINE_3_12=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo "  * Alpine 3.14"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --tty --rm --entrypoint="/bin/bash" didstopia/base:alpine-3.14 -c "apk update > /dev/null && apk upgrade | grep \"Upgrading \"" | grep "Upgrading " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_ALPINE_3_14=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo "  * Alpine Edge"
    echo -n "    > Checking for updates.. "
    if docker run --name test -it --tty --rm --entrypoint="/bin/bash" didstopia/base:alpine-edge -c "apk update > /dev/null && apk upgrade | grep \"Upgrading \"" | grep "Upgrading " > /dev/null
    then
        echo -n "updates available"
        echo ""
        UPDATE_ALPINE_EDGE=1
    else
        echo -n "no updates available"
        echo ""
    fi

    echo ""
    echo -n "Exporting results as environment variables.. "
    export UPDATE_UBUNTU_16_04
    export UPDATE_UBUNTU_18_04
    export UPDATE_UBUNTU_20_04
    export UPDATE_ALPINE_3_5
    export UPDATE_ALPINE_3_10
    export UPDATE_ALPINE_3_12
    export UPDATE_ALPINE_3_14
    export UPDATE_ALPINE_EDGE
    echo -n "done"
    echo ""

    # Disable error handling (useful when running with "source")
    set +e
    set +o pipefail

    echo ""
    echo "Update check completed successfully."
    echo ""
fi
