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
variable "resource_prefix" {}
variable "postgres_admin_password" { sensitive = true }
variable "postgres_admin_username" {}
variable "postgres_enable_high_availability" {
  default = false
}
variable "postgres_flexible_server_sku" {
  type    = string
  default = "B_Standard_B1ms"
}
variable "postgres_flexible_server_storage_mb" {
  type    = number
  default = 32768
}

variable "redis_capacity" {
  type    = number
  default = 1
}

variable "redis_family" {
  type    = string
  default = "C"
}

variable "redis_sku_name" {
  type    = string
  default = "Standard"
}

variable "redis_enable_non_ssl_port" {
  type    = bool
  default = true
}

variable "redis_minimum_tls_version" {
  type    = string
  default = "1.2"
}

variable "redis_public_network_access_enabled" {
  type    = bool
  default = false
}

variable "resource_group_name" {}

locals {
  app_config_name                      = "apply-config-${var.app_environment}"
  app_resource_group_name              = "${var.resource_prefix}-${var.app_environment}-rg"
  app_secrets_name                     = "apply-secrets-${var.app_environment}"
  backing_services_resource_group_name = "${var.cluster.cluster_resource_prefix}-bs-rg"
  database_host                        = var.deploy_azure_backing_services ? azurerm_postgresql_flexible_server.postgres-server[0].fqdn : local.postgres_service_name
  database_url                         = "postgres://postgres:${var.postgres_admin_password}@${local.database_host}:5432/${local.postgres_service_name}"
  hostname                             = var.cluster.dns_zone_prefix != null ? "${local.webapp_name}.${var.cluster.dns_zone_prefix}.teacherservices.cloud" : "${local.webapp_name}.teacherservices.cloud"
  postgres_dns_zone                    = var.cluster.dns_zone_prefix != null ? "${var.cluster.dns_zone_prefix}.internal.postgres.database.azure.com" : "internal.postgres.database.azure.com"
  postgres_server_name                 = "${var.resource_prefix}-${var.app_environment}-psql"
  postgres_service_name                = "apply-postgres-${var.app_environment}"
  redis_dns_zone                       = "privatelink.redis.cache.windows.net"
  redis_cache_name                     = "${var.resource_prefix}-${var.app_environment}-redis-cache"
  redis_cache_private_endpoint_name    = "${var.resource_prefix}-${var.app_environment}-redis-cache-pe"
  redis_queue_name                     = "${var.resource_prefix}-${var.app_environment}-redis-queue"
  redis_queue_private_endpoint_name    = "${var.resource_prefix}-${var.app_environment}-redis-queue-pe"
  redis_service_name                   = "apply-redis-${var.app_environment}"
  secondary_worker_name                = "apply-secondary-worker-${var.app_environment}"
  webapp_startup_command               = var.webapp_startup_command == null ? null : ["/bin/sh", "-c", var.webapp_startup_command]
  webapp_name                          = "apply-${var.app_environment}"
  worker_name                          = "apply-worker-${var.app_environment}"
  clock_worker_name                    = "apply-clock-worker-${var.app_environment}"
  vnet_name                            = "${var.cluster.cluster_resource_prefix}-vnet"

  webapp_env_variables = merge(
    var.app_environment_variables,
    {
      SERVICE_TYPE     = "web"
      CUSTOM_HOSTNAME  = local.hostname
      AUTHORISED_HOSTS = local.hostname
    }
  )
  # Create a unique name based on the values to force recreation when they change
  webapp_env_variables_hash = sha1(join("-", [for k, v in local.webapp_env_variables : "${k}:${v}"]))

  app_secrets = merge(
    var.app_secrets,
    {
      DATABASE_URL        = local.database_url
      BLAZER_DATABASE_URL = local.database_url
      REDIS_URL           = "redis://:${azurerm_redis_cache.redis-queue[0].primary_access_key}@${azurerm_redis_cache.redis-queue[0].hostname}:${azurerm_redis_cache.redis-queue[0].port}/0"
      REDIS_CACHE_URL     = "redis://:${azurerm_redis_cache.redis-cache[0].primary_access_key}@${azurerm_redis_cache.redis-cache[0].hostname}:${azurerm_redis_cache.redis-cache[0].port}/0"
    }
  )
  # Create a unique name based on the values to force recreation when they change
  app_secrets_hash = sha1(join("-", [for k, v in local.app_secrets : "${k}:${v}" if v != null]))
}
