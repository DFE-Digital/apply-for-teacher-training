data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = local.app_resource_group_name
}

data "azurerm_key_vault_secret" "statuscake_password" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "STATUSCAKE-PASSWORD"
}

data "azurerm_key_vault_secret" "postgres_admin_username" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "POSTGRES-ADMIN-USERNAME"
}

data "azurerm_key_vault_secret" "postgres_admin_password" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "POSTGRES-ADMIN-PASSWORD"
}
