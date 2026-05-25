## Based on https://github.com/myoung34/docker-github-actions-runner/blob/clair/install_actions.sh
#!/usr/bin/env bash

set -e
# set -o pipefail

set -x

GH_RUNNER_VERSION=$1
GH_RUNNER_PLATFORM=$2

export TARGET_ARCH="x64"
if [[ $GH_RUNNER_PLATFORM == "linux/arm/v7" ]]; then
  export TARGET_ARCH="arm"
elif [[ $GH_RUNNER_PLATFORM == "linux/arm64" ]]; then
  export TARGET_ARCH="arm64"
fi

curl -L "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-${TARGET_ARCH}-${GH_RUNNER_VERSION}.tar.gz" -o actions.tar.gz
tar -zxf actions.tar.gz
rm -f actions.tar.gz

./bin/installdependencies.sh

mkdir /app/_work
