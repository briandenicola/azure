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
  network_resource_group_name = "Apps01_Network_RG"
  virtual_network_name        = "DevSub01-VNet-001"
  subnet_name                 = "ase"
}

terraform {
  required_version = ">= 0.13"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
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

resource "azurerm_private_dns_zone" "appserviceenvironment_net" {
  name                      = "${local.ase_name}.appserviceenvironment.net"
  resource_group_name       = azurerm_resource_group.ase.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "appserviceenvironment_net_link" {
  name                  = "${local.ase_name}-link"
  resource_group_name   = azurerm_resource_group.ase.name

  private_dns_zone_name = azurerm_private_dns_zone.appserviceenvironment_net.name
  virtual_network_id    = data.azurerm_virtual_network.vnet001.id
}

resource "azurerm_app_service_environment_v3" "ase3" {
  name                          	        = "${local.ase_name}"
  resource_group_name                     = azurerm_resource_group.ase.name
  subnet_id                               = data.azurerm_subnet.ase.id
  internal_load_balancing_mode            = "Web, Publishing" 
  allow_new_private_endpoint_connections  = false
  zone_redundant                          = true

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
}

resource "azurerm_private_dns_a_record" "wildcard_for_kudu" {
  name                = "*.scm"
  zone_name           = azurerm_private_dns_zone.appserviceenvironment_net.name
  resource_group_name = azurerm_resource_group.ase.name
  ttl                 = 300
  records             = azurerm_app_service_environment_v3.ase3.internal_inbound_ip_addresses
}

resource "azurerm_private_dns_a_record" "root_domain" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.appserviceenvironment_net.name
  resource_group_name = azurerm_resource_group.ase.name
  ttl                 = 300
  records             = azurerm_app_service_environment_v3.ase3.internal_inbound_ip_addresses
}

resource "azurerm_service_plan" "app_service_plan_windows" {
  name                         = "${local.resource_name}-windows-hosting"
  resource_group_name          = azurerm_resource_group.ase.name
  location                     = azurerm_resource_group.ase.location
  os_type                      = "Windows"
  app_service_environment_id   = azurerm_app_service_environment_v3.ase3.id
  sku_name                     = "I2v2"
  worker_count                 = 3
}

resource "azurerm_service_plan" "app_service_plan_linux" {
  name                         = "${local.resource_name}-linux-hosting"
  resource_group_name          = azurerm_resource_group.ase.name
  location                     = azurerm_resource_group.ase.location
  os_type                      = "Linux"
  app_service_environment_id   = azurerm_app_service_environment_v3.ase3.id
  sku_name                     = "I2v2"
  worker_count                 = 3
}

resource "azurerm_windows_web_app" "windows_webapp" {
  name                = "01"
  location            = azurerm_resource_group.ase.location
  resource_group_name = azurerm_resource_group.ase.name
  service_plan_id     = azurerm_service_plan.app_service_plan_windows.id

  identity {
    type = "SystemAssigned"
  }
  
  site_config {
    application_stack  {
      dotnet_version = "v6.0"
    }
  }
  
}

resource "azurerm_linux_web_app" "linux_webapp" {
  name                = "02"
  location            = azurerm_resource_group.ase.location
  resource_group_name = azurerm_resource_group.ase.name
  service_plan_id     = azurerm_service_plan.app_service_plan_linux.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    container_registry_use_managed_identity = true

    application_stack  {
      docker_image = "bjdcsa.azurecr.io/httpdemo"
      docker_image_tag = "1287"
    }
  }

  app_settings = {
    "WEBSITES_PORT" = "8080"
  }

}
