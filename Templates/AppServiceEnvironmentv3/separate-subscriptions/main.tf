terraform {
  required_version = ">= 0.13"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
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
  location                    = "southcentralus"
  network_resource_group_name = "DevSub01_Network_RG"
  virtual_network_name        = "DevSub01-VNet-001"
  subnet_name                 = "ase"
  app_name                    = "${local.resource_name}-app"
  ase_resource_group_name     = "${local.resource_name}_ase_rg"
  asp_resource_group_name     = "${local.resource_name}_hosting_rg"
  app_resource_group_name     = "${local.resource_name}_app_rg"
  platform_subscription_id    = ""
  app_subscription_id         = ""
}

provider "azurerm" {
  features  {}
  alias           = "app"
  subscription_id = local.app_subscription_id
}

provider "azurerm" {
  features        {}
  alias           = "ase"
  subscription_id = local.platform_subscription_id
}

resource "azurerm_resource_group" "ase" {
  name      = local.ase_resource_group_name
  location  = local.location
  provider  = azurerm.ase
}

resource "azurerm_resource_group" "asp" {
  name      = local.asp_resource_group_name
  location  = local.location
  provider  = azurerm.app
}

resource "azurerm_resource_group" "app" {
  name      = local.ase_resource_group_name
  location  = local.app_resource_group_name
  provider  = azurerm.ase
}

data "azurerm_virtual_network" "vnet001" {
  name                 = local.virtual_network_name
  resource_group_name  = local.network_resource_group_name
  provider             = azurerm.ase
}

data "azurerm_subnet" "ase" {
  name                 = local.subnet_name
  virtual_network_name = local.virtual_network_name
  resource_group_name  = local.network_resource_group_name
  provider             = azurerm.ase
}

resource "azurerm_private_dns_zone" "appserviceenvironment_net" {
  name                      = "${local.resource_name}-ase.appserviceenvironment.net"
  resource_group_name       = azurerm_resource_group.ase.name
  provider                  = azurerm.ase
}

resource "azurerm_private_dns_zone_virtual_network_link" "appserviceenvironment_net_link" {
  name                  = "${local.resource_name}-link"
  resource_group_name   = azurerm_resource_group.ase.name

  private_dns_zone_name = azurerm_private_dns_zone.appserviceenvironment_net.name
  virtual_network_id    = data.azurerm_virtual_network.vnet001.id
  provider              = azurerm.ase
}

resource "azurerm_app_service_environment_v3" "ase3" {
  name                          	        = "${local.resource_name}-ase"
  resource_group_name                     = azurerm_resource_group.ase.name
  subnet_id                               = data.azurerm_subnet.ase.id
  internal_load_balancing_mode            = "Web, Publishing" 
  allow_new_private_endpoint_connections  = false
  zone_redundant                          = true
  provider                                = azurerm.ase

  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }

  cluster_setting {
    name  = "InternalEncryption"
    value = "true"
  }
}

resource "azurerm_private_dns_a_record" "wildcard_for_app_services" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.appserviceenvironment_net.name
  resource_group_name = azurerm_resource_group.ase.name
  ttl                 = 300
  records             = azurerm_app_service_environment_v3.ase3.internal_inbound_ip_addresses
  provider            = azurerm.ase
}

resource "azurerm_private_dns_a_record" "wildcard_for_kudu" {
  name                = "*.scm"
  zone_name           = azurerm_private_dns_zone.appserviceenvironment_net.name
  resource_group_name = azurerm_resource_group.ase.name
  ttl                 = 300
  records             = azurerm_app_service_environment_v3.ase3.internal_inbound_ip_addresses
  provider            = azurerm.ase
}

resource "azurerm_private_dns_a_record" "root_domain" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.appserviceenvironment_net.name
  resource_group_name = azurerm_resource_group.ase.name
  ttl                 = 300
  records             = azurerm_app_service_environment_v3.ase3.internal_inbound_ip_addresses
  provider            = azurerm.ase
}

resource "azurerm_service_plan" "asp" {
  name                         = "${local.resource_name}-windows-hosting"
  resource_group_name          = azurerm_resource_group.asp.name
  location                     = azurerm_resource_group.asp.location
  os_type                      = "Windows"
  app_service_environment_id   = azurerm_app_service_environment_v3.ase3.id
  sku_name                     = "I2v2"
  worker_count                 = 3
  provider                     = azurerm.app
}

resource "azurerm_windows_web_app" "app" {
  name                = "04"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  service_plan_id     = azurerm_service_plan.asp.id
  provider            = azurerm.app
  identity {
    type = "SystemAssigned"
  }
  
  site_config {
    application_stack  {
      dotnet_version = "v6.0"
    }
  }
}