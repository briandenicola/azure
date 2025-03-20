module "openai" {
  depends_on = [ 
    azurerm_resource_group.app,
  ]
  source               = "./modules/openai"
  resource_name        = local.resource_name
  resource_group = {
    location = azurerm_resource_group.app.location
    name     = azurerm_resource_group.app.name
  }
  log_analytics ={ 
    deploy       = true
    workspace_id =  module.azure_monitor.LOG_ANALYTICS_RESOURCE_ID
  }
}

resource "azurerm_private_endpoint" "azure_pop" {
  depends_on = [ 
    module.openai,
  ]
  name                = "${module.openai.OPENAI_RESOURCE_NAME}-endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.pe.id

  private_service_connection {
    name                           = "${module.openai.OPENAI_RESOURCE_NAME}-endpoint"
    private_connection_resource_id = module.openai.OPENAI_RESOURCE_ID
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                          = azurerm_private_dns_zone.privatelink_openai_azure_com.name
    private_dns_zone_ids          = [ azurerm_private_dns_zone.privatelink_openai_azure_com.id ]
  }
}