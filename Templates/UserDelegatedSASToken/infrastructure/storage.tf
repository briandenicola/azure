resource "azurerm_storage_account" "this" {
  name                            = local.sa_name
  resource_group_name             = azurerm_resource_group.this.name
  location                        = azurerm_resource_group.this.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  min_tls_version                 = "TLS1_2"

  network_rules {
    default_action = "Deny"
    ip_rules       = ["${chomp(data.http.myip.response_body)}"]
  }
}

resource "azurerm_role_assignment" "storage" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_storage_container" "files" {
  depends_on = [
    azurerm_role_assignment.storage,
  ]
  name                  = "files"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "testfile" {
  depends_on = [
    azurerm_role_assignment.storage,
  ]
  name                   = "testfile.txt"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = azurerm_storage_container.files.name
  type                   = "Block"
  source                 = "testfile.txt"
}
