#!/usr/bin/env bash
set -euo pipefail



# source global_config/${DEPLOY_ENV}.sh
# tf_vars_file=${TF_VARS_PATH}/${DEPLOY_ENV}.tfvars.json
# echo "CLUSTER=$(jq -r '.cluster' ${tf_vars_file})" >> $GITHUB_ENV
# echo "AKS_ENV=$(jq -r '.app_environment' ${tf_vars_file})" >> $GITHUB_ENV
# echo "NAMESPACE=$(jq -r '.namespace' ${tf_vars_file})" >> $GITHUB_ENV
# echo "RESOURCE_GROUP_NAME=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg" >> $GITHUB_ENV
# echo "STORAGE_ACCOUNT_NAME=${RESOURCE_NAME_PREFIX}${SERVICE_SHORT}dbbkp${CONFIG_SHORT}sa" >> $GITHUB_ENV
# TODAY=$(date +"%F_%H%M%S")
# if [ "${BACKUP_FILE}" == "schedule" ]; then
#   BACKUP_FILE=${SERVICE_SHORT}_${CONFIG_SHORT}_${TODAY}
# elif [ "${BACKUP_FILE}" == "default" ]; then
#   BACKUP_FILE=${SERVICE_SHORT}_${CONFIG_SHORT}_adhoc_${TODAY}
# else
#   BACKUP_FILE=${BACKUP_FILE}
# fi
# echo "BACKUP_FILE=${BACKUP_FILE}" >> $GITHUB_ENV





source global_config/${DEPLOY_ENV}.sh
tf_vars_file=${TF_VARS_PATH}/${DEPLOY_ENV}.tfvars.json
CLUSTER=$(jq -r '.cluster' ${tf_vars_file})
AKS_ENV=$(jq -r '.app_environment' ${tf_vars_file})
NAMESPACE=$(jq -r '.namespace' ${tf_vars_file})
RESOURCE_GROUP_NAME=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg
STORAGE_ACCOUNT_NAME=${RESOURCE_NAME_PREFIX}${SERVICE_SHORT}dbbkp${CONFIG_SHORT}sa

TODAY=$(date +"%F_%H%M%S")
if [ "${BACKUP_FILE}" == "schedule" ]; then
  BACKUP_FILE=${SERVICE_SHORT}_${CONFIG_SHORT}_${TODAY}
elif [ "${BACKUP_FILE}" == "default" ]; then
  BACKUP_FILE=${SERVICE_SHORT}_${CONFIG_SHORT}_adhoc_${TODAY}
else
  BACKUP_FILE=${BACKUP_FILE}
fi
BACKUP_FILE=${BACKUP_FILE}






STORAGE_ACCOUNT_NAME="s189d01attrvrdgexp"
CONTAINER_NAME="database-backup"
SAS_VALID_HOURS="2"
JOB_NAME=postgres-backup-${TODAY}

# Expiry timestamp in UTC
EXPIRY=$(date -u -d "+${SAS_VALID_HOURS} hours" '+%Y-%m-%dT%H:%MZ')

STORAGE_ACCOUNT_KEY=$(az storage account keys list \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --query "[0].value" \
  -o tsv)

SAS_TOKEN=$(
az storage container generate-sas \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --account-key "$STORAGE_ACCOUNT_KEY" \
  --name "$CONTAINER_NAME" \
  --permissions acdlrw \
  --expiry "$EXPIRY" \
  --https-only \
  --output tsv
)

# Build SAS URL
SAS_URL="https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${CONTAINER_NAME}/${JOB_NAME}.bak?${SAS_TOKEN}"

kubectl delete secret backup-sas -n development --ignore-not-found=true
kubectl create secret generic backup-sas \
  --from-literal=AZURE_STORAGE_SAS_URL="$SAS_URL" \
  -n development

kubectl delete pod postgres-backup-debug -n development
kubectl apply -f cronjob/debug-pod.yaml
kubectl exec -it -n development postgres-backup-debug -- \
/bin/bash -c '

#set -euo pipefail

cd /tmp

echo "running pg_dump"
pg_dump -d "$DATABASE_URL" \
  -E utf8 \
  --clean \
  --compress=1 \
  --if-exists \
  --no-owner \
  --verbose \
  --no-password \
  -f pg_backup.gz

echo "running azcopy"
azcopy cp ./pg_backup.gz ${AZURE_STORAGE_SAS_URL}
'
