#!/usr/bin/env bash

set -eu

NAMESPACE=$(jq -r '.namespace' terraform/aks/workspace_variables/${CONFIG}.tfvars.json)

echo Reset external ingress
kubectl -n ${NAMESPACE} apply -f maintenance_page/manifests/${CONFIG}/ingress_external_to_main.yml

echo Reset internal ingress
kubectl -n ${NAMESPACE} apply -f maintenance_page/manifests/${CONFIG}/ingress_internal_to_main.yml

echo Delete temp ingress
kubectl -n ${NAMESPACE} delete --ignore-not-found=true -f maintenance_page/manifests/${CONFIG}/ingress_temp_to_main.yml

echo Delete maintenance ingress
kubectl -n ${NAMESPACE} delete --ignore-not-found=true -f maintenance_page/manifests/${CONFIG}/ingress_maintenance.yml

echo Delete maintenance service
kubectl -n ${NAMESPACE} delete --ignore-not-found=true -f maintenance_page/manifests/maintenance/service_maintenance.yml

echo Update image tag
perl -p -e "s/#MAINTENANCE_IMAGE_TAG#/dummy-tag/" maintenance_page/manifests/maintenance/deployment_maintenance.yml.tmpl \
    > maintenance_page/manifests/maintenance/deployment_maintenance.yml

echo Delete maintenance app
kubectl -n ${NAMESPACE} delete --ignore-not-found=true -f maintenance_page/manifests/maintenance/deployment_maintenance.yml
