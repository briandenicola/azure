resource "azurerm_user_assigned_identity" "apim" {
  name                = "${local.apim_name}-identity"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}