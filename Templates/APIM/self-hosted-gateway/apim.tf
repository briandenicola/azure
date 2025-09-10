resource azurerm_public_ip "apim" {
  name                = local.apim_pip_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${local.apim_name}"
}

resource "azurerm_api_management" "this" {
  depends_on = [ 
    azurerm_subnet.apim,
    azurerm_subnet_network_security_group_association.apim,
    azurerm_public_ip.apim,
  ]

  name                          = local.apim_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  publisher_name                = "BD"
  publisher_email               = "admin@bjdazure.tech"
  sku_name                      = local.apim_sku_name
  public_network_access_enabled = true
  virtual_network_type          = var.apim_virtual_network_type
  public_ip_address_id          = azurerm_public_ip.apim.id

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.apim.id
    ]
  }

  protocols {
    http2_enabled = true
  }

}

resource "azurerm_api_management_logger" "this" {
  name                = "${local.apim_name}-logger"
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name

  application_insights {
    connection_string = module.azure_monitor.APP_INSIGHTS_CONNECTION_STRING
  }
}
