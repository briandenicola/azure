resource "azurerm_storage_account" "this" {
  name                      = local.storage_account_name_name
  resource_group_name       = azurerm_resource_group.this.name
  location                  = azurerm_resource_group.this.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

resource "azurerm_storage_account" "test_account" {
  name                      = local.test_storage_account_name_name
  resource_group_name       = azurerm_resource_group.this.name
  location                  = azurerm_resource_group.this.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

resource "azurerm_storage_container" "apps_container" {
  name                  = "apps"
  storage_account_name  = azurerm_storage_account.test_account.name
  container_access_type = "private"
}
