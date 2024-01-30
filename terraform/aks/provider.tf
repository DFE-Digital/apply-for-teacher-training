terraform {
  required_version = "~> 1.3.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.61.0"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.0.4"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.17.0"
    }
    environment = {
      source  = "EppO/environment"
      version = "1.3.5"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}

provider "statuscake" {
  api_token = local.infra_secrets.STATUSCAKE_PASSWORD
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.main.kube_config.0.host
  client_certificate     = (local.azure_RBAC_enabled ? null :
    base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  )
  client_key             = (local.azure_RBAC_enabled ? null :
    base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  )
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)

  dynamic "exec" {
    for_each = local.azure_RBAC_enabled ? [1] : []
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args        = local.kubelogin_args
    }
  }
}
