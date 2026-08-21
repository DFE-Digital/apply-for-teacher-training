#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '%s\n' "$*"
}

error() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

required() {
  local var="$1"

  if [[ -z "${!var:-}" ]]; then
    error "Missing environment variable: ${var}"
  fi
}

cleanup_secret_files() {
  rm -f /tmp/sas_token.$$ /tmp/sas_url.$$
}
