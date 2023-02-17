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
  webapp_memory_min             = var.webapp_memory_min
  webapp_memory_max             = var.webapp_memory_max
  webapp_cpu_min                = var.webapp_cpu_min
  webapp_cpu_max                = var.webapp_cpu_max
  worker_memory_min             = var.worker_memory_min
  worker_memory_max             = var.worker_memory_max
  worker_cpu_min                = var.worker_cpu_max
  worker_cpu_max                = var.worker_cpu_max
  secondary_worker_memory_min   = var.secondary_worker_memory_min
  secondary_worker_memory_max   = var.secondary_worker_memory_max
  secondary_worker_cpu_min      = var.secondary_worker_cpu_min
  secondary_worker_cpu_max      = var.secondary_worker_cpu_max
  clock_worker_memory_min       = var.clock_worker_memory_min
  clock_worker_memory_max       = var.clock_worker_memory_max
  clock_worker_cpu_min          = var.clock_worker_cpu_min
  clock_worker_cpu_max          = var.clock_worker_cpu_max
  webapp_replicas               = var.webapp_replicas
  worker_replicas               = var.worker_replicas
  secondary_worker_replicas     = var.secondary_worker_replicas
  clock_worker_replicas         = var.clock_worker_replicas
  postgres_flexible_server_sku  = var.postgres_flexible_server_sku
  postgres_flexible_server_storage_mb = var.postgres_flexible_server_storage_mb
  redis_capacity                = var.redis_capacity
  redis_family                  = var.redis_family
  redis_sku_name                = var.redis_sku_name
}

module "statuscake" {
  source = "../modules/statuscake"

  api_token = local.infra_secrets.STATUSCAKE_PASSWORD
  alerts    = var.statuscake_alerts
}
