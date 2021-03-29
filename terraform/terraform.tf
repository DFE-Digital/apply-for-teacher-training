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
  subscription_id            = local.azure_credentials.subscriptionId
  client_id                  = local.azure_credentials.clientId
  client_secret              = local.azure_credentials.clientSecret
  tenant_id                  = local.azure_credentials.tenantId
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
  postgres_service_plan     = var.paas_postgres_service_plan
  redis_service_plan        = var.paas_redis_service_plan
}
