resource "azurerm_storage_account" "this" {
  name                = local.storage_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  public_network_access_enabled   = var.bootstrap
  shared_access_key_enabled       = false
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = var.bootstrap ? [local.my_ip] : []
  }
}

resource "azurerm_storage_container" "deployments" {
  name                  = "app-package-${random_id.this.dec}"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"

  depends_on = [time_sleep.wait_for_deployer_rbac]
}

resource "azurerm_private_endpoint" "storage_blob" {
  name                = "${local.resource_name}-pe-blob"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${local.resource_name}-psc-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "blob-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.this["blob"].id]
  }
}
