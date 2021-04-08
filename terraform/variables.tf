# PaaS variables
variable "paas_sso_code" { default = null }

variable "paas_cf_space" {}

variable "paas_app_environment" {}

variable "paas_docker_image" {}

variable "paas_web_app_memory" {}

variable "paas_web_app_instances" {}

variable "paas_postgres_service_plan" {}

variable "paas_redis_service_plan" {}

variable "paas_clock_app_memory" { default = 512 }

variable "paas_worker_app_memory" { default = 512 }

variable "paas_clock_app_instances" { default = 1 }

variable "paas_worker_app_instances" { default = 1 }

# Key Vault variables
variable "azure_credentials" { default = null }

variable "key_vault_name" {}

variable "key_vault_resource_group" {}

variable "key_vault_infra_secret_name" {}

variable "key_vault_app_secret_name" {}

locals {
  cf_api_url        = "https://api.london.cloud.service.gov.uk"
  azure_credentials = try(jsondecode(var.azure_credentials), null)
  app_secrets       = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets     = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)

  paas_app_environment_variables = local.app_secrets

  docker_credentials = {
    username = local.infra_secrets.GHCR_USERNAME
    password = local.infra_secrets.GHCR_PASSWORD
  }
}
