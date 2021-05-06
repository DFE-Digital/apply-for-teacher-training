# PaaS
paas_app_environment       = "prod"
paas_cf_space              = "bat-prod"
paas_web_app_memory        = 1024
paas_worker_app_memory     = 1024
paas_web_app_instances     = 4
paas_worker_app_instances  = 2
paas_postgres_service_plan = "small-ha-11"
paas_redis_service_plan    = "micro-ha-5_x"

# KeyVault
key_vault_resource_group    = "s121p01-shared-rg"
key_vault_name              = "s121p01-shared-kv-01"
key_vault_app_secret_name   = "APPLY-APP-SECRETS-PRODUCTION"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-PRODUCTION"

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
  apply-prod-sidekiq-retries = {
    website_name   = "Apply-Teacher-Training-Check-Prod"
    website_url    = "https://www.apply-for-teacher-training.service.gov.uk/integrations/monitoring/sidekiq_retries_count"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-prod-sidekiq-mailer = {
    website_name   = "Apply-Teacher-Training-Sidekiq-Mailers-Queue-Prod"
    website_url    = "https://www.apply-for-teacher-training.service.gov.uk/integrations/monitoring/sidekiq_mailers_queue"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-prod-sidekiq-default = {
    website_name   = "Apply-Teacher-Training-Sidekiq-Default-Queue-Prod"
    website_url    = "https://www.apply-for-teacher-training.service.gov.uk/integrations/monitoring/sidekiq_default_queue"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-prod-redis = {
    website_name   = "Apply-Teacher-Training-Redis-Prod"
    website_url    = "https://www.apply-for-teacher-training.service.gov.uk/integrations/monitoring/redis"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [204421]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-prod-postgres = {
    website_name   = "Apply-Teacher-Training-Postgres-Prod"
    website_url    = "https://www.apply-for-teacher-training.service.gov.uk/integrations/monitoring/postgres"
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
}
