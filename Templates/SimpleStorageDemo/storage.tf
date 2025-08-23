resource "azurerm_storage_account" "this" {
  name                          = local.storage_account_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = false

  network_rules {
    default_action = "Deny"
  }

}

resource "azurerm_private_endpoint" "storage_account" {
  name                = "${local.storage_account_name}-endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = data.azurerm_subnet.private-endpoints.id

  private_service_connection {
    name                           = "${local.storage_account_name}-endpoint"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = data.azurerm_private_dns_zone.privatelink_blob_core_windows_net.name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.privatelink_blob_core_windows_net.id]
  }
}
