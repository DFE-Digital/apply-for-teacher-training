
locals {
  alertable_zone = var.enable_alerting ? var.hosted_zone : {}
}

data "azurerm_monitor_action_group" "main" {
  count = var.enable_alerting ? 1 : 0

  name                = var.pg_actiongroup_name
  resource_group_name = var.pg_actiongroup_rg
}

data "azurerm_cdn_frontdoor_profile" "zone" {
  for_each            = local.alertable_zone

  name                = var.hosted_zone[each.key].front_door_name
  resource_group_name = var.hosted_zone[each.key].resource_group_name
}

# Default is to evaluate alerts every 1 minute,
# aggregated over the last 5 minutes

resource "azurerm_monitor_metric_alert" "fd_total_latency" {
  for_each            = local.alertable_zone

  name                = "${var.hosted_zone[each.key].front_door_name}-${var.hosted_zone[each.key].domains[0]}-latency"
  resource_group_name = var.hosted_zone[each.key].resource_group_name
  scopes              = [data.azurerm_cdn_frontdoor_profile.zone[each.key].id]
  description         = "Action will be triggered when avg latency is greater than 1500ms"

  criteria {
    metric_namespace = "Microsoft.Cdn/profiles"
    metric_name      = "TotalLatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.latency_threshold

    dimension {
      name     = "Endpoint"
      operator = "StartsWith"
      values   = [var.hosted_zone[each.key].domains[0]]
    }
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

resource "azurerm_monitor_metric_alert" "fd_percent_5xx" {
  for_each            = local.alertable_zone

  name                = "${var.hosted_zone[each.key].front_door_name}-${var.hosted_zone[each.key].domains[0]}-5xx"
  resource_group_name = var.hosted_zone[each.key].resource_group_name
  scopes              = [data.azurerm_cdn_frontdoor_profile.zone[each.key].id]
  description         = "Action will be triggered when 5xx failures greater than 10%"

  criteria {
    metric_namespace = "Microsoft.Cdn/profiles"
    metric_name      = "Percentage5XX"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.percent_5xx_threshold

    dimension {
      name     = "Endpoint"
      operator = "StartsWith"
      values   = [var.hosted_zone[each.key].domains[0]]
    }
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
