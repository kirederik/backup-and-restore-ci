#!/usr/bin/env bash

set -eu

echo -e "${BOSH_GW_PRIVATE_KEY}" > "${PWD}/ssh.key"
chmod 0600 "${PWD}/ssh.key"
export BOSH_GW_PRIVATE_KEY="${PWD}/ssh.key"

export BOSH_ALL_PROXY="ssh+socks5://${BOSH_GW_USER}@${BOSH_GW_HOST}:22?private-key=${BOSH_GW_PRIVATE_KEY}"

export GOPATH="${PWD}/backup-and-restore-sdk-release"
export PATH="${PATH}:${GOPATH}/bin"

pushd backup-and-restore-sdk-release/src/github.com/cloudfoundry-incubator/backup-and-restore-sdk-release-system-tests/s3
  if [[ ! -z "${FOCUS_SPEC}" ]]; then
    ginkgo -focus "${FOCUS_SPEC}" -v -r -trace
  else
    ginkgo -v -r -trace
  fi
popd