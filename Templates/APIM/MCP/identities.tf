resource "azurerm_user_assigned_identity" "apim_identity" {
  name                = "${local.apim_identity}"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
}

