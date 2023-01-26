module "paas" {
  count  = var.deploy_aks ? 0 : 1
  source = "./modules/paas"

  cf_space                             = var.paas_cf_space
  prometheus_app                       = var.prometheus_app
  web_app_instances                    = var.paas_web_app_instances
  web_app_memory                       = var.paas_web_app_memory
  app_docker_image                     = var.paas_docker_image
  app_environment                      = local.app_name_suffix
  app_environment_variables            = local.paas_app_environment_variables
  logstash_url                         = local.infra_secrets.LOGSTASH_URL
  postgres_service_plan                = var.paas_postgres_service_plan
  postgres_snapshot_service_plan       = var.paas_postgres_snapshot_service_plan
  snapshot_databases_to_deploy         = var.paas_snapshot_databases_to_deploy
  worker_redis_service_plan            = var.paas_worker_redis_service_plan
  cache_redis_service_plan             = var.paas_cache_redis_service_plan
  clock_app_memory                     = var.paas_clock_app_memory
  worker_app_memory                    = var.paas_worker_app_memory
  clock_app_instances                  = var.paas_clock_app_instances
  worker_app_instances                 = var.paas_worker_app_instances
  worker_secondary_app_instances       = var.paas_worker_secondary_app_instances
  service_gov_uk_host_names            = var.service_gov_uk_host_names
  assets_host_names                    = var.assets_host_names
  enable_external_logging              = var.paas_enable_external_logging
  restore_db_from_db_instance          = var.paas_restore_db_from_db_instance
  restore_db_from_point_in_time_before = var.paas_restore_db_from_point_in_time_before
}

module "kubernetes" {
  count  = var.deploy_aks ? 1 : 0
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
