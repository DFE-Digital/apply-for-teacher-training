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

  cf_api_url                = local.cf_api_url
  cf_user                   = local.infra_secrets.CF_USER
  cf_user_password          = local.infra_secrets.CF_PASSWORD
  cf_sso_passcode           = var.paas_sso_code
  cf_space                  = var.paas_cf_space
  docker_credentials        = local.docker_credentials
  web_app_instances         = var.paas_web_app_instances
  web_app_memory            = var.paas_web_app_memory
  app_docker_image          = var.paas_docker_image
  app_environment           = var.paas_app_environment
  app_environment_variables = local.paas_app_environment_variables
  logstash_url              = local.infra_secrets.LOGSTASH_URL
  postgres_service_plan     = var.paas_postgres_service_plan
  redis_service_plan        = var.paas_redis_service_plan
  clock_app_memory          = var.paas_clock_app_memory
  worker_app_memory         = var.paas_worker_app_memory
  clock_app_instances       = var.paas_clock_app_instances
  worker_app_instances      = var.paas_worker_app_instances
}

module "statuscake" {
  source = "./modules/statuscake"

  username = local.infra_secrets.STATUSCAKE_USERNAME
  password = local.infra_secrets.STATUSCAKE_PASSWORD
  alerts   = var.statuscake_alerts
}
