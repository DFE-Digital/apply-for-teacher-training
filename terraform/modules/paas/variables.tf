variable "cf_api_url" {}

variable "cf_user" { default = null}

variable "cf_user_password" { default = null }

variable "cf_sso_passcode" { default = null }

variable "cf_space" {}

variable "web_app_instances" {}

variable "web_app_memory" {}

variable "docker_credentials" {}

variable "app_docker_image" {}

variable "app_environment" {}

variable "app_environment_variables" {}

locals {
  web_app_name = "apply-${var.app_environment}"
  service_gov_uk_host_names = {
    qa      = "qa"
    staging = "staging"
    sandbox = "sandbox"
    prod    = "www"
  }
  web_app_routes = [cloudfoundry_route.web_app_service_gov_uk_route, cloudfoundry_route.web_app_cloudapps_digital_route]
}
