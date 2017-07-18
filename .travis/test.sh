#!/bin/bash

# Catch errors
set -e
set -o pipefail

# Switch to root
cd "${0%/*}/../"

# Check if we're running in Travis
if [ "$TRAVIS" = "true" ]; then
    # Check if this is a pull request
    if [ "$TRAVIS_PULL_REQUEST" = "true" ]; then
        echo "NOTICE: Pull request detected, testing all images.."
    fi
fi

# Environment variables
TEST_SUCCESS=1

# Test the images
echo ""
echo "Testing images.."

echo ""
echo "  * Ubuntu 14.04"
if [ "$UPDATE_UBUNTU_14_04" == "1" ]; then
    echo -n "    > Testing.. "
    if docker run --name test -it --rm didstopia/base:ubuntu-14.04 bash -c "echo \"This is a simple test.\" | grep \"This is a simple test.\"" | grep "This is a simple test." > /dev/null
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
echo "  * Alpine 3.5"
if [ "$UPDATE_ALPINE_3_5" == "1" ]; then
    echo -n "    > Testing.. "
    if docker run --name test -it --rm didstopia/base:alpine-3.5 /bin/ash -c "echo \"This is a simple test.\" | grep \"This is a simple test.\"" | grep "This is a simple test." > /dev/null
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

echo ""
echo "Tests completed successfully."
echo ""
