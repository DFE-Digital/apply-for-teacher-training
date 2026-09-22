#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

required NAMESPACE
required DB_TOOLS_POD_NAME

cleanup_if_required() {
    local exit_code=$?

    if [[ "${CLEANUP_DB_TOOLS_POD:-true}" == "true" ]]; then
        NAMESPACE="$NAMESPACE" \
        DB_TOOLS_POD_NAME="$DB_TOOLS_POD_NAME" \
        "$(dirname "$0")/cleanup-db-tools-pod.sh"
    fi

    exit "$exit_code"
}

trap cleanup_if_required EXIT

kubectl exec \
  -i \
  -n "$NAMESPACE" \
  "$DB_TOOLS_POD_NAME" \
  -- \
  /bin/bash -c '
    azcopy list "$AZURE_STORAGE_SAS_URL"
  '