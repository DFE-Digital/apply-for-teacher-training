module "application_configuration" {
  source = "./vendor/modules/aks//aks/application_configuration"

  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  config_variables = local.app_env_values

  secret_variables = {
    DATABASE_URL               = module.postgres.url
    BLAZER_DATABASE_URL        = module.postgres.url
    REDIS_URL                  = module.redis-queue.url
    REDIS_CACHE_URL            = module.redis-cache.url
    AZURE_STORAGE_ACCOUNT_NAME = local.azure_storage_account_name
    AZURE_STORAGE_ACCESS_KEY   = local.azure_storage_access_key
    AZURE_STORAGE_CONTAINER    = local.azure_storage_container
  }

  secret_yaml_key = var.key_vault_app_secret_name
}

module "web_application" {
  source = "./vendor/modules/aks//aks/application"


  namespace                  = var.namespace
  environment                = local.app_name_suffix
  service_name               = var.service_name
  is_web                     = true
  docker_image               = var.docker_image
  replicas                   = var.webapp_replicas
  max_memory                 = var.webapp_memory_max
  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name
  command                    = local.webapp_startup_command
  probe_path                 = "/check"
  web_external_hostnames     = var.gov_uk_host_names
  enable_logit               = var.enable_logit

  send_traffic_to_maintenance_page = var.send_traffic_to_maintenance_page
  enable_prometheus_monitoring     = var.enable_prometheus_monitoring
}

module "main_worker" {
  source     = "./vendor/modules/aks//aks/application"
  depends_on = [module.web_application]

  namespace                    = var.namespace
  environment                  = local.app_name_suffix
  service_name                 = var.service_name
  name                         = "worker"
  is_web                       = false
  docker_image                 = var.docker_image
  replicas                     = var.worker_replicas
  max_memory                   = var.worker_memory_max
  cluster_configuration_map    = module.cluster_data.configuration_map
  kubernetes_config_map_name   = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name       = module.application_configuration.kubernetes_secret_name
  command                      = ["bundle", "exec", "sidekiq", "-c", "5", "-C", "config/sidekiq-main.yml"]
  probe_command                = ["pgrep", "-f", "sidekiq"]
  enable_gcp_wif               = true
  enable_prometheus_monitoring = var.enable_prometheus_monitoring
  enable_logit                 = var.enable_logit
}

module "secondary_worker" {
  source     = "./vendor/modules/aks//aks/application"
  depends_on = [module.web_application]

  is_web                       = false
  namespace                    = var.namespace
  environment                  = local.app_name_suffix
  service_name                 = var.service_name
  name                         = "secondary-worker"
  docker_image                 = var.docker_image
  replicas                     = var.secondary_worker_replicas
  max_memory                   = var.secondary_worker_memory_max
  cluster_configuration_map    = module.cluster_data.configuration_map
  kubernetes_config_map_name   = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name       = module.application_configuration.kubernetes_secret_name
  command                      = ["bundle", "exec", "sidekiq", "-c", "5", "-C", "config/sidekiq-secondary.yml"]
  probe_command                = ["pgrep", "-f", "sidekiq"]
  enable_gcp_wif               = true
  enable_prometheus_monitoring = var.enable_prometheus_monitoring
  enable_logit                 = var.enable_logit
}

module "clock_worker" {
  source     = "./vendor/modules/aks//aks/application"
  depends_on = [module.web_application]

  is_web                     = false
  namespace                  = var.namespace
  environment                = local.app_name_suffix
  service_name               = var.service_name
  name                       = "clock-worker"
  docker_image               = var.docker_image
  replicas                   = var.clock_worker_replicas
  max_memory                 = var.clock_worker_memory_max
  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name
  command                    = ["bundle", "exec", "clockwork", "config/clock.rb"]
  probe_command              = ["pgrep", "-f", "clockwork"]
  enable_logit               = var.enable_logit
}
