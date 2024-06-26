
resource "azurerm_key_vault" "this" {
  name                        = local.kv_name
  resource_group_name         = azurerm_resource_group.this.name
  location                    = azurerm_resource_group.this.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  enabled_for_disk_encryption = true

  sku_name = "standard"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["${chomp(data.http.myip.response_body)}/32"]
  }
}

resource "azurerm_private_endpoint" "kv" {
  name                = "${local.kv_name}-ep"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.private-endpoints.id

  private_service_connection {
    name                           = "${local.kv_name}-ep"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.privatelink_vaultcore_azure_net.name
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_vaultcore_azure_net.id]
  }
}
