variable "app_name_suffix" { default = null }

# PaaS variables
variable "paas_app_environment" {}

variable "paas_docker_image" {}

# Key Vault variables
variable "key_vault_name" {}
variable "key_vault_infra_secret_name" {}
variable "key_vault_app_secret_name" {}

variable "gov_uk_host_names" {
  default = []
  type    = list(any)
}

# StatusCake variables
variable "statuscake_alerts" {
  type    = map(any)
  default = {}
}

# Kubernetes variables
variable "namespace" { default = "" }

variable "cluster" { default = "" }

variable "deploy_azure_backing_services" { default = true }

variable "db_sslmode" { default = "require" }

variable "webapp_startup_command" { default = null }

variable "azure_resource_prefix" {}

variable "enable_alerting" { default = false }
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
variable "redis_cache_capacity" { default = 1 }
variable "redis_cache_family" { default = "C" }
variable "redis_cache_sku_name" { default = "Standard" }
variable "redis_queue_capacity" { default = 1 }
variable "redis_queue_family" { default = "C" }
variable "redis_queue_sku_name" { default = "Standard" }
variable "pdb_min_available" { default = null }
variable "config_short" {}
variable "service_short" {}
variable "azure_maintenance_window" { default = null }

# NEW
variable "service_name" {}
variable "redis_server_version" {
  type    = string
  default = "6"
}

variable "alert_window_size" {
  type        = string
  nullable    = false
  default     = "PT5M"
  description = "The period of time that is used to monitor alert activity e.g PT1M, PT5M, PT15M, PT30M, PT1H, PT6H or PT12H"
}

locals {
  app_name_suffix = var.app_name_suffix != null ? var.app_name_suffix : var.paas_app_environment

  app_secrets       = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets     = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)

  app_env_values_from_yaml = try(yamldecode(file("${path.module}/workspace-variables/${var.paas_app_environment}_app_env.yml")), {})

  review_url_vars = var.app_name_suffix != null ? {
    "CUSTOM_HOSTNAME"  = "apply-${local.app_name_suffix}.${local.cluster[var.cluster].dns_zone_prefix}.teacherservices.cloud"
    "AUTHORISED_HOSTS" = "apply-${local.app_name_suffix}.${local.cluster[var.cluster].dns_zone_prefix}.teacherservices.cloud"
  } : {}

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
      cpu_min                     = 0.8
    }
  }
  cluster_name = "${local.cluster[var.cluster].cluster_resource_prefix}-aks"
  app_resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"

  kubelogin_args_map = {
    spn = [
      "get-token",
      "--login",
      "spn",
      "--environment",
      "AzurePublicCloud",
      "--tenant-id",
      data.azurerm_client_config.current.tenant_id,
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630" # See https://azure.github.io/kubelogin/concepts/aks.html
    ],
    azurecli = [
      "get-token",
      "--login",
      "azurecli",
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630"
    ]
  }
  azure_RBAC_enabled = length(data.azurerm_kubernetes_cluster.main.azure_active_directory_role_based_access_control) > 0
  spn_authentication = contains(keys(data.environment_variables.github_actions.items), "GITHUB_ACTIONS")
  kubelogin_args = local.spn_authentication ? local.kubelogin_args_map["spn"] : local.kubelogin_args_map["azurecli"]
}
