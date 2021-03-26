# Key Vault variables
variable "azure_credentials" {}

variable "key_vault_name" {}

variable "key_vault_resource_group" {}

variable "key_vault_infra_secret_name" {}

variable "key_vault_app_secret_name" {}

locals {
  azure_credentials = jsondecode(var.azure_credentials)
}
