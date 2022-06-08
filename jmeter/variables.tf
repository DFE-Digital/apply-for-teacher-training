variable "app_name" { default = null }

variable "cf_sso_passcode" { }

variable "cf_space" { default = "bat-prod" }

variable "prometheus_app" { default = "prometheus-bat" }

variable "app_env_variables" {}

locals {
  app_name          = var.app_name
  docker_image      = "ghcr.io/dfe-digital/apply-jmeter-runner:latest"
  app_env_variables = var.app_env_variables
}
