terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.15.5"
    }
  }
}

provider "cloudfoundry" {
  api_url           = var.cf_api_url
  user              = var.cf_sso_passcode == "" ? var.cf_user : null
  password          = var.cf_sso_passcode == "" ? var.cf_user_password : null
  sso_passcode      = var.cf_sso_passcode != "" ? var.cf_sso_passcode : null
  store_tokens_path = var.cf_sso_passcode != "" ? ".cftoken" : null
}

resource "cloudfoundry_app" "web_app" {
  name                       = local.web_app_name
  docker_image               = var.app_docker_image
  health_check_type          = "http"
  health_check_http_endpoint = "/check"
  health_check_timeout       = 180
  instances                  = var.web_app_instances
  memory                     = var.web_app_memory
  space                      = data.cloudfoundry_space.space.id
  strategy                   = "blue-green-v2"
  enable_ssh                 = true
  timeout                    = 180
  environment                = local.web_app_env_variables

  dynamic "service_binding" {
    for_each = local.service_bindings
    content {
      service_instance = service_binding.value
    }
  }

  dynamic "routes" {
    for_each = local.web_app_routes
    content {
      route = routes.value.id
    }
  }
}

resource "cloudfoundry_app" "clock" {
  name                 = local.clock_app_name
  docker_image         = var.app_docker_image
  health_check_type    = "process"
  health_check_timeout = 180
  command              = "bundle exec clockwork config/clock.rb"
  instances            = var.clock_app_instances
  memory               = var.clock_app_memory
  space                = data.cloudfoundry_space.space.id
  timeout              = 180
  environment          = local.clock_app_env_variables

  dynamic "service_binding" {
    for_each = local.service_bindings
    content {
      service_instance = service_binding.value
    }
  }
}

resource "cloudfoundry_app" "worker" {
  name                 = local.worker_app_name
  docker_image         = var.app_docker_image
  health_check_type    = "process"
  health_check_timeout = 180
  command              = "bundle exec sidekiq -c 5 -C config/sidekiq-main.yml"
  instances            = var.worker_app_instances
  memory               = var.worker_app_memory
  strategy             = "blue-green-v2"
  space                = data.cloudfoundry_space.space.id
  timeout              = 180
  environment          = local.worker_app_env_variables

  dynamic "service_binding" {
    for_each = local.service_bindings
    content {
      service_instance = service_binding.value
    }
  }

  routes {
    route = cloudfoundry_route.worker_app_internal_route.id
  }
}

resource "cloudfoundry_app" "worker_secondary" {
  name                 = local.secondary_worker_app_name
  docker_image         = var.app_docker_image
  health_check_type    = "process"
  health_check_timeout = 180
  command              = "bundle exec sidekiq -c 5 -C config/sidekiq-secondary.yml"
  instances            = var.worker_secondary_app_instances
  memory               = var.worker_app_memory
  strategy             = "blue-green-v2"
  space                = data.cloudfoundry_space.space.id
  timeout              = 180
  environment          = local.worker_app_env_variables

  dynamic "service_binding" {
    for_each = local.service_bindings
    content {
      service_instance = service_binding.value
    }
  }

  routes {
    route = cloudfoundry_route.secondary_worker_app_internal_route.id
  }
}

resource "cloudfoundry_route" "web_app_internal_route" {
  domain   = data.cloudfoundry_domain.internal.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}

resource "cloudfoundry_route" "worker_app_internal_route" {
  domain   = data.cloudfoundry_domain.internal.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.worker_app_name
}

resource "cloudfoundry_route" "secondary_worker_app_internal_route" {
  domain   = data.cloudfoundry_domain.internal.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.secondary_worker_app_name
}

resource "cloudfoundry_route" "web_app_cloudapps_digital_route" {
  domain   = data.cloudfoundry_domain.london_cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}

resource "cloudfoundry_route" "web_app_service_gov_uk_route" {
  for_each = toset(var.service_gov_uk_host_names)
  domain   = data.cloudfoundry_domain.apply_service_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = each.value
}

