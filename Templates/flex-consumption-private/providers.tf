terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3"
    }
  }
}

provider "azurerm" {
  # Shared keys are disabled on the storage account (shared_access_key_enabled = false),
  # so the provider must use the caller's Azure AD identity for storage data-plane calls
  # (blob service health check, container create) instead of an account key.
  storage_use_azuread = true

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
