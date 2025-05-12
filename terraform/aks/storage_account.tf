resource "azurerm_storage_account" "data_exports_sa" {
  count                            = var.create_storage_account ? 1 : 0
  name                             = local.exp_storage_account_name
  resource_group_name              = local.app_resource_group_name
  location                         = "UK South"
  account_tier                     = "Standard"
  account_replication_type         = var.account_replication_type
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false

  dynamic "blob_properties" {
    for_each = var.app_environment == "production" ? [1] : []
    content {
      delete_retention_policy {
        days = 7
      }
      container_delete_retention_policy {
        days = 7
      }
    }
  }

  tags = {
    environment = var.app_environment
  }

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_storage_container" "data_exports_container" {
  count                 = var.create_storage_account ? 1 : 0
  name                  = "storage"
  storage_account_name  = azurerm_storage_account.data_exports_sa[count.index].name
  container_access_type = "private"
}
