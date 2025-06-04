resource "azurerm_api_management" "this" {
  name                 = local.apim_name
  location             = azurerm_resource_group.app.location
  resource_group_name  = azurerm_resource_group.app.name
  publisher_name       = "BD"
  publisher_email      = "admin@bjdazure.tech"
  sku_name             = "${var.apim_sku_name}_1"
  zones                = var.apim_sku_name == "Premium" ? [1, 2, 3] : null
  virtual_network_type = var.apim_sku_name == "Premium" ? "External" : "None"

  dynamic "virtual_network_configuration" {
    for_each = var.apim_sku_name == "Premium" ? [1] : []
    content {
      subnet_id = azurerm_subnet.apim.id
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.apim_identity.id
    ]
  }
}

resource "azurerm_api_management_product" "ric_api_product" {
  product_id            = "ric-api-product"
  api_management_name   = azurerm_api_management.this.name
  resource_group_name   = azurerm_resource_group.app.name
  display_name          = "Roman Imperial Coin Analyzer"
  description           = "Roman Imperial Coin Analyzer"
  subscription_required = true
  approval_required     = false
  published             = true
}
