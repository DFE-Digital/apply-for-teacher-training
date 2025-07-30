module "statuscake" {
  source = "../modules/statuscake"

  api_token = data.azurerm_key_vault_secret.statuscake_password.value
  alerts    = var.statuscake_alerts
}
