module "dns_zones" {
  source      = "git::https://github.com/DFE-Digital/terraform-modules.git//dns/zones"
  hosted_zone = var.hosted_zone
  tags        = local.tags
}
