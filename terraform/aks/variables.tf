variable "app_name_suffix" { default = null }

# PaaS variables
variable "paas_sso_code" { default = "" }

variable "paas_app_environment" {}

variable "paas_docker_image" {}

variable "paas_postgres_snapshot_service_plan" { default = "small-11" }

variable "paas_snapshot_databases_to_deploy" { default = 0 }

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

variable "postgres_version" { default = "11" }

variable "gov_uk_host_names" {
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

variable "deploy_azure_backing_services" { default = true }

variable "db_sslmode" { default = "require" }

variable "webapp_startup_command" { default = null }

variable "azure_resource_prefix" {}

variable "app_resource_group_name" { default = null }

variable "enable_alerting" { default = false }
variable "pg_actiongroup_name" { default = false }
variable "pg_actiongroup_rg" { default = false }

variable "webapp_memory_max" { default = "1Gi" }
variable "worker_memory_max" { default = "1Gi" }
variable "secondary_worker_memory_max" { default = "1Gi" }
variable "clock_worker_memory_max" { default = "1Gi" }
variable "webapp_replicas" { default = 1 }
variable "worker_replicas" { default = 1 }
variable "secondary_worker_replicas" { default = 1 }
variable "clock_worker_replicas" { default = 1 }
variable "postgres_flexible_server_sku" { default = "B_Standard_B1ms" }
variable "postgres_flexible_server_storage_mb" { default = 32768 }
variable "postgres_enable_high_availability" { default = false }
variable "redis_capacity" { default = 1 }
variable "redis_family" { default = "C" }
variable "redis_sku_name" { default = "Standard" }
variable "pdb_min_available" { default = null }

locals {
  app_name_suffix = var.app_name_suffix != null ? var.app_name_suffix : var.paas_app_environment

  cf_api_url        = "https://api.london.cloud.service.gov.uk"
  azure_credentials = try(jsondecode(var.azure_credentials), null)
  app_secrets       = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets     = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)

  app_env_values_from_yaml = try(yamldecode(file("${path.module}/workspace-variables/${var.paas_app_environment}_app_env.yml")), {})

  review_url_vars = {
    "CUSTOM_HOSTNAME"  = "apply-${local.app_name_suffix}.test.teacherservices.cloud"
    "AUTHORISED_HOSTS" = "apply-${local.app_name_suffix}.test.teacherservices.cloud"
  }

  app_env_values = merge(
    local.app_env_values_from_yaml,
    var.app_name_suffix != null ? local.review_url_vars : {},
    { DB_SSLMODE = var.db_sslmode }
  )

  cluster = {
    cluster1 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster1"
      dns_zone_prefix             = "cluster1.development"
      cpu_min                     = 0.1
    }
    cluster2 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster2"
      dns_zone_prefix             = "cluster2.development"
      cpu_min                     = 0.1
    }
    cluster3 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster3"
      dns_zone_prefix             = "cluster3.development"
      cpu_min                     = 0.1
    }
    cluster4 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster4"
      dns_zone_prefix             = "cluster4.development"
      cpu_min                     = 0.1
    }
    cluster5 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster5"
      dns_zone_prefix             = "cluster5.development"
      cpu_min                     = 0.1
    }
    cluster6 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_resource_prefix     = "s189d01-tsc-cluster6"
      dns_zone_prefix             = "cluster6.development"
      cpu_min                     = 0.1
    }
    test = {
      cluster_resource_group_name = "s189t01-tsc-ts-rg"
      cluster_resource_prefix     = "s189t01-tsc-test"
      dns_zone_prefix             = "test"
      cpu_min                     = 0.1
    }
    platform-test = {
      cluster_resource_group_name = "s189t01-tsc-pt-rg"
      cluster_resource_prefix     = "s189t01-tsc-platform-test"
      dns_zone_prefix             = "platform-test"
      cpu_min                     = 0.1
    }
    production = {
      cluster_resource_group_name = "s189p01-tsc-pd-rg"
      cluster_resource_prefix     = "s189p01-tsc-production"
      dns_zone_prefix             = null
      cpu_min                     = 1
    }
  }
  cluster_name = "${local.cluster[var.cluster].cluster_resource_prefix}-aks"
}
