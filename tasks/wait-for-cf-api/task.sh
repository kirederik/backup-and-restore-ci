#!/usr/bin/env bash

call_cf_api() {
    cf api "${CF_API_URL}" --skip-ssl-validation
}

set -e
curl "${CF_API_URL}" --fail --retry "${RETRY_COUNT}" --insecure
set +e

for i in $(seq 1 ${RETRY_COUNT}); do
    call_cf_api
    exit_code=$?

    if [[ ${exit_code} -eq 0 ]]; then
        break
    fi

    sleep 15
done

if [[ ${exit_code} -ne 0 ]]; then
   echo "Failed to successfully connect to CF API after ${RETRY_COUNT} tries"
   exit 1
fi

set -e

for i in $(seq 1 ${RETRY_COUNT}); do
    sleep 15

    call_cf_api
done