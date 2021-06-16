variable "cf_user" { default = null }

variable "cf_password" { default = null }

variable "cf_sso_passcode" { default = null }

variable "cf_space" { default = "bat-qa" }

variable "prometheus_app" { default = null }

variable "app_env_variables" {}

locals {
  app_name          = "apply-jmeter"
  docker_image      = "ghcr.io/dfe-digital/apply-jmeter-runner:latest"
  app_env_variables = var.app_env_variables
}
