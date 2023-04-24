data "azurerm_storage_account" "this" {
  name                          = var.storage_account_name
  resource_group_name           = var.storage_account_resource_group_name
}

resource "azurerm_storage_container" "this" {
  name                  = "content"
  storage_account_name  = data.azurerm_storage_account.this.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "example" {
  name                   = "helloword.txt"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  source                 = "helloword.txt"
}