variable "app_environment" {}
variable "namespace" {}
variable "app_docker_image" {}
variable "app_environment_variables" {}
variable "app_secrets" {}
variable "cluster" {}

locals {
  cluster = {
    psp = {
      cluster_resource_group_name = "b901d01rg-tsc-poc"
      cluster_name                = "b901d01aks-tsc-psp-poc"
      dns_suffix                  = "psppaas.teaching-identity.education.gov.uk"
    }
    cluster1 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_name                = "s189d01-tsc-cluster1-aks"
      dns_suffix                  = "cluster1.development.teacherservices.cloud"
    }
    cluster2 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_name                = "s189d01-tsc-cluster2-aks"
      dns_suffix                  = "cluster2.teaching-identity.education.gov.uk"
    }
    cluster3 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_name                = "s189d01-tsc-cluster3-aks"
      dns_suffix                  = "cluster3.teaching-identity.education.gov.uk"
    }
    cluster4 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_name                = "s189d01-tsc-cluster4-aks"
      dns_suffix                  = "cluster4.teaching-identity.education.gov.uk"
    }
    cluster5 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_name                = "s189d01-tsc-cluster5-aks"
      dns_suffix                  = "cluster5.teaching-identity.education.gov.uk"
    }
    cluster6 = {
      cluster_resource_group_name = "s189d01-tsc-dv-rg"
      cluster_name                = "s189d01-tsc-cluster6-aks"
      dns_suffix                  = "cluster6.teaching-identity.education.gov.uk"
    }
  }
  webapp_name           = "apply-${var.app_environment}"
  worker_name           = "apply-worker-${var.app_environment}"
  secondary_worker_name           = "apply-secondary-worker-${var.app_environment}"
  app_secrets_name       = "apply-secrets-${var.app_environment}"
  app_config_name        = "apply-config-${var.app_environment}"
  postgres_service_name = "apply-postgres-${var.app_environment}"
  redis_service_name = "apply-redis-${var.app_environment}"

  hostname = "${local.webapp_name}.${local.cluster[var.cluster].dns_suffix}"
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
