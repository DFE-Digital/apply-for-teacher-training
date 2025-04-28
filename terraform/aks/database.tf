module "postgres" {
  source = "./vendor/modules/aks//aks/postgres"

  namespace                      = var.namespace
  environment                    = local.app_name_suffix
  azure_resource_prefix          = var.azure_resource_prefix
  service_name                   = var.service_name
  service_short                  = var.service_short
  config_short                   = var.config_short
  azure_name_override            = "${var.azure_resource_prefix}-${var.service_short}-${local.app_name_suffix}-psql"
  cluster_configuration_map      = module.cluster_data.configuration_map
  use_azure                      = var.deploy_azure_backing_services
  azure_enable_monitoring        = var.enable_alerting
  azure_enable_backup_storage    = var.deploy_azure_backing_services
  server_version                 = "15"
  admin_username                 = local.infra_secrets.POSTGRES_ADMIN_USERNAME
  admin_password                 = local.infra_secrets.POSTGRES_ADMIN_PASSWORD
  azure_sku_name                 = var.postgres_flexible_server_sku
  azure_storage_mb               = var.postgres_flexible_server_storage_mb
  azure_enable_high_availability = var.postgres_enable_high_availability
  azure_maintenance_window       = var.azure_maintenance_window
  azure_extensions               = ["PG_BUFFERCACHE", "PG_STAT_STATEMENTS", "PGCRYPTO", "UNACCENT"]
  alert_window_size              = var.alert_window_size
}
