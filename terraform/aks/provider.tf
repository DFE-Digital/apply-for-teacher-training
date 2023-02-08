terraform {
  required_version = "~> 1.3.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.24.0"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.0.4"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.17.0"
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

provider "statuscake" {
  api_token = local.infra_secrets.STATUSCAKE_PASSWORD
}

provider "kubernetes" {
  host                   = try(data.azurerm_kubernetes_cluster.main.kube_config.0.host, null)
  client_certificate     = try(base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate), null)
  client_key             = try(base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key), null)
  cluster_ca_certificate = try(base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate), null)
}
