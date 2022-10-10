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

  web_app_env_variables = merge(var.app_environment_variables, { SERVICE_TYPE = "web" })
  database_url = "postgres://postgres:password@${local.postgres_service_name}:5432/${local.postgres_service_name}"
  app_secrets = merge(
    var.app_secrets,
    {
      DATABASE_URL        = local.database_url
      BLAZER_DATABASE_URL = local.database_url
    }
  )
}
