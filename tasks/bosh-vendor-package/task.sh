#!/usr/bin/env bash

set -e

pushd release
  bosh vendor-package "${VENDORED_PACKAGE_NAME}" ../vendored-package-release

  git add .

  if git commit -m "Update vendored package ${VENDORED_PACKAGE_NAME}"; then
    echo "Updated vendored package ${VENDORED_PACKAGE_NAME}"
  else
    echo "No change to vendored package ${VENDORED_PACKAGE_NAME}"
  fi
popd

cp -r release/. release-with-updated-vendored-package