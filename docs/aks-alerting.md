# AKS alerting configuration

## Purpose

This document describes the alerting configuration for AKS

## Backend Service Alerting

Postgres and Redis monitoring is configured within the environment terraform

If enabled it will monitor and alert via email on the following
- postgres memory, cpu and storage used
- redis memory used

### To enable backing service alerting

1. Update tvfars.json

In terraform/aks/workspace_variables/${env}.tfvars.json, set

"enable_alerting": true

2. If required, add alert threshold overrides to terraform/aks/workspace_variables/${env}.tfvars.json

Defaults below:

pg_memory_threshold        default = 75

pg_cpu_threshold           default = 60

pg_storage_threshold       default = 75

redis_memory_threshold     default = 60

3. Set email alert group

Add ALERT_EMAILGROUP to the infra keyvault secret for that environment

Note that alerting will only be configured if Azure backing services are being used

i.e. "deploy_azure_backing_services": true

## CDN/Frontdoor Alerting

CDN/Frontdoor monitoring is configured within the custom_domain terraform

If enabled it will monitor and alert via email on the following
- high request latency
- high 5xx request rate

### To enable CDN alerting

1. Update tvfars.json

In terraform/custom_domains/environment_domains/workspace_variables/apply-${env}.tfvars.json, set

"alert_domains": ["apply-for-teacher-training.service.gov.uk"]

2. If required, add alert threshold overrides to terraform/custom_domains/environment_domains/workspace_variables/apply-${env}.tfvars.json

Defaults below:

latency_threshold"         default = 1500

percent_5xx_threshold      default = 10

3. Set email alert group

Add ALERT_EMAILGROUP to the infra keyvault secret for that environment
