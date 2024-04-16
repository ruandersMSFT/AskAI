terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "=1.12.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.99.0"
    }
  }
}

provider "azapi" {
}

provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}