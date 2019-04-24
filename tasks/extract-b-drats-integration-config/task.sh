#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2153

set -eu

pushd terraform-state
  bosh_host="$(terraform output director-ip)"
popd

bosh_ssh_username="${BOSH_SSH_USERNAME}"
bosh_ssh_private_key="$(bosh int --path=/jumpbox_ssh/private_key "${BOSH_VARS_STORE_PATH}")"
timeout_in_minutes="${TIMEOUT_IN_MINUTES}"
bosh_client="${BOSH_CLIENT}"
bosh_client_secret="$(bosh int --path=/admin_password "${BOSH_VARS_STORE_PATH}")"
bosh_ca_cert="$(bosh int --path=/director_ssl/ca "${BOSH_VARS_STORE_PATH}")"
include_deployment_testcase="${INCLUDE_DEPLOYMENT_TESTCASE}"
include_truncate_db_blobstore_testcase="${INCLUDE_TRUNCATE_DB_BLOBSTORE_TESTCASE}"
include_credhub_testcase="${INCLUDE_CREDHUB_TESTCASE}"
stemcell_src=$(cat stemcell/url)

integration_config="{}"

string_vars="bosh_host bosh_ssh_username bosh_ssh_private_key bosh_client bosh_client_secret bosh_ca_cert stemcell_src"
for var in $string_vars
do
  integration_config=$(echo ${integration_config} | jq ".${var}=\"${!var}\"")
done

other_vars="include_deployment_testcase include_truncate_db_blobstore_testcase include_credhub_testcase timeout_in_minutes"
for var in $other_vars
do
  integration_config=$(echo "${integration_config}" | jq ".${var}=${!var}")
done

echo "$integration_config" > "${OUTPUT_DIR}/integration_config.json"
