terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm  = {
      source = "hashicorp/azurerm"
      version = "3.57.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "1.6.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.39.0"
    }
  }
}

provider "azurerm" {
  features  {}
}

provider "azapi" {
}

provider "azuread" {
}
