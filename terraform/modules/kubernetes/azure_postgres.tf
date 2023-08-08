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

  dynamic "maintenance_window" {
    for_each = var.azure_maintenance_window != null ? [var.azure_maintenance_window] : []
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
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
resource "azurerm_postgresql_flexible_server" "postgres-snapshot-server" {
  count = var.deploy_snapshot_database ? 1 : 0

  name                   = local.postgres_snapshot_server_name
  location               = data.azurerm_resource_group.app-resource-group.location
  resource_group_name    = data.azurerm_resource_group.app-resource-group.name
  version                = var.postgres_version
  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password
  create_mode            = "Default"
  storage_mb             = var.postgres_flexible_server_storage_mb
  sku_name               = var.postgres_snapshot_flexible_server_sku
  delegated_subnet_id    = data.azurerm_subnet.postgres-subnet[0].id
  private_dns_zone_id    = data.azurerm_private_dns_zone.postgres-dns[0].id
  lifecycle {
    ignore_changes = [
      tags,
      # Allow Azure to manage deployment zone. Ignore changes.
      zone,
      # Required for import because of https://github.com/hashicorp/terraform-provider-azurerm/issues/15586
      create_mode
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "snapshot-db" {
  count = var.deploy_snapshot_database ? 1 : 0
  # add option to not create database

  name      = local.postgres_snapshot_service_name
  server_id = azurerm_postgresql_flexible_server.postgres-snapshot-server[0].id
  collation = "en_US.utf8"
  charset   = "utf8"
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

resource "azurerm_postgresql_flexible_server_configuration" "postgres-snapshot-extensions" {
  count = var.deploy_snapshot_database ? 1 : 0

  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.postgres-snapshot-server[0].id
  value     = "PG_BUFFERCACHE,PG_STAT_STATEMENTS,PGCRYPTO,UNACCENT"
}

resource "azurerm_storage_account" "database_backup" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                     = "${var.azure_resource_prefix}${var.service_short}dbbkp${var.config_short}sa"
  location                 = data.azurerm_resource_group.app-resource-group.location
  resource_group_name      = data.azurerm_resource_group.app-resource-group.name
  account_tier             = "Standard"
  account_replication_type = "GRS"

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_storage_management_policy" "database_backup" {
  count = var.deploy_azure_backing_services ? 1 : 0

  storage_account_id = azurerm_storage_account.database_backup[0].id

  rule {
    name    = "DeleteAfter7Days"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 7
      }
    }
  }
}

resource "azurerm_storage_container" "database_backup" {
  count = var.deploy_azure_backing_services ? 1 : 0

  name                  = "database-backup"
  storage_account_name  = azurerm_storage_account.database_backup[0].name
  container_access_type = "private"
}
