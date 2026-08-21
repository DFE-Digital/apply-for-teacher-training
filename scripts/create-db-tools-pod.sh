#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

required NAMESPACE
required DB_TOOLS_POD_NAME
required SECRET_REF_NAME

export NAMESPACE
export DB_TOOLS_POD_NAME
export SECRET_REF_NAME

envsubst < db-pod/db-pod.yaml.tpl \
  | kubectl apply -n "$NAMESPACE" -f -

sleep 2
