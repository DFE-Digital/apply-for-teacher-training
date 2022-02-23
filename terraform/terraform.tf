terraform {
  required_version = "~> 0.14.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.53.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.13.0"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "1.0.1"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
}

module "paas" {
  source = "./modules/paas"

  cf_api_url                     = local.cf_api_url
  cf_user                        = var.paas_sso_code == "" ? local.infra_secrets.CF_USER : null
  cf_user_password               = var.paas_sso_code == "" ? local.infra_secrets.CF_PASSWORD : null
  cf_sso_passcode                = var.paas_sso_code
  cf_space                       = var.paas_cf_space
  prometheus_app                 = var.prometheus_app
  web_app_instances              = var.paas_web_app_instances
  web_app_memory                 = var.paas_web_app_memory
  app_docker_image               = var.paas_docker_image
  app_environment                = local.app_name_suffix
  app_environment_variables      = local.paas_app_environment_variables
  logstash_url                   = local.infra_secrets.LOGSTASH_URL
  postgres_service_plan          = var.paas_postgres_service_plan
  postgres_snapshot_service_plan = var.paas_postgres_snapshot_service_plan
  snapshot_databases_to_deploy   = var.paas_snapshot_databases_to_deploy
  worker_redis_service_plan      = var.paas_worker_redis_service_plan
  cache_redis_service_plan       = var.paas_cache_redis_service_plan
  clock_app_memory               = var.paas_clock_app_memory
  worker_app_memory              = var.paas_worker_app_memory
  clock_app_instances            = var.paas_clock_app_instances
  worker_app_instances           = var.paas_worker_app_instances
  worker_secondary_app_instances = var.paas_worker_secondary_app_instances
  service_gov_uk_host_names      = var.service_gov_uk_host_names
  assets_host_names              = var.assets_host_names

  restore_db_from_db_instance          = var.paas_restore_db_from_db_instance
  restore_db_from_point_in_time_before = var.paas_restore_db_from_point_in_time_before
}

module "statuscake" {
  source = "./modules/statuscake"

  username = local.infra_secrets.STATUSCAKE_USERNAME
  password = local.infra_secrets.STATUSCAKE_PASSWORD
  alerts   = var.statuscake_alerts
}
