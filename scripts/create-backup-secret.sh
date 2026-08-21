#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

required STORAGE_ACCOUNT_NAME
required CONTAINER_NAME
required NAMESPACE
required EXPIRY
required SAS_PERMISSIONS

storage_account_key=$(
  az storage account keys list \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --query '[0].value' \
    -o tsv
)

sas_token=$(
  az storage container generate-sas \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --account-key "$storage_account_key" \
    --name "$CONTAINER_NAME" \
    --permissions "$SAS_PERMISSIONS" \
    --expiry "$EXPIRY" \
    --https-only \
    -o tsv
)

if [[ -n "${BLOB_URL:-}" ]]; then
  sas_url="${BLOB_URL}?${sas_token}"
else
  sas_url="notset"
fi

kubectl delete secret backup-sas \
  -n "$NAMESPACE" \
  --ignore-not-found

kubectl create secret generic backup-sas \
  -n "$NAMESPACE" \
  --from-literal=AZURE_STORAGE_SAS_TOKEN="$sas_token" \
  --from-literal=AZURE_STORAGE_SAS_URL="$sas_url"

unset storage_account_key
unset sas_token
unset sas_url

log "backup-sas secret created"
