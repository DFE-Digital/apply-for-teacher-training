# PaaS
paas_app_environment           = "prod"
paas_cf_space                  = "bat-prod"
paas_web_app_memory            = 6144
paas_worker_app_memory         = 4096
paas_clock_app_memory          = 1024
paas_web_app_instances         = 8
paas_worker_app_instances      = 2
paas_postgres_service_plan     = "medium-ha-11"
paas_worker_redis_service_plan = "micro-ha-5_x"
paas_cache_redis_service_plan  = "micro-ha-5_x"

# KeyVault
key_vault_resource_group    = "s121p01-shared-rg"
key_vault_name              = "s121p01-shared-kv-01"
key_vault_app_secret_name   = "APPLY-APP-SECRETS-PRODUCTION"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-PRODUCTION"

# Network Policy
prometheus_app = "prometheus-bat"

# StatusCake
statuscake_alerts = {
  apply-prod = {
    website_name   = "Apply-Teacher-Training-Prod"
    website_url    = "https://www.apply-for-teacher-training.service.gov.uk/check"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-prod-monitoring = {
    website_name   = "Apply-Teacher-Training-Monitoring-Prod"
    website_url    = "https://www.apply-for-teacher-training.service.gov.uk/integrations/monitoring/all"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-cloudapps-prod = {
    website_name   = "Apply-Teacher-Training-Cloudapps-Prod"
    website_url    = "https://apply-prod.london.cloudapps.digital/check"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-cloudapps-prod-monitoring = {
    website_name   = "Apply-Teacher-Training-Cloudapps-Prod"
    website_url    = "https://apply-prod.london.cloudapps.digital/integrations/monitoring/all"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
}
