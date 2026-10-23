#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

required NAMESPACE
required DB_TOOLS_POD_NAME
required DESTINATION_SERVER
required DESTINATION_DATABASE

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

kubectl exec \
  -i \
  -n "$NAMESPACE" \
  "$DB_TOOLS_POD_NAME" \
  -- env \
  DESTINATION_SERVER="$DESTINATION_SERVER" \
  DESTINATION_DATABASE="$DESTINATION_DATABASE" \
  /bin/bash -c '
    set -euo pipefail

    cd /tmp

    echo "Building destination connection string..."

    ORIGINAL_URL="$DATABASE_URL"

    DESTINATION_URL=$(python3 - <<EOF
from urllib.parse import urlparse, urlunparse
import os

url = urlparse(os.environ["ORIGINAL_URL"])

new_netloc = (
    f"{url.username}:{url.password}@"
    f"{os.environ['DESTINATION_SERVER']}:5432"
)

print(
    urlunparse((
        url.scheme,
        new_netloc,
        os.environ["DESTINATION_DATABASE"],
        "",
        url.query,
        ""
    ))
)
EOF
)

    echo "Testing destination connection..."

    psql "$DESTINATION_URL" \
      -c "SELECT current_database();"

    echo "Downloading backup..."

    azcopy cp \
      "$AZURE_STORAGE_SAS_URL" \
      ./pg_backup.gz

    echo "Restoring database..."

    gunzip -c pg_backup.gz | psql "$DESTINATION_URL"

    echo "Restore completed successfully."
  '