module "domains_infrastructure" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//domains/infrastructure?ref=3053-validate-infra-fix"
  hosted_zone             = var.hosted_zone
  tags                    = var.tags
  deploy_default_records  = var.deploy_default_records
  azure_enable_monitoring = var.azure_enable_monitoring

}
