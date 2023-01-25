variable "app_environment" {}
variable "namespace" {}
variable "app_docker_image" {}
variable "app_environment_variables" {}
variable "app_secrets" {}
variable "cluster" {}
variable "webapp_startup_command" {}

locals {
  app_config_name        = "apply-config-${var.app_environment}"
  app_secrets_name       = "apply-secrets-${var.app_environment}"
  database_url           = "postgres://postgres:password@${local.postgres_service_name}:5432/${local.postgres_service_name}"
  hostname               = "${local.webapp_name}.${var.cluster.dns_suffix}"
  postgres_service_name  = "apply-postgres-${var.app_environment}"
  redis_service_name     = "apply-redis-${var.app_environment}"
  redis_url              = "redis://${local.redis_service_name}:6379/0"
  secondary_worker_name  = "apply-secondary-worker-${var.app_environment}"
  webapp_startup_command = var.webapp_startup_command == null ? null : ["/bin/sh", "-c", var.webapp_startup_command]
  webapp_name            = "apply-${var.app_environment}"
  worker_name            = "apply-worker-${var.app_environment}"

  webapp_env_variables = merge(
    var.app_environment_variables,
    {
      SERVICE_TYPE     = "web"
      CUSTOM_HOSTNAME  = local.hostname
      AUTHORISED_HOSTS = local.hostname
    }
  )
  webapp_env_variables_hash = sha1(join("-", [for k, v in local.webapp_env_variables : "${k}:${v}"]))

  app_secrets = merge(
    var.app_secrets,
    {
      DATABASE_URL        = local.database_url
      BLAZER_DATABASE_URL = local.database_url
      REDIS_URL           = local.redis_url
    }
  )
  app_secrets_hash = sha1(join("-", [for k, v in local.app_secrets : "${k}:${v}" if v != null]))
}
