module "kubernetes" {
  source = "./modules/kubernetes"

  app_docker_image          = var.paas_docker_image
  app_environment           = local.app_name_suffix
  app_environment_variables = local.app_env_values
  app_secrets               = local.app_secrets
  cluster                   = local.cluster[var.cluster]
  namespace                 = var.namespace
  webapp_startup_command    = var.webapp_startup_command
}

module "statuscake" {
  source = "./modules/statuscake"

  api_token = local.infra_secrets.STATUSCAKE_PASSWORD
  alerts    = var.statuscake_alerts
}
