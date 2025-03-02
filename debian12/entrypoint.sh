#!/bin/bash

./config.sh --unattended \
        --replace --url https://github.com/${GH_REPO} --token ${REG_TOKEN} --name ${RUNNER_NAME} --labels ${RUNNER_LABELS}

cleanup() {
  echo "Removing runner..."
 ./config.sh remove --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!