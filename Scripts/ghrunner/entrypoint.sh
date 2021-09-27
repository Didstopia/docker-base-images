## Based on https://github.com/myoung34/docker-github-actions-runner/blob/clair/entrypoint.sh
#!/usr/bin/env bash

export RUNNER_ALLOW_RUNASROOT=1
export PATH=$PATH:/app

## TODO: Test if the runner automatically de-registers itself
##       now that it has ephemeral support?
deregister_runner() {
  # echo "Caught SIGTERM. Deregistering runner"
  # _TOKEN=$(bash /token.sh)
  # RUNNER_TOKEN=$(echo "${_TOKEN}" | jq -r .token)
  # ./config.sh remove --token "${RUNNER_TOKEN}"
  exit
}

_RUNNER_NAME=${RUNNER_NAME:-${RUNNER_NAME_PREFIX:-github-runner}-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')}
_RUNNER_WORKDIR=${RUNNER_WORKDIR:-/app/_work}
_LABELS=${LABELS:-default}
_SHORT_URL=${REPO_URL}

if [[ -n "${ACCESS_TOKEN}" ]]; then
  _TOKEN=$(bash /token.sh)
  RUNNER_TOKEN=$(echo "${_TOKEN}" | jq -r .token)
  _SHORT_URL=$(echo "${_TOKEN}" | jq -r .short_url)
fi

## TODO: Ensure that these flags still work, but also check if there are new potentialy useful ones?
echo "Configuring"
./config.sh \
  --url "${_SHORT_URL}" \
  --token "${RUNNER_TOKEN}" \
  --name "${_RUNNER_NAME}" \
  --work "${_RUNNER_WORKDIR}" \
  --labels "${_LABELS}" \
  --unattended \
  --replace

unset RUNNER_TOKEN
trap deregister_runner SIGINT SIGQUIT SIGTERM

## NOTE: The runner now has full support for ephemeral mode:
##       https://github.com/actions/runner/releases/tag/v2.283.1
# ./run.sh --once
./run.sh --ephemeral
