variable "cluster_resource_group_name" {}
variable "cluster_name" {}
variable "app_environment" {}
variable "namespace" {}
variable "app_docker_image" {}
variable "app_environment_variables" {}
variable "app_secrets" {}

locals {
  webapp_name           = "apply-${var.app_environment}"
  app_secrets_name       = "apply-secrets-${var.app_environment}"
  app_config_name        = "apply-config-${var.app_environment}"
  postgres_service_name = "apply-postgres-${var.app_environment}"
  redis_service_name = "apply-redis-${var.app_environment}"

  hostname = "${local.webapp_name}.paas.teaching-identity.education.gov.uk"
  web_app_env_variables = merge(
    var.app_environment_variables,
    {
      SERVICE_TYPE = "web"
      CUSTOM_HOSTNAME     = local.hostname
      AUTHORISED_HOSTS    = local.hostname
    }
  )
  web_app_env_variables_hash = sha1(join("-", [for k, v in local.web_app_env_variables : "${k}:${v}"]))

  database_url = "postgres://postgres:password@${local.postgres_service_name}:5432/${local.postgres_service_name}"
  redis_url="redis://${local.redis_service_name}:6379/0"

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
