module "kubernetes" {
  source = "../modules/kubernetes"

  app_docker_image              = var.paas_docker_image
  app_environment               = local.app_name_suffix
  app_environment_variables     = local.app_env_values
  app_secrets                   = local.app_secrets
  cluster                       = local.cluster[var.cluster]
  deploy_azure_backing_services = var.deploy_azure_backing_services
  namespace                     = var.namespace
  postgres_admin_password       = local.infra_secrets.POSTGRES_ADMIN_PASSWORD
  postgres_admin_username       = local.infra_secrets.POSTGRES_ADMIN_USERNAME
  resource_group_name           = var.app_resource_group_name
  resource_prefix               = var.azure_resource_prefix
  webapp_startup_command        = var.webapp_startup_command
}

module "statuscake" {
  source = "../modules/statuscake"

  api_token = local.infra_secrets.STATUSCAKE_PASSWORD
  alerts    = var.statuscake_alerts
}
