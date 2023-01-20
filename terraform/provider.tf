terraform {
  required_version = "~> 1.2.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.24.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = "0.15.5"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.0.4"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
  subscription_id            = try(local.azure_credentials.subscriptionId, null)
  client_id                  = try(local.azure_credentials.clientId, null)
  client_secret              = try(local.azure_credentials.clientSecret, null)
  tenant_id                  = try(local.azure_credentials.tenantId, null)
}

provider "cloudfoundry" {
  api_url           = local.cf_api_url
  user              = var.paas_sso_code == "" ? local.infra_secrets.CF_USER : null
  password          = var.paas_sso_code == "" ? local.infra_secrets.CF_PASSWORD : null
  sso_passcode      = var.paas_sso_code != "" ? var.paas_sso_code : null
  store_tokens_path = var.paas_sso_code != "" ? ".cftoken" : null
}

provider "statuscake" {
  api_token = local.infra_secrets.STATUSCAKE_PASSWORD
}

provider "kubernetes" {
  host                   = try(data.azurerm_kubernetes_cluster.main[0].kube_config.0.host, null)
  client_certificate     = try(base64decode(data.azurerm_kubernetes_cluster.main[0].kube_config.0.client_certificate), null)
  client_key             = try(base64decode(data.azurerm_kubernetes_cluster.main[0].kube_config.0.client_key), null)
  cluster_ca_certificate = try(base64decode(data.azurerm_kubernetes_cluster.main[0].kube_config.0.cluster_ca_certificate), null)
}
