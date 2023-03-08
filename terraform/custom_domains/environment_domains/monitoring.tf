data "azurerm_key_vault" "key_vault" {
  name                = "s189p01-att-sbx-kv"
  resource_group_name = "s189p01-att-sbx-rg"
}

data "azurerm_key_vault_secret" "infra_secrets" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "BAT-INFRA-SECRETS-SANDBOX"
}

resource "azurerm_monitor_action_group" "main" {
  count = var.alert_domains != null ? 1 : 0

  name                = "apply-cdn-${var.hosted_zone[var.alert_domains[0]].environment_short}-ag"
  resource_group_name = var.hosted_zone[var.alert_domains[0]].resource_group_name
  short_name          = "apply-${var.hosted_zone[var.alert_domains[0]].environment_short}"

  email_receiver {
    name          = "apply-${var.hosted_zone[var.alert_domains[0]].environment_short}-email-receiver"
    email_address = local.alert_emailgroup
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

data "azurerm_cdn_frontdoor_profile" "svc_domain" {
  for_each            = toset(var.alert_domains)

  name                = var.hosted_zone[each.value].front_door_name
  resource_group_name = var.hosted_zone[each.value].resource_group_name
}

# Default is to evaluate alerts every 1 minute,
# aggregated over the last 5 minutes

resource "azurerm_monitor_metric_alert" "fd_total_latency" {
  for_each            = toset(var.alert_domains)

  name                = "${var.hosted_zone[each.value].front_door_name}-metricalert-latency"
  resource_group_name = var.hosted_zone[each.value].resource_group_name
  scopes              = [data.azurerm_cdn_frontdoor_profile.svc_domain[each.value].id]
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
      values   = [var.hosted_zone[each.value].domains[0]]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "fd_percent_5xx" {
  for_each            = toset(var.alert_domains)

  name                = "${var.hosted_zone[each.value].front_door_name}-metricalert-5xx"
  resource_group_name = var.hosted_zone[each.value].resource_group_name
  scopes              = [data.azurerm_cdn_frontdoor_profile.svc_domain[each.value].id]
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
      values   = [var.hosted_zone[each.value].domains[0]]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
