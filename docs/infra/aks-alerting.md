# AKS alerting configuration

## Purpose

This document describes the alerting configuration for AKS

## Backend Service Alerting

Postgres and Redis monitoring is configured within the aks terraform

If enabled it will monitor and alert via email on the following
- postgres memory, cpu and storage used
- redis memory used

### To enable backing service alerting

1. Create an alert action group manually for each subscription

Current config is 1 ag per subscription per app.
So for apply this is
- s189d01-att-dev-ag in rg s189d01-att-rv-rg
- s189t01-att-test-ag in rg s189t01-att-qa-rg
- s189p01-att-production-ag in rg s189p01-att-pd-rg

2. Update tvfars.json

In each terraform/aks/workspace_variables/${env}.tfvars.json, set
- "enable_alerting": true
- "pg_actiongroup_name": "actiongroup_name from step 1",
- "pg_actiongroup_rg": "actiongroup_rg from step 1",

3. If required, add alert threshold overrides to terraform/aks/workspace_variables/${env}.tfvars.json

Defaults:
- pg_memory_threshold        default = 75
- pg_cpu_threshold           default = 60
- pg_storage_threshold       default = 75
- redis_memory_threshold     default = 60

## CDN/Frontdoor Alerting

CDN/Frontdoor monitoring is configured within the custom_domains terraform

If enabled it will monitor and alert via email on the following
- high request latency
- high 5xx request rate

### To enable CDN alerting

1. Create an alert action group manually for the prod subscription (if one doesn't already exist from the backing service)

CDN/fd is only configured in the prod subscription.
So for apply this is
- s189p01-att-production-ag in rg s189p01-att-pd-rg

2. Update tvfars.json

In each terraform/custom_domains/environment_domains/workspace_variables/apply-${env}.tfvars.json, set
- "enable_alerting":
- "pg_actiongroup_name": "actiongroup_name from step 1",
- "pg_actiongroup_rg": "actiongroup_rg from step 1",

3. If required, add alert threshold overrides to terraform/custom_domains/environment_domains/workspace_variables/apply-${env}.tfvars.json

Defaults:
- latency_threshold          default = 1500
- percent_5xx_threshold      default = 15
