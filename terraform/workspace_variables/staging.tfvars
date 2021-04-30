# PaaS
paas_app_environment       = "staging"
paas_cf_space              = "bat-staging"
paas_web_app_memory        = 512
paas_web_app_instances     = 1
paas_postgres_service_plan = "small-11"
paas_redis_service_plan    = "micro-5_x"
paas_clock_app_command     = "bundle exec clockwork config/clock.rb"
paas_worker_app_command    = "bundle exec sidekiq -c 5 -C config/sidekiq.yml"

# KeyVault
key_vault_resource_group    = "s121t01-shared-rg"
key_vault_name              = "s121t01-shared-kv-01"
key_vault_app_secret_name   = "APPLY-APP-SECRETS-STAGING"
key_vault_infra_secret_name = "BAT-INFRA-SECRETS-STAGING"

# StatusCake
statuscake_alerts = {
  apply-staging = {
    website_name   = "Apply-Teacher-Training-Staging"
    website_url    = "https://staging.apply-for-teacher-training.service.gov.uk/integrations/monitoring/all"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [188603]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-staging-check = {
    website_name   = "Apply-Teacher-Training-Check-Staging"
    website_url    = "https://staging.apply-for-teacher-training.service.gov.uk/check"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [188603]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 2
  }
  apply-cloudapps-qa = {
    website_name   = "Apply-Teacher-Training-Cloudapps-Staging"
    website_url    = "https://apply-staging.london.cloudapps.digital/check"
    test_type      = "HTTP"
    check_rate     = 30
    contact_group  = [188603]
    trigger_rate   = 0
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
    confirmations  = 1
  }
}
