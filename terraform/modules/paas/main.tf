terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.13.0"
    }
  }
}

provider "cloudfoundry" {
  api_url      = var.cf_api_url
  user         = var.cf_user != "" ? var.cf_user : null
  password     = var.cf_user_password != "" ? var.cf_user_password : null
  sso_passcode = var.cf_sso_passcode != "" ? var.cf_sso_passcode : null
}
