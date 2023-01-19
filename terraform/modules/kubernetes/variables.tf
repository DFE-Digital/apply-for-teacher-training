variable "app_environment" {}
variable "namespace" {}
variable "app_docker_image" {}
variable "app_environment_variables" {}
variable "app_secrets" {}
variable "cluster" {}

locals {
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
      dns_suffix                  = "production.teacherservices.cloud"
    }
  }
  webapp_name           = "apply-${var.app_environment}"
  worker_name           = "apply-worker-${var.app_environment}"
  secondary_worker_name = "apply-secondary-worker-${var.app_environment}"
  app_secrets_name      = "apply-secrets-${var.app_environment}"
  app_config_name       = "apply-config-${var.app_environment}"
  postgres_service_name = "apply-postgres-${var.app_environment}"
  redis_service_name    = "apply-redis-${var.app_environment}"

  hostname = "${local.webapp_name}.${local.cluster[var.cluster].dns_suffix}"
  web_app_env_variables = merge(
    var.app_environment_variables,
    {
      SERVICE_TYPE     = "web"
      CUSTOM_HOSTNAME  = local.hostname
      AUTHORISED_HOSTS = local.hostname
    }
  )
  web_app_env_variables_hash = sha1(join("-", [for k, v in local.web_app_env_variables : "${k}:${v}"]))

  database_url = "postgres://postgres:password@${local.postgres_service_name}:5432/${local.postgres_service_name}"
  redis_url    = "redis://${local.redis_service_name}:6379/0"

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
