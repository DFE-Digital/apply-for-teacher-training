# PaaS
paas_app_environment       = "staging"
paas_cf_space              = "bat-staging"
paas_web_app_memory        = 512
paas_web_app_instances     = 1
paas_postgres_service_plan = "small-11"
paas_redis_service_plan    = "micro-5_x"

# KeyVault
key_vault_resource_group    = "s121t01-shared-rg"
key_vault_name              = "s121t01-shared-kv-01"
key_vault_app_secret_name   = "APPLY-APP-SECRETS-STAGING"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-STAGING"
