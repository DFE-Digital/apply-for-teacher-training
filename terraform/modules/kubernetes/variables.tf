variable "app_environment" {}
variable "azure_region_name" {
  default = "uksouth"
}
variable "namespace" {}
variable "app_docker_image" {}
variable "app_environment_variables" {}
variable "app_secrets" {}
variable "cluster" {}
variable "deploy_azure_backing_services" {}
variable "webapp_startup_command" {}
variable "azure_resource_prefix" {}
variable "postgres_version" {}
variable "postgres_admin_password" { sensitive = true }
variable "postgres_admin_username" {}
variable "postgres_enable_high_availability" {
  default = false
}
variable "postgres_flexible_server_sku" {
  type    = string
  default = "B_Standard_B1ms"
}
variable "postgres_snapshot_flexible_server_sku" {
  type    = string
  default = "B_Standard_B1ms"
}
variable "postgres_flexible_server_storage_mb" {
  type    = number
  default = 32768
}

variable "redis_cache_capacity" {
  type    = number
  default = 1
}

variable "redis_cache_family" {
  type    = string
  default = "C"
}

variable "redis_cache_sku_name" {
  type    = string
  default = "Standard"
}

variable "redis_queue_capacity" {
  type    = number
  default = 1
}

variable "redis_queue_family" {
  type    = string
  default = "C"
}

variable "redis_queue_sku_name" {
  type    = string
  default = "Standard"
}

variable "redis_minimum_tls_version" {
  type    = string
  default = "1.2"
}

variable "redis_server_version" {
  type    = string
  default = "6"
}

variable "redis_public_network_access_enabled" {
  type    = bool
  default = false
}

variable "app_resource_group_name" {}

variable "webapp_memory_max" {}
variable "worker_memory_max" {}
variable "secondary_worker_memory_max" {}
variable "clock_worker_memory_max" {}
variable "webapp_replicas" {}
variable "worker_replicas" {}
variable "secondary_worker_replicas" {}
variable "clock_worker_replicas" {}

variable "gov_uk_host_names" {
  default = []
  type    = list(any)
}

# Variables for Azure alerts
variable "enable_alerting" {}
variable "pg_actiongroup_name" {}
variable "pg_actiongroup_rg" {}
variable "pg_memory_threshold" {
  default = 75
}
variable "pg_cpu_threshold" {
  default = 60
}
variable "pg_storage_threshold" {
  default = 75
}
variable "redis_memory_threshold" {
  default = 60
}
variable "pdb_min_available" {
  type    = string
  default = null
}

variable "config_short" {}
variable "service_short" {}
variable "deploy_snapshot_database" { default = false }
variable "azure_maintenance_window" {}

locals {
  app_config_name                      = "apply-config-${var.app_environment}"
  app_secrets_name                     = "apply-secrets-${var.app_environment}"
  backing_services_resource_group_name = "${var.cluster.cluster_resource_prefix}-bs-rg"
  database_host                        = var.deploy_azure_backing_services ? azurerm_postgresql_flexible_server.postgres-server[0].fqdn : local.postgres_service_name
  database_url                         = "postgres://postgres:${var.postgres_admin_password}@${local.database_host}:5432/${local.postgres_service_name}"
  hostname                             = var.cluster.dns_zone_prefix != null ? "${local.webapp_name}.${var.cluster.dns_zone_prefix}.teacherservices.cloud" : "${local.webapp_name}.teacherservices.cloud"
  postgres_dns_zone                    = var.cluster.dns_zone_prefix != null ? "${var.cluster.dns_zone_prefix}.internal.postgres.database.azure.com" : "production.internal.postgres.database.azure.com"
  postgres_server_name                 = "${var.azure_resource_prefix}-${var.service_short}-${var.app_environment}-psql"
  postgres_service_name                = "apply-postgres-${var.app_environment}"
  postgres_snapshot_server_name        = "${var.azure_resource_prefix}-${var.service_short}-${var.app_environment}-snapshot-psql"
  postgres_snapshot_service_name       = "apply-postgres-${var.app_environment}-snapshot"
  redis_dns_zone                       = "privatelink.redis.cache.windows.net"
  redis_cache_name                     = "${var.azure_resource_prefix}-${var.service_short}-${var.app_environment}-redis-cache"
  redis_cache_private_endpoint_name    = "${var.azure_resource_prefix}-${var.service_short}-${var.app_environment}-redis-cache-pe"
  redis_queue_name                     = "${var.azure_resource_prefix}-${var.service_short}-${var.app_environment}-redis-queue"
  redis_queue_private_endpoint_name    = "${var.azure_resource_prefix}-${var.service_short}-${var.app_environment}-redis-queue-pe"
  redis_service_name                   = "apply-redis-${var.app_environment}"
  redis_container_url                  = "redis://${local.redis_service_name}:6379/0"
  redis_queue_azure_url = (var.deploy_azure_backing_services ?
    "rediss://:${azurerm_redis_cache.redis-queue[0].primary_access_key}@${azurerm_redis_cache.redis-queue[0].hostname}:${azurerm_redis_cache.redis-queue[0].ssl_port}/0" :
    local.redis_container_url
  )
  redis_cache_azure_url = (var.deploy_azure_backing_services ?
    "rediss://:${azurerm_redis_cache.redis-cache[0].primary_access_key}@${azurerm_redis_cache.redis-cache[0].hostname}:${azurerm_redis_cache.redis-cache[0].ssl_port}/0" :
    local.redis_container_url
  )
  secondary_worker_name  = "apply-secondary-worker-${var.app_environment}"
  webapp_startup_command = var.webapp_startup_command == null ? null : ["/bin/sh", "-c", var.webapp_startup_command]
  webapp_name            = "apply-${var.app_environment}"
  worker_name            = "apply-worker-${var.app_environment}"
  clock_worker_name      = "apply-clock-worker-${var.app_environment}"
  vnet_name              = "${var.cluster.cluster_resource_prefix}-vnet"

  webapp_env_variables = merge(
    var.app_environment_variables,
    {
      SERVICE_TYPE = "web"
    }
  )
  # Create a unique name based on the values to force recreation when they change
  webapp_env_variables_hash = sha1(join("-", [for k, v in local.webapp_env_variables : "${k}:${v}"]))

  app_secrets = merge(
    var.app_secrets,
    {
      DATABASE_URL        = local.database_url
      BLAZER_DATABASE_URL = local.database_url
      REDIS_URL           = local.redis_queue_azure_url
      REDIS_CACHE_URL     = local.redis_cache_azure_url
    }
  )
  # Create a unique name based on the values to force recreation when they change
  app_secrets_hash = sha1(join("-", [for k, v in local.app_secrets : "${k}:${v}" if v != null]))

}
