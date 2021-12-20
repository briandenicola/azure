provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "spring_rg" {
  name     = "DevSub01_SpringCloud_RG"
}

data "azurerm_virtual_network" "vnet" {
  name                = "DevSub01-VNet-001"
  resource_group_name = "DevSub01_Network_RG"
}

data "azurerm_subnet" "services_subnet" {
  name                 = "springcloud-runtime"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_subnet" "app_subnet" {
  name                 = "springcloud-apps"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

resource "azurerm_application_insights" "spring_ai" {
    name                = "bjd-spring-appinsights"
    location            = data.azurerm_resource_group.spring_rg.location
    resource_group_name = data.azurerm_resource_group.spring_rg.name
    application_type    = "web"
}

resource "azurerm_spring_cloud_service" "spring" {
    name                = "bjdspring-standard"
    resource_group_name = data.azurerm_resource_group.spring_rg.name
    location            = data.azurerm_resource_group.spring_rg.location
    sku_name            = "S0"

    config_server_git_setting {
        uri          = "https://github.com/Azure-Samples/piggymetrics"
        label        = "config"
        search_paths = ["dir1", "dir2"]
    }

    network {
        app_subnet_id               = data.azurerm_subnet.app_subnet.id
        service_runtime_subnet_id   = data.azurerm_subnet.services_subnet.id
        cidr_ranges                 = ["10.20.0.0/16", "10.21.0.0/16", "10.30.0.1/16"]
    }

    trace {
        connection_string = azurerm_application_insights.spring_ai.connection_string
        sample_rate       = 10.0
    }

}