# PaaS variables
variable "paas_sso_code" { default = null }

variable "paas_cf_space" {}

# Key Vault variables
variable "azure_credentials" {}

variable "key_vault_name" {}

variable "key_vault_resource_group" {}

variable "key_vault_infra_secret_name" {}

variable "key_vault_app_secret_name" {}

locals {
  cf_api_url        = "https://api.london.cloud.service.gov.uk"
  azure_credentials = jsondecode(var.azure_credentials)
  app_secrets       = yamldecode(data.azurerm_key_vault_secret.app_secrets.value)
  infra_secrets     = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)
}
