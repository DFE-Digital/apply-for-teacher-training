# PaaS
paas_app_environment           = "research"
paas_cf_space                  = "bat-qa"
paas_web_app_memory            = 1024
paas_web_app_instances         = 2
paas_postgres_service_plan     = "small-11"
paas_worker_redis_service_plan = "micro-5_x"
paas_cache_redis_service_plan  = "micro-5_x"

# KeyVault
key_vault_resource_group    = "s121d01-shared-rg"
key_vault_name              = "s121d01-shared-kv-01"
key_vault_app_secret_name   = "APPLY-APP-SECRETS-RESEARCH"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-QA"
