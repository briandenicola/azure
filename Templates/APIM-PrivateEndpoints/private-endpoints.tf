resource "azurerm_private_endpoint" "apim" {
  name                = "${local.apim_name}-endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.pe.id

  private_service_connection {
    name                           = "${local.apim_name}-endpoint"
    private_connection_resource_id = azurerm_api_management.this.id
    subresource_names              = ["gateway"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.privatelink_azure_api_net.name
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_azure_api_net.id]
  }
}

