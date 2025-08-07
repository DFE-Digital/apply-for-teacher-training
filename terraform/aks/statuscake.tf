module "statuscake" {
  for_each = var.statuscake_alerts

  source = "./vendor/modules/aks//monitoring/statuscake"

  uptime_urls    = try(each.value.website_url, null)
  contact_groups = try(each.value.contact_group, null)
  trigger_rate   = try(each.value.trigger_rate, null)
  ssl_urls       = try(each.value.ssl_urls, null)
}
