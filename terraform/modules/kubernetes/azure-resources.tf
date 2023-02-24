resource "azurerm_postgresql_flexible_server" "postgres-server" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                   = local.postgres_server_name
  location               = data.azurerm_resource_group.backing-service-resource-group[0].location
  resource_group_name    = data.azurerm_resource_group.backing-service-resource-group[0].name
  version                = 11
  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password
  create_mode            = "Default"
  storage_mb             = var.postgres_flexible_server_storage_mb
  sku_name               = var.postgres_flexible_server_sku
  delegated_subnet_id    = data.azurerm_subnet.postgres-subnet[0].id
  private_dns_zone_id    = data.azurerm_private_dns_zone.postgres-dns[0].id
  dynamic "high_availability" {
    for_each = var.postgres_enable_high_availability ? [1] : []
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

resource "azurerm_postgresql_flexible_server_configuration" "postgres-extensions" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.postgres-server[0].id
  value     = "PG_BUFFERCACHE,PG_STAT_STATEMENTS,PGCRYPTO"
}

resource "azurerm_postgresql_flexible_server_configuration" "max-connections" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name      = "max_connections"
  server_id = azurerm_postgresql_flexible_server.postgres-server[0].id
  value     = 856 # Maximum on GP_Standard_D2ds_v4. See: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-limits#maximum-connections
}

resource "azurerm_redis_cache" "redis-cache" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                          = local.redis_cache_name
  location                      = data.azurerm_resource_group.backing-service-resource-group[0].location
  resource_group_name           = data.azurerm_resource_group.backing-service-resource-group[0].name
  capacity                      = var.redis_capacity
  family                        = var.redis_family
  sku_name                      = var.redis_sku_name
  minimum_tls_version           = var.redis_minimum_tls_version
  public_network_access_enabled = var.redis_public_network_access_enabled

  redis_configuration {
    maxmemory_policy = "allkeys-lru"
  }

  timeouts {
    create = "30m"
    update = "30m"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_endpoint" "redis-cache-private-endpoint" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                = local.redis_cache_private_endpoint_name
  location            = data.azurerm_resource_group.backing-service-resource-group[0].location
  resource_group_name = data.azurerm_resource_group.backing-service-resource-group[0].name
  subnet_id           = data.azurerm_subnet.redis-subnet[0].id

  private_dns_zone_group {
    name                 = data.azurerm_private_dns_zone.redis-dns[0].name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.redis-dns[0].id]
  }

  private_service_connection {
    name                           = local.redis_cache_private_endpoint_name
    private_connection_resource_id = azurerm_redis_cache.redis-cache[0].id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_redis_cache" "redis-queue" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                          = local.redis_queue_name
  location                      = data.azurerm_resource_group.backing-service-resource-group[0].location
  resource_group_name           = data.azurerm_resource_group.backing-service-resource-group[0].name
  capacity                      = var.redis_capacity
  family                        = var.redis_family
  sku_name                      = var.redis_sku_name
  minimum_tls_version           = var.redis_minimum_tls_version
  public_network_access_enabled = var.redis_public_network_access_enabled

  redis_configuration {
    maxmemory_policy = "noeviction"
  }

  timeouts {
    create = "30m"
    update = "30m"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_endpoint" "redis-queue-private-endpoint" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                = local.redis_queue_private_endpoint_name
  location            = data.azurerm_resource_group.backing-service-resource-group[0].location
  resource_group_name = data.azurerm_resource_group.backing-service-resource-group[0].name
  subnet_id           = data.azurerm_subnet.redis-subnet[0].id

  private_dns_zone_group {
    name                 = data.azurerm_private_dns_zone.redis-dns[0].name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.redis-dns[0].id]
  }

  private_service_connection {
    name                           = local.redis_queue_private_endpoint_name
    private_connection_resource_id = azurerm_redis_cache.redis-queue[0].id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
