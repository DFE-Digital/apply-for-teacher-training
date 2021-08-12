# PaaS
paas_app_environment           = "qa"
paas_cf_space                  = "bat-qa"
paas_web_app_memory            = 1024
paas_web_app_instances         = 2
paas_postgres_service_plan     = "small-11"
paas_worker_redis_service_plan = "micro-5_x"
paas_cache_redis_service_plan  = "micro-5_x"

# KeyVault
key_vault_resource_group    = "s121d01-shared-rg"
key_vault_name              = "s121d01-shared-kv-01"
key_vault_app_secret_name   = "APPLY-APP-SECRETS-QA"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-QA"

# Network Policy
prometheus_app = "prometheus-bat-qa"

# StatusCake
statuscake_alerts = {
  apply-qa = {
    website_name   = "Apply-Teacher-Training-QA"
    website_url    = "https://qa.apply-for-teacher-training.service.gov.uk/integrations/monitoring/all"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-qa-check = {
    website_name   = "Apply-Teacher-Training-Check-QA"
    website_url    = "https://qa.apply-for-teacher-training.service.gov.uk/check"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-cloudapps-qa = {
    website_name   = "Apply-Teacher-Training-Cloudapps-QA"
    website_url    = "https://apply-qa.london.cloudapps.digital/check"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 1
  }
}
