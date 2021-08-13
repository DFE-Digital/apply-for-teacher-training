variable "cf_api_url" {}

variable "cf_user" { default = null }

variable "cf_user_password" { default = null }

variable "cf_sso_passcode" { default = "" }

variable "cf_space" {}

variable "web_app_instances" {}

variable "web_app_memory" {}

variable "docker_credentials" {}

variable "app_docker_image" {}

variable "app_environment" {}

variable "app_environment_variables" {}

variable "postgres_service_plan" {}

variable "worker_redis_service_plan" {}

variable "cache_redis_service_plan" {}

variable "clock_app_memory" {}

variable "worker_app_memory" {}

variable "clock_app_instances" {}

variable "worker_app_instances" {}

variable "logstash_url" {}

variable "prometheus_app" { default = null }

locals {
  web_app_name              = "apply-${var.app_environment}"
  clock_app_name            = "apply-clock-${var.app_environment}"
  worker_app_name           = "apply-worker-${var.app_environment}"
  postgres_service_name     = "apply-postgres-${var.app_environment}"
  worker_redis_service_name = "apply-worker-redis-${var.app_environment}"
  cache_redis_service_name  = "apply-cache-redis-${var.app_environment}"
  postgres_params = {
    enable_extensions = ["pg_buffercache", "pg_stat_statements", "pgcrypto"]
  }
  noeviction_maxmemory_policy = {
    maxmemory_policy = "noeviction"
  }
  allkeys_lru_maxmemory_policy = {
    maxmemory_policy = "allkeys-lru"
  }
  app_service_bindings = [cloudfoundry_service_instance.postgres, cloudfoundry_service_instance.redis,
  cloudfoundry_service_instance.redis_cache]
  service_gov_uk_host_names = {
    qa        = "qa"
    staging   = "staging"
    sandbox   = "sandbox"
    research  = "research"
    load-test = "load-test"
    prod      = "www"
  }
  assets_host_names = {
    qa        = "qa-assets"
    staging   = "staging-assets"
    sandbox   = "sandbox-assets"
    research  = "research-assets"
    load-test = "load-test-assets"
    prod      = "assets"
  }
  web_app_routes = [cloudfoundry_route.web_app_service_gov_uk_route, cloudfoundry_route.web_app_cloudapps_digital_route,
  cloudfoundry_route.web_app_education_gov_uk_route, cloudfoundry_route.web_app_internal_route, cloudfoundry_route.web_app_assets_service_gov_uk_route]
  app_environment_variables = merge(var.app_environment_variables,
    {
      BLAZER_DATABASE_URL = cloudfoundry_service_key.postgres-readonly-key.credentials.uri
      REDIS_URL           = cloudfoundry_service_key.worker_redis_key.credentials.uri
      REDIS_CACHE_URL     = cloudfoundry_service_key.cache_redis_key.credentials.uri
  })
  web_app_env_variables    = merge(local.app_environment_variables, { SERVICE_TYPE = "web" })
  clock_app_env_variables  = merge(local.app_environment_variables, { SERVICE_TYPE = "clock" })
  worker_app_env_variables = merge(local.app_environment_variables, { SERVICE_TYPE = "worker" })
}
