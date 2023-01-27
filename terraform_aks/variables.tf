variable "app_name_suffix" { default = null }

# PaaS variables
variable "paas_sso_code" { default = "" }

variable "paas_cf_space" {}

variable "paas_app_environment" {}

variable "paas_docker_image" {}

variable "paas_web_app_memory" {}

variable "paas_web_app_instances" {}

variable "paas_postgres_service_plan" {}

variable "paas_postgres_snapshot_service_plan" { default = "small-11" }

variable "paas_snapshot_databases_to_deploy" { default = 0 }

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

variable "service_gov_uk_host_names" {
  default = []
  type    = list(any)
}

variable "assets_host_names" {
  default = []
  type    = list(any)
}

# StatusCake variables
variable "statuscake_alerts" {
  type    = map(any)
  default = {}
}

variable "api_token" { default = "" }

# Restore DB variables
variable "paas_restore_db_from_db_instance" { default = "" }

variable "paas_restore_db_from_point_in_time_before" { default = "" }

variable "paas_enable_external_logging" { default = true }

# Kubernetes variables
variable "namespace" { default = "" }

variable "cluster" { default = "" }

variable "deploy_aks" {
  type    = bool
  default = false
}

variable "db_sslmode" { default = "require" }

variable "webapp_startup_command" { default = null }

locals {
  app_name_suffix = var.app_name_suffix != null ? var.app_name_suffix : var.paas_app_environment

  cf_api_url        = "https://api.london.cloud.service.gov.uk"
  azure_credentials = try(jsondecode(var.azure_credentials), null)
  app_secrets       = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets     = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)

  app_env_values_from_yaml = try(yamldecode(file("${path.module}/workspace-variables/${var.paas_app_environment}_app_env.yml")), {})

  app_env_values = merge(
    local.app_env_values_from_yaml,
    { DB_SSLMODE = var.db_sslmode }
  )

  custom_domain    = { "CUSTOM_HOSTNAME" = "apply-${local.app_name_suffix}.london.cloudapps.digital" }
  authorized_hosts = { "AUTHORISED_HOSTS" = "apply-${local.app_name_suffix}.london.cloudapps.digital" }

  paas_app_environment_variables = merge(
    local.custom_domain,
    local.authorized_hosts,
    local.app_secrets,   # Values in app secrets can override anything before it
    local.app_env_values # Utilimately app_env_values can override anything in the merged map
  )
  cluster = {
    cluster1 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_name                = "s189d01-tsc-cluster1-aks"
      dns_suffix                  = "cluster1.development.teacherservices.cloud"
    }
    test = {
      cluster_resource_group_name = "s189t01-tsc-ts-rg"
      cluster_name                = "s189t01-tsc-test-aks"
      dns_suffix                  = "test.teacherservices.cloud"
    }
    production = {
      cluster_resource_group_name = "s189p01-tsc-ps-rg"
      cluster_name                = "s189p01-tsc-production-aks"
      dns_suffix                  = "teacherservices.cloud"
    }
  }
}
