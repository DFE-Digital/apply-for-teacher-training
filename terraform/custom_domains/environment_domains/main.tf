# Used to create domains to be managed by front door.
module "domains" {
  for_each              = var.hosted_zone
  source                = "./vendor/modules/domains//domains/environment_domains"
  zone                  = each.key
  front_door_name       = each.value.front_door_name
  resource_group_name   = each.value.resource_group_name
  domains               = each.value.domains
  environment           = each.value.environment_short
  host_name             = each.value.origin_hostname
  multiple_hosted_zones = var.multiple_hosted_zones
  null_host_header      = try(each.value.null_host_header, false)
  cached_paths          = try(each.value.cached_paths, [])
  redirect_rules        = try(each.value.redirect_rules, null)
}
