resource "azurerm_api_management" "this" {
  name                = local.apim_name
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  publisher_name      = "BD"
  publisher_email     = "admin@bjdazure.tech"
  sku_name            = local.apim_sku_name
}

resource "azurerm_api_management_logger" "this" {
  name                = "${local.apim_name}-logger"
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name

  application_insights {
    connection_string = module.azure_monitor.APP_INSIGHTS_CONNECTION_STRING
  }
}