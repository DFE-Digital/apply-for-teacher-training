resource "azurerm_redis_cache" "redis-cache" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                          = local.redis_cache_name
  location                      = data.azurerm_resource_group.app-resource-group.location
  resource_group_name           = data.azurerm_resource_group.app-resource-group.name
  capacity                      = var.redis_cache_capacity
  family                        = var.redis_cache_family
  sku_name                      = var.redis_cache_sku_name
  minimum_tls_version           = var.redis_minimum_tls_version
  public_network_access_enabled = var.redis_public_network_access_enabled
  redis_version                 = var.redis_server_version

  redis_configuration {
    maxmemory_policy = "allkeys-lru"
  }

  timeouts {
    create = "30m"
    update = "30m"
  }

  patch_schedule {
    day_of_week    = "Sunday"
    start_hour_utc = 01
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
  location            = data.azurerm_resource_group.app-resource-group.location
  resource_group_name = data.azurerm_resource_group.app-resource-group.name
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
  location                      = data.azurerm_resource_group.app-resource-group.location
  resource_group_name           = data.azurerm_resource_group.app-resource-group.name
  capacity                      = var.redis_queue_capacity
  family                        = var.redis_queue_family
  sku_name                      = var.redis_queue_sku_name
  minimum_tls_version           = var.redis_minimum_tls_version
  public_network_access_enabled = var.redis_public_network_access_enabled
  zones                         = var.redis_queue_sku_name != "Standard" && var.redis_queue_sku_name != "Basic" ? ["1", "2"] : null

  redis_configuration {
    maxmemory_policy = "noeviction"
  }
  timeouts {
    create = "30m"
    update = "30m"
  }

  patch_schedule {
    day_of_week    = "Sunday"
    start_hour_utc = 01
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
  location            = data.azurerm_resource_group.app-resource-group.location
  resource_group_name = data.azurerm_resource_group.app-resource-group.name
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
