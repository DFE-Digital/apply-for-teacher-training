terraform {

  required_version = "= 1.14.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.61.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}
