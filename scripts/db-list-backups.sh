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

backup_list="$({
  kubectl exec \
    -i \
    -n "$NAMESPACE" \
    "$DB_TOOLS_POD_NAME" \
    -- \
    /bin/bash -c '
            set +e
            azcopy_output="$(azcopy list "$AZURE_STORAGE_SAS_URL" 2>&1)"
            azcopy_exit_code=$?
            storage_url_without_query="${AZURE_STORAGE_SAS_URL%%\?*}"
            redacted_storage_url="${storage_url_without_query}?[REDACTED]"
            printf "%s\n" "${azcopy_output//"$AZURE_STORAGE_SAS_URL"/"$redacted_storage_url"}"
            exit "$azcopy_exit_code"
    '
} 2>&1)"

printf '\nAvailable database backups:\n%s\n' "$backup_list"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    {
        printf '## Available database backups\n\n'
        printf '```text\n%s\n```\n' "$backup_list"
    } >> "$GITHUB_STEP_SUMMARY"
fi