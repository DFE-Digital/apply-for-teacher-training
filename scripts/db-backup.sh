#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

required NAMESPACE
required DB_TOOLS_POD_NAME

cleanup_if_required() {
    local exit_code=$?

    if [[ "${CLEANUP_DB_TOOLS_POD:-true}" == "true" ]]; then
        echo "Cleaning up db tools pod..."

        NAMESPACE="$NAMESPACE" \
        DB_TOOLS_POD_NAME="$DB_TOOLS_POD_NAME" \
        "$(dirname "$0")/cleanup-db-tools-pod.sh"

    else
        echo "leaving pod and secret in place.."
    fi

    exit "$exit_code"
}

trap cleanup_if_required EXIT

# backup logic...
kubectl exec \
  -i \
  -n "$NAMESPACE" \
  "$DB_TOOLS_POD_NAME" \
  -- \
  /bin/bash -c '
    set -euo pipefail

    cd /tmp

    echo "Running pg_dump..."

    pg_dump \
      -d "$DATABASE_URL" \
      -E utf8 \
      --clean \
      --compress=1 \
      --if-exists \
      --no-owner \
      --verbose \
      --no-password \
      -f pg_backup.gz

    echo "Uploading backup..."

    azcopy cp \
      ./pg_backup.gz \
      "$AZURE_STORAGE_SAS_URL"
  '
