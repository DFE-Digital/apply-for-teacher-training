terraform {
  required_version = "~> 0.14.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.53.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.13.0"
    }
  }
}

provider "cloudfoundry" {
  api_url           = "https://api.london.cloud.service.gov.uk"
  user              = var.cf_sso_passcode == null ? var.cf_user : null
  password          = var.cf_sso_passcode == null ? var.cf_password : null
  sso_passcode      = var.cf_sso_passcode != null ? var.cf_sso_passcode : null
  store_tokens_path = var.cf_sso_passcode != null ? ".cftoken" : null
}

resource "cloudfoundry_app" "jmeter_app" {
  name                 = local.app_name
  docker_image         = local.docker_image
  health_check_type    = "process"
  health_check_timeout = 180
  stopped              = true
  instances            = 1
  memory               = 4096
  space                = data.cloudfoundry_space.space.id
  environment          = local.app_env_variables
  routes {
    route = cloudfoundry_route.jmeter_app_internal_route.id
  }
  routes {
    route = cloudfoundry_route.jmeter_cloudpps_route.id
  }
}

data "cloudfoundry_app" "jmeter_app" {
  depends_on = [cloudfoundry_app.jmeter_app]
  name_or_id = cloudfoundry_app.jmeter_app.name
  space      = data.cloudfoundry_space.space.id
}

data "cloudfoundry_app" "prometheus_app" {
  name_or_id = var.prometheus_app
  space      = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_network_policy" "prometheus_policy" {
  depends_on = [data.cloudfoundry_app.jmeter_app]
  policy {
    source_app      = data.cloudfoundry_app.prometheus_app.id
    destination_app = data.cloudfoundry_app.jmeter_app.id
    port            = "8080"
  }
}

resource "cloudfoundry_route" "jmeter_app_internal_route" {
  domain   = data.cloudfoundry_domain.internal.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.app_name
}

resource "cloudfoundry_route" "jmeter_cloudpps_route" {
  domain   = data.cloudfoundry_domain.london_cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.app_name
}

data "cloudfoundry_org" "org" {
  name = "dfe"
}

data "cloudfoundry_space" "space" {
  name = var.cf_space
  org  = data.cloudfoundry_org.org.id
}

data "cloudfoundry_domain" "internal" {
  name = "apps.internal"
}

data "cloudfoundry_domain" "london_cloudapps_digital" {
  name = "london.cloudapps.digital"
}
