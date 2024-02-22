module "kubernetes" {
  source = "../modules/kubernetes"

  app_docker_image                    = var.paas_docker_image
  app_environment                     = local.app_name_suffix
  app_environment_variables           = local.app_env_values
  app_secrets                         = local.app_secrets
  cluster                             = local.cluster[var.cluster]
  namespace                           = var.namespace
  webapp_startup_command              = var.webapp_startup_command
  webapp_memory_max                   = var.webapp_memory_max
  worker_memory_max                   = var.worker_memory_max
  secondary_worker_memory_max         = var.secondary_worker_memory_max
  clock_worker_memory_max             = var.clock_worker_memory_max
  webapp_replicas                     = var.webapp_replicas
  worker_replicas                     = var.worker_replicas
  secondary_worker_replicas           = var.secondary_worker_replicas
  clock_worker_replicas               = var.clock_worker_replicas
  gov_uk_host_names                   = var.gov_uk_host_names
  pdb_min_available                   = var.pdb_min_available
  database_username                   = module.postgres.username
  database_password                   = module.postgres.password
  database_host                       = module.postgres.host
  database_port                       = module.postgres.port
  redis_cache_url                     = module.redis-cache.url
  redis_queue_url                     = module.redis-queue.url
}

module "statuscake" {
  source = "../modules/statuscake"

  api_token = local.infra_secrets.STATUSCAKE_PASSWORD
  alerts    = var.statuscake_alerts
}
