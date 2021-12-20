locals {
  ase_name                    = "bjdasev3-internal"
  resource_group_name         = "DevSub01_ASEv3-internal_RG"
  network_resource_group_name = "DevSub01_Network_RG"
  virtual_network_name        = "DevSub01-VNet-001"
  subnet_name                 = "ase"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.73.0"
    }
  }
}

provider "azurerm" {
  features  {}
}

data "azurerm_resource_group" "ase" {
  name = local.resource_group_name
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

resource "azurerm_private_dns_zone" "appserviceenvironment_net" {
  name                      = "${local.ase_name}.appserviceenvironment.net"
  resource_group_name       = data.azurerm_resource_group.ase.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "appserviceenvironment_net_link" {
  name                  = "${local.ase_name}-link"
  resource_group_name   = data.azurerm_resource_group.ase.name

  private_dns_zone_name = azurerm_private_dns_zone.appserviceenvironment_net.name
  virtual_network_id    = data.azurerm_virtual_network.vnet001.id
}

resource "azurerm_app_service_environment_v3" "ase3" {
  name                          = local.ase_name
  resource_group_name           = data.azurerm_resource_group.ase.name
  subnet_id                     = data.azurerm_subnet.ase.id
  internal_load_balancing_mode  = "Web, Publishing" 
  zone_redundant                = true

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }

  cluster_setting {
    name  = "InternalEncryption"
    value = "true"
  }
}

resource "azurerm_app_service_plan" "app_service_plan_windows" {
  name                         = "bjdhosting-windows"
  resource_group_name          = data.azurerm_resource_group.ase.name
  location                     = data.azurerm_resource_group.ase.location
  kind                         = "Windows"
  reserved                     = false
  app_service_environment_id   = azurerm_app_service_environment_v3.ase3.id

  sku {
    tier          = "IsolatedV2"
    size          = "I1v2"
    capacity      = 2
  }

}

resource "azurerm_app_service" "webapp" {
  name                = "01"
  location            = data.azurerm_resource_group.ase.location
  resource_group_name = data.azurerm_resource_group.ase.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan_windows.id

  identity {
    type = "SystemAssigned"
  }
  
  site_config {
    dotnet_framework_version = "v4.0"
  }
  
}
