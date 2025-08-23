resource "azurerm_user_assigned_identity" "this" {
  name                = local.cache_identity_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}