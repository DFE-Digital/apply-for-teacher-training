# PaaS
paas_app_environment           = "load-test"
paas_cf_space                  = "bat-prod"
paas_web_app_memory            = 4096
paas_worker_app_memory         = 4096
paas_clock_app_memory          = 1024
paas_web_app_instances         = 8
paas_worker_app_instances      = 2
paas_postgres_service_plan     = "medium-ha-11"
paas_worker_redis_service_plan = "micro-ha-5_x"
paas_cache_redis_service_plan  = "micro-ha-5_x"

# KeyVault
key_vault_resource_group    = "s121d01-shared-rg"
key_vault_name              = "s121d01-shared-kv-01"
key_vault_app_secret_name   = "APPLY-APP-SECRETS-LOADTEST"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-QA"

# Network Policy
prometheus_app = "prometheus-bat"
