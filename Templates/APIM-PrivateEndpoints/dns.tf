resource "azurerm_private_dns_zone" "privatelink_openai_azure_com" {
  name                      = "privatelink.openai.azure.com"
  resource_group_name       = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_openai_azure_com" {
  name                      = "${azurerm_virtual_network.this.name}-link"
  private_dns_zone_name     = azurerm_private_dns_zone.privatelink_openai_azure_com.name
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_id        = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone" "privatelink_azure_api_net" {
  name                      = "privatelink.azure-api.net"
  resource_group_name       = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_azure_api_net" {
  name                      = "${azurerm_virtual_network.this.name}-link"
  private_dns_zone_name     = azurerm_private_dns_zone.privatelink_azure_api_net.name
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_id        = azurerm_virtual_network.this.id
}