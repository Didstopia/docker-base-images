#!/usr/bin/env bash

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

# Check if this is a pull request
if [[ ! -z ${GITHUB_PULL_REQUEST+x} && "${GITHUB_PULL_REQUEST}" != "false" ]]; then
    echo ""
    echo "NOTICE: Pull request detected, testing all images.."
    UPDATE_UBUNTU_16_04=1
    UPDATE_UBUNTU_18_04=1
    UPDATE_ALPINE_3_5=1
    UPDATE_ALPINE_3_10=1
    UPDATE_ALPINE_EDGE=1
elif [[ ! -z ${GITHUB_BRANCH+x} && "${GITHUB_BRANCH}" != "master" ]]; then
    echo ""
    echo "NOTICE: Branch is not 'master', testing all images.."
    UPDATE_UBUNTU_16_04=1
    UPDATE_UBUNTU_18_04=1
    UPDATE_ALPINE_3_5=1
    UPDATE_ALPINE_3_10=1
    UPDATE_ALPINE_EDGE=1
fi

# Environment variables
TEST_SUCCESS=1

# Test the images
echo ""
echo "Testing images.."

echo ""
echo "  * Ubuntu 16.04"
if [ "$UPDATE_UBUNTU_16_04" == "1" ]; then
    echo -n "    > Testing.. "
    if docker run --name test -it --rm didstopia/base:ubuntu-16.04 bash -c "echo \"This is a simple test.\" | grep \"This is a simple test.\"" | grep "This is a simple test." > /dev/null
    then
        echo -n "passed"
    else
        echo -n "failed"
        TEST_SUCCESS=0
    fi
else
    echo -n "    > No testing necessary, skipping.."
fi
echo ""

echo ""
echo "  * Ubuntu 18.04"
if [ "$UPDATE_UBUNTU_18_04" == "1" ]; then
    echo -n "    > Testing.. "
    if docker run --name test -it --rm didstopia/base:ubuntu-18.04 bash -c "echo \"This is a simple test.\" | grep \"This is a simple test.\"" | grep "This is a simple test." > /dev/null
    then
        echo -n "passed"
    else
        echo -n "failed"
        TEST_SUCCESS=0

    fi
else
    echo -n "    > No testing necessary, skipping.."
fi
echo ""

echo ""
echo "  * Alpine 3.5"
if [ "$UPDATE_ALPINE_3_5" == "1" ]; then
    echo -n "    > Testing.. "
    if docker run --name test -it --rm didstopia/base:alpine-3.5 /bin/bash -c "echo \"This is a simple test.\" | grep \"This is a simple test.\"" | grep "This is a simple test." > /dev/null
    then
        echo -n "passed"
    else
        echo -n "failed"
        TEST_SUCCESS=0
    fi
else
    echo -n "    > No testing necessary, skipping.."
fi
echo ""

echo ""
echo "  * Alpine 3.10"
if [ "$UPDATE_ALPINE_3_10" == "1" ]; then
    echo -n "    > Testing.. "
    if docker run --name test -it --rm didstopia/base:alpine-3.10 /bin/bash -c "echo \"This is a simple test.\" | grep \"This is a simple test.\"" | grep "This is a simple test." > /dev/null
    then
        echo -n "passed"
    else
        echo -n "failed"
        TEST_SUCCESS=0
    fi
else
    echo -n "    > No testing necessary, skipping.."
fi
echo ""

echo ""
echo "  * Alpine edge"
if [ "$UPDATE_ALPINE_EDGE" == "1" ]; then
    echo -n "    > Testing.. "
    if docker run --name test -it --rm didstopia/base:alpine-edge /bin/bash -c "echo \"This is a simple test.\" | grep \"This is a simple test.\"" | grep "This is a simple test." > /dev/null
    then
        echo -n "passed"
    else
        echo -n "failed"
        TEST_SUCCESS=0
    fi
else
    echo -n "    > No testing necessary, skipping.."
fi
echo ""

# Check if tests failed
if [ "$TEST_SUCCESS" == "0" ]; then
    echo ""
    echo "ERROR: One or more tests have failed!"
    echo ""
    exit 1
fi

# Disable error handling (useful when running with "source")
set +e
set +o pipefail

echo ""
echo "Tests completed successfully."
echo ""
