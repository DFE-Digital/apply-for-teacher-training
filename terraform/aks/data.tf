data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = local.app_resource_group_name
}

data "azurerm_key_vault_secret" "app_secrets" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = var.key_vault_app_secret_name
}

data "azurerm_key_vault_secret" "infra_secrets" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = var.key_vault_infra_secret_name
}

data "azurerm_kubernetes_cluster" "main" {
  name                = try(local.cluster_name, null)
  resource_group_name = try(local.cluster[var.cluster].cluster_resource_group_name, null)
}
