locals {
  ase_name  = "bjdasev3-internal"
  resource_group_name = "DevSub01_Network_RG"
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
  name                 = "DevSub01-VNet-001"
  resource_group_name  = "DevSub01_Network_RG"
}

data "azurerm_subnet" "ase" {
  name                 = "ase"
  virtual_network_name = "DevSub01-VNet-001"
  resource_group_name  = "DevSub01_Network_RG"
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

