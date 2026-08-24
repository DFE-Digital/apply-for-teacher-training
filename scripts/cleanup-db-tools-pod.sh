#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

required NAMESPACE
required DB_TOOLS_POD_NAME

kubectl delete pod \
  "$DB_TOOLS_POD_NAME" \
  -n "$NAMESPACE" \
  --ignore-not-found

kubectl delete secret \
  backup-sas \
  -n "$NAMESPACE" \
  --ignore-not-found
