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
  name = "DevSub01_ASEv3.2_RG"
}

data "azurerm_subnet" "ase" {
  name                 = "asev3"
  virtual_network_name = "DevSub01-VNet-001"
  resource_group_name  = "DevSub01_Network_RG"
}

resource "azurerm_app_service_environment_v3" "ase3" {
  name                          = "bjdasev3-2"
  resource_group_name           = data.azurerm_resource_group.ase.name
  subnet_id                     = data.azurerm_subnet.ase.id
  //internal_load_balancing_mode  = "Web, Publishing" //https://github.com/hashicorp/terraform-provider-azurerm/issues/12251

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
  resource_group_name          = data.azurerm_resource_group.ase.name
  location                     = data.azurerm_resource_group.ase.location
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
  resource_group_name          = data.azurerm_resource_group.ase.name
  location                     = data.azurerm_resource_group.ase.location
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
  location            = data.azurerm_resource_group.ase.location
  resource_group_name = data.azurerm_resource_group.ase.name
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