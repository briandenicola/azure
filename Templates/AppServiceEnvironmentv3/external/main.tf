terraform {
  required_version = ">= 0.13"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.73.0"
    }
  }
}

resource "random_id" "this" {
  byte_length = 2
}

resource "random_pet" "this" {
  length = 1
  separator  = ""
}

locals {
  resource_name               = "${random_pet.this.id}-${random_id.this.dec}"
  ase_name                    = "${local.resource_name}-ase"
  resource_group_name         = "${local.resource_name}_rg"
  location                    = "southcentralus"
  network_resource_group_name = "Core_Network_RG"
  virtual_network_name        = "BJD-Core-VNet-001"
  subnet_name                 = "ase"
}

provider "azurerm" {
  features  {}
}

resource "azurerm_resource_group" "ase" {
  name      = local.resource_group_name
  location  = local.location
}

data "azurerm_virtual_network" "vnet001" {
  name                 = local.virtual_network_name
  resource_group_name  = local.network_resource_group_name
}

data "azurerm_subnet" "ase" {
  name                 = local.subnet_name
  virtual_network_name = local.virtual_network_name
  resource_group_name  = local.network_resource_group_name
}

resource "azurerm_app_service_environment_v3" "ase3" {
  name                          = "bjdasev3-external"
  resource_group_name           = azurerm_resource_group.ase.name
  subnet_id                     = data.azurerm_subnet.ase.id

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }

  cluster_setting {
    name  = "InternalEncryption"
    value = "true"
  }
}

resource "azurerm_app_service_plan" "app_service_plan_linux" {
  name                         = "bjdhosting-linux"
  resource_group_name          = azurerm_resource_group.ase.name
  location                     = azurerm_resource_group.ase.location
  kind                         = "Linux"
  reserved                     = true
  app_service_environment_id   = azurerm_app_service_environment_v3.ase3.id
  sku {
    tier          = "IsolatedV2"
    size          = "I1v2"
    capacity      = 2
  }
}
/*
resource "azurerm_app_service_plan" "app_service_plan_windows" {
  name                         = "bjdhosting-windows"
  resource_group_name          = azurerm_resource_group.ase.name
  location                     = azurerm_resource_group.ase.location
  kind                         = "Windows"
  reserved                     = true
  app_service_environment_id   = azurerm_app_service_environment_v3.ase3.id
  sku {
    tier          = "IsolatedV2"
    size          = "I1v2"
    capacity      = 2
  }
}
*/

resource "azurerm_app_service" "webapp" {
  name                = "web01"
  location            = azurerm_resource_group.ase.location
  resource_group_name = azurerm_resource_group.ase.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan_linux.id
  identity {
    type = "SystemAssigned"
  }
  site_config {
    linux_fx_version          = "DOCKER|bjd145/chatws:1008"
    use_32_bit_worker_process = false
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"  = "https://index.docker.io/v1"
    "WEBSITE_VNET_ROUTE_ALL"      = "1"
  }
}