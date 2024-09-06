resource "azurerm_service_plan" "this" {
  name                   = local.app_service_name
  location               = azurerm_resource_group.this.location
  resource_group_name    = azurerm_resource_group.this.name
  os_type                = "Windows"
  sku_name               = "WS1"
}

