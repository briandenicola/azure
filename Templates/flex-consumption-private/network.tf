resource "azurerm_virtual_network" "this" {
  name                = "${local.resource_name}-network"
  address_space       = [local.vnet_cidr]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

# Dedicated subnet for the Function App's outbound VNet integration. Flex Consumption
# runs on the same compute fabric as Container Apps, so it delegates to
# Microsoft.App/environments rather than the classic App Service Plan delegation
# (Microsoft.Web/serverFarms) used by Premium/Dedicated plans.
resource "azurerm_subnet" "integration" {
  name                 = "integration"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.integration_subnet_cidr]

  delegation {
    name = "function-delegation"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Subnet for private endpoints (storage, function app).
resource "azurerm_subnet" "private_endpoints" {
  name                               = "private-endpoints"
  resource_group_name               = azurerm_resource_group.this.name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = [local.pe_subnet_cidr]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_network_security_group" "this" {
  name                = "${local.resource_name}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "integration" {
  subnet_id                 = azurerm_subnet.integration.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.this.id
}
