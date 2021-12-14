variable app_name_suffix { default = null }

# PaaS variables
variable "paas_sso_code" { default = "" }

variable "paas_cf_space" {}

variable "paas_app_environment" {}

variable "paas_docker_image" {}

variable "paas_web_app_memory" {}

variable "paas_web_app_instances" {}

variable "paas_postgres_service_plan" {}

variable "paas_worker_redis_service_plan" {}

variable "paas_cache_redis_service_plan" {}

variable "paas_clock_app_memory" { default = 512 }

variable "paas_worker_app_memory" { default = 512 }

variable "paas_clock_app_instances" { default = 1 }

variable "paas_worker_app_instances" { default = 1 }

variable "paas_worker_secondary_app_instances" { default = 1 }

variable "prometheus_app" { default = null }

# Key Vault variables
variable "azure_credentials" { default = null }

variable "key_vault_name" {}

variable "key_vault_resource_group" {}

variable "key_vault_infra_secret_name" {}

variable "key_vault_app_secret_name" {}

# StatusCake variables
variable "statuscake_alerts" {
  type    = map(any)
  default = {}
}

# Restore DB variables
variable "paas_restore_db_from_db_instance" { default = "" }

variable "paas_restore_db_from_point_in_time_before" { default = "" }

locals {
  app_name_suffix = var.app_name_suffix != null ? var.app_name_suffix : var.paas_app_environment

  cf_api_url        = "https://api.london.cloud.service.gov.uk"
  azure_credentials = try(jsondecode(var.azure_credentials), null)
  app_secrets       = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets     = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)

  app_env_values  = try(yamldecode(file("${path.module}/workspace-variables/${var.paas_app_environment}_app_env.yml")), {})

  custom_domain = { "CUSTOM_HOSTNAME" = "apply-${local.app_name_suffix}.london.cloudapps.digital" }
  authorized_hosts = { "AUTHORISED_HOSTS" = "apply-${local.app_name_suffix}.london.cloudapps.digital" }

  paas_app_environment_variables = merge(
    local.custom_domain,
    local.authorized_hosts,
    local.app_secrets, # Values in app secrets can override anything before it
    local.app_env_values # Utilimately app_env_values can override anything in the merged map
  )

  docker_credentials = {
    username = local.infra_secrets.GHCR_USERNAME
    password = local.infra_secrets.GHCR_PASSWORD
  }
}
