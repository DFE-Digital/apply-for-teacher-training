variable "app_environment" {}

variable "namespace" {}
variable "app_docker_image" {}
variable "app_environment_variables" {}
variable "app_secrets" {}
variable "cluster" {}
variable "webapp_startup_command" {}

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

variable "pdb_min_available" {
  type    = string
  default = null
}

variable "database_username" {}
variable "database_password" {}
variable "database_host" {}
variable "database_port" {}

variable "redis_cache_url" {}
variable "redis_queue_url" {}

locals {
  app_config_name                      = "apply-config-${var.app_environment}"
  app_secrets_name                     = "apply-secrets-${var.app_environment}"
  database_url                         = "postgres://${var.database_username}:${var.database_password}@${var.database_host}:${var.database_port}/${local.postgres_service_name}"
  hostname                             = var.cluster.dns_zone_prefix != null ? "${local.webapp_name}.${var.cluster.dns_zone_prefix}.teacherservices.cloud" : "${local.webapp_name}.teacherservices.cloud"
  # We don't use the att_<env> database created by the postgres module as the app connects to the
  # existing one with the local.postgres_service_name name
  postgres_service_name                = "apply-postgres-${var.app_environment}"
  secondary_worker_name                = "apply-secondary-worker-${var.app_environment}"
  webapp_startup_command               = var.webapp_startup_command == null ? null : ["/bin/sh", "-c", var.webapp_startup_command]
  webapp_name                          = "apply-${var.app_environment}"
  worker_name                          = "apply-worker-${var.app_environment}"
  clock_worker_name                    = "apply-clock-worker-${var.app_environment}"

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
      REDIS_URL           = var.redis_queue_url
      REDIS_CACHE_URL     = var.redis_cache_url
    }
  )
  # Create a unique name based on the values to force recreation when they change
  app_secrets_hash = sha1(join("-", [for k, v in local.app_secrets : "${k}:${v}" if v != null]))
}
