# PaaS
paas_app_environment       = "prod"
paas_cf_space              = "bat-prod"
paas_web_app_memory        = 1024
paas_web_app_instances     = 2
paas_postgres_service_plan = "small-ha-11"
paas_redis_service_plan    = "micro-ha-5_x"

# KeyVault
key_vault_resource_group    = "s121p01-shared-rg"
key_vault_name              = "s121p01-shared-kv-01"
key_vault_app_secret_name   = "APPLY-APP-SECRETS-PRODUCTION"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-PRODUCTION"
