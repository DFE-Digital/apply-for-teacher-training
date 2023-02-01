module "dns_records" {
  source      = "git::https://github.com/DFE-Digital/terraform-modules.git//dns/records"
  hosted_zone = var.hosted_zone
}
