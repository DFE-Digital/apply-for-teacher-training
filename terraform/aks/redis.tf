module "redis-cache" {
  source = "./vendor/modules/aks//aks/redis"

  name                  = "cache"
  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  service_name          = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_alerting
  azure_patch_schedule    = [{ "day_of_week" : "Sunday", "start_hour_utc" : 01 }]

  azure_capacity = var.redis_cache_capacity
  azure_family   = var.redis_cache_family
  azure_sku_name = var.redis_cache_sku_name
  server_version = var.redis_server_version
}

module "redis-queue" {
  source = "./vendor/modules/aks//aks/redis"

  name                  = "queue"
  namespace             = var.namespace
  environment           = local.app_name_suffix
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short
  service_name          = var.service_name

  cluster_configuration_map = module.cluster_data.configuration_map

  use_azure               = var.deploy_azure_backing_services
  azure_enable_monitoring = var.enable_alerting
  azure_maxmemory_policy  = "noeviction"
  azure_patch_schedule    = [{ "day_of_week" : "Sunday", "start_hour_utc" : 01 }]

  azure_capacity = var.redis_queue_capacity
  azure_family   = var.redis_queue_family
  azure_sku_name = var.redis_queue_sku_name
  server_version = var.redis_server_version
}
