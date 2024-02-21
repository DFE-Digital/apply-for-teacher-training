data "azurerm_monitor_action_group" "main" {
  count = var.enable_alerting ? 1 : 0

  name                = var.pg_actiongroup_name
  resource_group_name = var.pg_actiongroup_rg
}

# Default is to evaluate alerts every 1 minute,
# aggregated over the last 5 minutes

resource "azurerm_monitor_metric_alert" "redis_memory" {
  count = var.enable_alerting ? (var.deploy_azure_backing_services ? 1 : 0) : 0

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
