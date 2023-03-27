data "azurerm_monitor_action_group" "main" {
  count = var.enable_alerting ? 1 : 0

  name                = var.pg_actiongroup_name
  resource_group_name = var.pg_actiongroup_rg
}

# Default is to evaluate alerts every 1 minute,
# aggregated over the last 5 minutes

resource "azurerm_monitor_metric_alert" "postgres_memory" {
  count = var.enable_alerting ? (var.deploy_azure_backing_services ? 1 : 0 ) : 0

  name                = "${azurerm_postgresql_flexible_server.postgres-server[0].name}-memory"
  resource_group_name = data.azurerm_resource_group.backing-service-resource-group[0].name
  scopes              = [azurerm_postgresql_flexible_server.postgres-server[0].id]
  description         = "Action will be triggered when memory use is greater than 75%"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "memory_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.pg_memory_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "postgres_cpu" {
  count = var.enable_alerting ? (var.deploy_azure_backing_services ? 1 : 0 ) : 0

  name                = "${azurerm_postgresql_flexible_server.postgres-server[0].name}-cpu"
  resource_group_name = data.azurerm_resource_group.backing-service-resource-group[0].name
  scopes              = [azurerm_postgresql_flexible_server.postgres-server[0].id]
  description         = "Action will be triggered when cpu use is greater than 60%"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.pg_cpu_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "postgres_storage" {
  count = var.enable_alerting ? (var.deploy_azure_backing_services ? 1 : 0 ) : 0

  name                = "${azurerm_postgresql_flexible_server.postgres-server[0].name}-storage"
  resource_group_name = data.azurerm_resource_group.backing-service-resource-group[0].name
  scopes              = [azurerm_postgresql_flexible_server.postgres-server[0].id]
  description         = "Action will be triggered when storage use is greater than 75%"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.pg_storage_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "redis_memory" {
  count = var.enable_alerting ? (var.deploy_azure_backing_services ? 1 : 0 ) : 0

  name                = "${azurerm_redis_cache.redis-queue[0].name}-memory"
  resource_group_name = data.azurerm_resource_group.backing-service-resource-group[0].name
  scopes              = [azurerm_redis_cache.redis-queue[0].id]
  description         = "Action will be triggered when memory use is greater than 60%"

  criteria {
    metric_namespace = "Microsoft.Cache/redis"
    metric_name      = "allusedmemorypercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.redis_memory_threshold
  }

  action {
    action_group_id = data.azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
