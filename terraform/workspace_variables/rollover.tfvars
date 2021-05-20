# PaaS
paas_app_environment       = "rollover"
paas_cf_space              = "bat-staging"
paas_web_app_memory        = 1024
paas_web_app_instances     = 2
paas_postgres_service_plan = "small-11"
paas_redis_service_plan    = "micro-5_x"

# KeyVault
key_vault_resource_group    = "s121t01-shared-rg"
key_vault_name              = "s121t01-shared-kv-01"
key_vault_app_secret_name   = "APPLY-APP-SECRETS-ROLLOVER"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-ROLLOVER"

# StatusCake
statuscake_alerts = {
  apply-rollover-check = {
    website_name   = "Apply-Teacher-Training-Check-Rollover"
    website_url    = "https://apply-rollover.london.cloudapps.digital/check"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
}
