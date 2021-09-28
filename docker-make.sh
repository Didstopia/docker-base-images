#!/usr/bin/env bash

# Remove temporary custom Docker configuration file when shell script exits
trap "rm -f $dockercfg" EXIT

# Catch errors
set -e
set -o pipefail

## FIXME: Remove after done testing
set -x

# Switch to build directory (if available)
if [[ ! -z "${GITHUB_WORKSPACE}" ]]; then
    cd "${GITHUB_WORKSPACE}"
# Otherwise switch to root
else
    cd "${0%/*}"
fi

DOCKER_CONFIG_FILE="${HOME}/.docker/config.json"

# Login to Docker Hub
if [[ ! -z "${DOCKER_USERNAME}" && ! -z "${DOCKER_PASSWORD}" ]]; then
    echo "Logging in to Docker Hub.."
    docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD" > /dev/null
    echo ""
fi

# Ensure that the Docker configuration file exists
if [[ ! -f "${DOCKER_CONFIG_FILE}" ]]; then
    echo "ERROR: Docker configuration file missing from ${DOCKER_CONFIG_FILE}"
    exit 1
else
    echo "Docker configuration file exists at ${DOCKER_CONFIG_FILE}, continuing"
fi

# Create a temporary custom Docker configuration file with the credentials embedded,
# otherwise docker-make will refuse to work correctly, as it needs permissions to push
DOCKER_CUSTOM_CONFIG="${DOCKER_CONFIG_FILE}"
if grep -q credsStore "${DOCKER_CONFIG_FILE}"; then
    echo "Customizing Docker credentials for docker-make"
    DOCKER_CUSTOM_CONFIG=$(mktemp /tmp/dockercfg.XXXXX)
    storetype=$(jq -r .credsStore < ${DOCKER_CONFIG_FILE})
    (
        echo '{'
        echo '    "auths": {'
        for registry in $(docker-credential-$storetype list | jq -r 'to_entries[] | .key'); do
            if [ ! -z $FIRST ]; then
                echo '        },'
            fi
            FIRST=true
            credential=$(echo $registry | docker-credential-$storetype get | jq -jr '"\(.Username):\(.Secret)"' | base64)
            echo '        "'$registry'": {'
            echo '            "auth": "'$credential'"'
        done
        echo '        }'
        echo '    }'
        echo '}'
    ) > $DOCKER_CUSTOM_CONFIG
else
    echo "Skipping Docker credentials customization for docker-make"
fi

# if [ ! -z "$DOCKER_CUSTOM_CONFIG" ]; then
#     echo "Using default Docker configuration file"
#     DOCKER_CUSTOM_CONFIG="${DOCKER_CONFIG_FILE}"
# fi

# Pull the latest version of docker-make
docker pull didstopia/docker-make:latest

# Run docker-make with the custom Docker configuration file 
docker run \
  --rm \
  -w /usr/src/app \
  -v ~/.docker:/root/.docker \
  -v ${DOCKER_CUSTOM_CONFIG}:/root/.docker/config.json \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd)":/usr/src/app didstopia/docker-make:latest \
  docker-make -rm "$@"

# Disable error handling (useful when running with "source")
set +e
set +o pipefail
