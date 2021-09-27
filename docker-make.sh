#!/usr/bin/env bash

# Remove temporary custom Docker configuration file when shell script exits
trap "rm -f $dockercfg" EXIT

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

## FIXME: Only run this if NOT using a CI (CI does not use a credentials helper!)
##        NOTE: Alternatively setup a credential helper for CI?

# Login to Docker Hub
if [[ ! -z "${DOCKER_USERNAME}" && ! -z "${DOCKER_PASSWORD}" ]]; then
    echo "Logging in to Docker Hub.."
    docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD" > /dev/null
    echo ""
fi

# Ensure that the Docker configuration file exists
if [[ ! -f "${HOME}/.docker/config.json" ]]; then
    echo "ERROR: Docker configuration file missing from ${HOME}/.docker/config.json"
    exit 1
else
  echo "Docker configuration file exists at ${HOME}/.docker/config.json"
fi

# Create a temporary custom Docker configuration file with the credentials embedded,
# otherwise docker-make will refuse to work correctly, as it needs permissions to push
# mkdir ~/.docker && touch ~/.docker/config.json
dockercfg=$(mktemp /tmp/dockercfg.XXXXX)
if grep -q credsStore "~/.docker/config.json"; then
    echo "Customizing Docker credentials for docker-make"
    storetype=$(jq -r .credsStore < ~/.docker/config.json)
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
    ) > $dockercfg
else
    echo "Skipping Docker credentials customization for docker-make"
fi

# Pull the latest version of docker-make
docker pull didstopia/docker-make:latest

# Run docker-make with the custom Docker configuration file 
docker run \
  --rm \
  -w /usr/src/app \
  -v ~/.docker:/root/.docker \
  -v ${dockercfg}:/root/.docker/config.json \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd)":/usr/src/app didstopia/docker-make:latest \
  docker-make -rm "$@"

# Disable error handling (useful when running with "source")
set +e
set +o pipefail
