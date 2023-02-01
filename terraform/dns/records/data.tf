# Zone

data "azurerm_dns_zone" "dns_zone" {
  for_each = var.hosted_zone

  name                = each.key
  resource_group_name = each.value.resource_group_name
}
