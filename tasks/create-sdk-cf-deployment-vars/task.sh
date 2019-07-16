#!/usr/bin/env bash

set -euo pipefail

autogenerated_message="# variables autogenerated by the create-sdk-cf-deployment-vars task"

terraform_output() {
  terraform output -state="terraform-state-${1}/terraform.tfstate" "$2"
}

live_bucket="$(terraform_output aws "backup-and-restore-s3-unversioned-acceptance-live-bucket")"
backup_bucket="$(terraform_output aws "backup-and-restore-s3-unversioned-acceptance-backup-bucket")"

echo """
${autogenerated_message}
aws_region: ${AWS_REGION}
aws_backup_region: ${AWS_BACKUP_REGION}
blobstore_access_key_id: ${AWS_ACCESS_KEY}
blobstore_secret_access_key: ${AWS_SECRET_KEY}
buildpack_directory_key: ${live_bucket}
buildpack_backup_directory_key: ${backup_bucket}
app_package_directory_key: ${live_bucket}
app_package_backup_directory_key: ${backup_bucket}
droplet_directory_key: ${live_bucket}
droplet_backup_directory_key: ${backup_bucket}
resource_directory_key: ${live_bucket}
""" > "bosh-backup-and-restore-meta/${S3_UNVERSIONED_CF_DEPLOYMENT_VARS_FILE}"


live_bucket="$(terraform_output aws "backup-and-restore-s3-versioned-acceptance-live-bucket")"
database_address="$(terraform_output aws "backup-and-restore-acceptance-external-db-address")"

echo """
${autogenerated_message}
aws_region: ${AWS_REGION}
blobstore_access_key_id: ${AWS_ACCESS_KEY}
blobstore_secret_access_key: ${AWS_SECRET_KEY}
buildpack_directory_key: ${live_bucket}
app_package_directory_key: ${live_bucket}
droplet_directory_key: ${live_bucket}
resource_directory_key: ${live_bucket}
external_database_type: ${DATABASE_TYPE}
external_database_port: ${DATABASE_PORT}
external_cc_database_name: cc-db
external_cc_database_address: ${database_address}
external_cc_database_username: ${DATABASE_USERNAME}
external_cc_database_password: ${DATABASE_PASSWORD}
external_uaa_database_name: uaa-db
external_uaa_database_address: ${database_address}
external_uaa_database_username: ${DATABASE_USERNAME}
external_uaa_database_password: ${DATABASE_PASSWORD}
external_bbs_database_name: bbs-db
external_bbs_database_address: ${database_address}
external_bbs_database_username: ${DATABASE_USERNAME}
external_bbs_database_password: ${DATABASE_PASSWORD}
external_routing_api_database_name: api-db
external_routing_api_database_address: ${database_address}
external_routing_api_database_username: ${DATABASE_USERNAME}
external_routing_api_database_password: ${DATABASE_PASSWORD}
external_policy_server_database_address: ${database_address}
external_policy_server_database_name: policy-server-db
external_policy_server_database_password: ${DATABASE_PASSWORD}
external_policy_server_database_username: ${DATABASE_USERNAME}
external_silk_controller_database_address: ${database_address}
external_silk_controller_database_name: silk-controller-db
external_silk_controller_database_password: ${DATABASE_PASSWORD}
external_silk_controller_database_username: ${DATABASE_USERNAME}
external_locket_database_password: ${DATABASE_PASSWORD}
external_locket_database_address: ${database_address}
external_locket_database_name: locket-db
external_locket_database_username: ${DATABASE_USERNAME}
external_credhub_database_password: ${DATABASE_PASSWORD}
external_credhub_database_username: ${DATABASE_USERNAME}
external_credhub_database_name: credhub-db
external_credhub_database_address: ${database_address}
""" > "bosh-backup-and-restore-meta/${S3_VERSIONED_CF_DEPLOYMENT_VARS_FILE}"

live_bucket="$(terraform_output gcp "backup-and-restore-sdk-gcp-acceptance-live-bucket")"
backup_bucket="$(terraform_output gcp "backup-and-restore-sdk-gcp-acceptance-backup-bucket")"
project_id="$(jq -r .project_id <<< "$GCP_SERVICE_ACCOUNT_KEY")"
email="$(jq -r .client_email <<< "$GCP_SERVICE_ACCOUNT_KEY")"

echo """
${autogenerated_message}
gcs_project: ${project_id}
gcs_service_account_email: ${email}
gcs_service_account_json_key: ${GCP_SERVICE_ACCOUNT_KEY}
buildpack_backup_directory_key: ${backup_bucket}
app_package_directory_key: ${live_bucket}
app_package_backup_directory_key: ${backup_bucket}
droplet_directory_key: ${live_bucket}
droplet_backup_directory_key: ${backup_bucket}
resource_directory_key: ${live_bucket}
""" > "bosh-backup-and-restore-meta/${GCS_CF_DEPLOYMENT_VARS_FILE}"

live_bucket="$(terraform_output azure "blobstore-container")"
storage_account_name="$(terraform_output azure "azure-storage-account-name")"
storage_account_key="$(terraform_output azure "azure-storage-account-key")"

echo """
${autogenerated_message}
app_package_directory_key: ${live_bucket}
droplet_directory_key: ${live_bucket}
environment: AzureCloud
blobstore_storage_access_key: ${storage_account_key}
blobstore_storage_account_name: ${storage_account_name}
buildpack_directory_key: ${live_bucket}
resource_directory_key: ${live_bucket}
""" > "bosh-backup-and-restore-meta/${AZURE_CF_DEPLOYMENT_VARS_FILE}"

(
  cd bosh-backup-and-restore-meta

  git add "$S3_VERSIONED_CF_DEPLOYMENT_VARS_FILE"
  git add "$S3_UNVERSIONED_CF_DEPLOYMENT_VARS_FILE"
  git add "$GCS_CF_DEPLOYMENT_VARS_FILE"
  git add "$AZURE_CF_DEPLOYMENT_VARS_FILE"

  if git commit -m "Update cf-deployment vars for external directors"; then
    echo "Updated cf-deployment vars for external directors"
  else
    echo "No change to cf-deployment vars for external directors"
  fi
)