resource "cloudfoundry_route" "web_app_education_gov_uk_route" {
  for_each = toset(var.service_gov_uk_host_names)
  domain   = data.cloudfoundry_domain.apply_education_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = each.value
}

resource "cloudfoundry_route" "web_app_assets_service_gov_uk_route" {
  for_each = toset(var.assets_host_names)
  domain   = data.cloudfoundry_domain.apply_service_gov_uk.id
  space    = data.cloudfoundry_space.space.id
  hostname = each.value
}

resource "cloudfoundry_service_instance" "postgres" {
  name         = local.postgres_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  json_params  = jsonencode(local.postgres_params)
  timeouts {
    create = "60m"
    update = "60m"
  }
}

resource "cloudfoundry_service_instance" "postgres_snapshot" {
  count        = var.snapshot_databases_to_deploy
  name         = local.postgres_snapshot_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_snapshot_service_plan]
  json_params  = jsonencode(local.postgres_params)
  timeouts {
    create = "60m"
    update = "60m"
  }
}

resource "cloudfoundry_service_key" "postgres" {
  name = "postgres-${var.app_environment}"
  service_instance = cloudfoundry_service_instance.postgres.id
}


resource "azurerm_postgresql_flexible_server" "postgres-server" {
  name                   = local.postgres_server_name
  location               = data.azurerm_resource_group.group.location
  resource_group_name    = data.azurerm_resource_group.group.name
  version                = 11
  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password
  create_mode            = "Default"
  storage_mb             = var.postgres_flexible_server_storage_mb
  sku_name               = var.postgres_flexible_server_sku
  dynamic "high_availability" {
    for_each = var.enable_postgres_high_availability ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }
  lifecycle {
    ignore_changes = [
      tags,
      # Allow Azure to manage deployment zone. Ignore changes.
      zone,
      # Allow Azure to manage primary and standby server on fail-over. Ignore changes.
      high_availability[0].standby_availability_zone
    ]
  }
}

##TO DO: check which extensions apply needs
# resource "azurerm_postgresql_flexible_server_configuration" "postgres-extensions" {
#   name      = "azure.extensions"
#   server_id = azurerm_postgresql_flexible_server.postgres-server.id
#   value     = "PLPGSQL,PGCRYPTO"
# }

resource "azurerm_postgresql_flexible_server_database" "postgres-database" {
  name      = local.postgres_service_name
  server_id = azurerm_postgresql_flexible_server.postgres-server.id
}

# resource "azurerm_postgresql_flexible_server_firewall_rule" "postgres-fw-rule-azure" {
#   name             = "AllowAzure"
#   server_id        = azurerm_postgresql_flexible_server.postgres-server.id
#   start_ip_address = "0.0.0.0"
#   end_ip_address   = "0.0.0.0"
# }

resource "cloudfoundry_service_instance" "redis" {
  name         = local.worker_redis_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.worker_redis_service_plan]
  json_params  = jsonencode(local.noeviction_maxmemory_policy)
  timeouts {
    create = "30m"
    update = "30m"
  }
}

resource "cloudfoundry_service_instance" "redis_cache" {
  name         = local.cache_redis_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.cache_redis_service_plan]
  json_params  = jsonencode(local.allkeys_lru_maxmemory_policy)
  timeouts {
    create = "30m"
    update = "30m"
  }
}

resource "cloudfoundry_service_key" "postgres-readonly-key" {
  name             = "${local.postgres_service_name}-readonly-key"
  service_instance = cloudfoundry_service_instance.postgres.id
}

resource "cloudfoundry_service_key" "worker_redis_key" {
  name             = "${local.worker_redis_service_name}-key"
  service_instance = cloudfoundry_service_instance.redis.id
}

resource "cloudfoundry_service_key" "cache_redis_key" {
  name             = "${local.cache_redis_service_name}-key"
  service_instance = cloudfoundry_service_instance.redis_cache.id
}

resource "cloudfoundry_user_provided_service" "logging" {
  name             = local.logging_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = var.logstash_url
}
