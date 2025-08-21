variable "app_name_suffix" { default = null }

# PaaS variables
variable "app_environment" {}

variable "docker_image" {}

# Key Vault variables
variable "key_vault_name" {}

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

variable "send_traffic_to_maintenance_page" {
  default     = false
  description = "During a maintenance operation, keep sending traffic to the maintenance page instead of resetting the ingress"
}

variable "create_storage_account" {
  description = "Flag to create storage account for data_exports"
  type        = bool
  default     = false
}

variable "data_exports_storage_account_name" {
  type    = string
  default = null
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "exp_storage_account_name" {
  type    = string
  default = null
}

variable "enable_prometheus_monitoring" {
  type    = bool
  default = false
}

variable "enable_logit" { default = false }

locals {
  app_name_suffix = var.app_name_suffix != null ? var.app_name_suffix : var.app_environment

  exp_storage_account_name = var.exp_storage_account_name != null ? var.exp_storage_account_name : var.data_exports_storage_account_name

  app_env_values_from_yaml = try(yamldecode(file("${path.module}/workspace-variables/${var.app_environment}_app_env.yml")), {})

  review_url_vars = var.app_name_suffix != null ? {
    "CUSTOM_HOSTNAME"  = "apply-${local.app_name_suffix}.${module.cluster_data.ingress_domain}"
    "AUTHORISED_HOSTS" = "apply-${local.app_name_suffix}.${module.cluster_data.ingress_domain}"
  } : {}

  app_env_values = merge(
    local.app_env_values_from_yaml,
    var.app_name_suffix != null ? local.review_url_vars : {},
    { DB_SSLMODE = var.db_sslmode }
  )

  app_resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"

  webapp_startup_command = var.webapp_startup_command == null ? null : ["/bin/sh", "-c", var.webapp_startup_command]

  azure_storage_account_name = var.create_storage_account ? azurerm_storage_account.data_exports_sa[0].name : ""
  azure_storage_access_key   = var.create_storage_account ? azurerm_storage_account.data_exports_sa[0].primary_access_key : ""
  azure_storage_container    = var.create_storage_account ? azurerm_storage_container.data_exports_container[0].name : ""
}
