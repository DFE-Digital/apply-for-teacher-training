resource "azurerm_postgresql_flexible_server" "postgres-server" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                   = local.postgres_server_name
  location               = data.azurerm_resource_group.app-resource-group.location
  resource_group_name    = data.azurerm_resource_group.app-resource-group.name
  version                = var.postgres_version
  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password
  create_mode            = "Default"
  storage_mb             = var.postgres_flexible_server_storage_mb
  sku_name               = var.postgres_flexible_server_sku
  delegated_subnet_id    = data.azurerm_subnet.postgres-subnet[0].id
  private_dns_zone_id    = data.azurerm_private_dns_zone.postgres-dns[0].id
  dynamic "high_availability" {
    for_each = var.postgres_enable_high_availability ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }
  lifecycle {
    ignore_changes = [
      tags,
      # Allow Azure to manage deployment zone. Ignore changes.
      zone,
      # Allow Azure to manage primary and standby server on fail-over. Ignore changes.
      high_availability[0].standby_availability_zone,
      # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
      create_mode
    ]
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "postgres-extensions" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.postgres-server[0].id
  value     = "PG_BUFFERCACHE,PG_STAT_STATEMENTS,PGCRYPTO,UNACCENT"
}

resource "azurerm_postgresql_flexible_server_configuration" "max-connections" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name      = "max_connections"
  server_id = azurerm_postgresql_flexible_server.postgres-server[0].id
  value     = 856 # Maximum on GP_Standard_D2ds_v4. See: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-limits#maximum-connections
}
