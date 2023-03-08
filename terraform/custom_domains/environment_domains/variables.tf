variable hosted_zone {
  type = map(any)
  default = {}
}

variable "multiple_hosted_zones" {
  type = bool
  default = false
}

# Variables for Azure alerts
variable "alert_domains" { default = null }
variable "latency_threshold" {
  default = 1500
}
variable "percent_5xx_threshold" {
  default = 10
}

variable "azure_credentials" { default = null }
locals {
  azure_credentials = try(jsondecode(var.azure_credentials), null)
  infra_secrets     = yamldecode(data.azurerm_key_vault_secret.infra_secrets.value)
  alert_emailgroup  = local.infra_secrets.ALERT_EMAILGROUP
}
