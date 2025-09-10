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


resource "azurerm_api_management_api" "ric_api" {
  name                  = "ric-api"
  resource_group_name   = azurerm_resource_group.app.name
  api_management_name   = azurerm_api_management.this.name
  api_type              = "http"
  revision              = "1"
  display_name          = "Roman Imperial Coin Analyzer"
  path                  = local.apim_api_path
  protocols             = ["http", "https"]
  subscription_required = true
}

resource "azurerm_api_management_api_operation" "ric_api_get_operation" {
  operation_id        = "get"
  api_name            = azurerm_api_management_api.ric_api.name
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_resource_group.app.name
  display_name        = "GET User Operation"
  method              = "GET"
  url_template        = "/"

  response {
    status_code = 200
  }
}

resource "azurerm_api_management_product_api" "ric_api_product_association" {
  api_name            = azurerm_api_management_api.ric_api.name
  product_id          = azurerm_api_management_product.ric_api_product.product_id
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name
}


resource "azurerm_api_management_subscription" "ric_ui_subscription" {
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name
  product_id          = azurerm_api_management_product.ric_api_product.id
  display_name        = "Roman Imperial Coin Analyzer UI Subscription"
  allow_tracing       = true
  state               = "active"
}

resource "azurerm_api_management_logger" "this" {
  name                = "${local.apim_name}-logger"
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name

  application_insights {
    connection_string = module.azure_monitor.APP_INSIGHTS_CONNECTION_STRING
  }
}

resource "azurerm_api_management_api_policy" "ric_ui_api_policy" {
  api_name            = azurerm_api_management_api.ric_api.name
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name

  xml_content = <<XML
    <policies>
      <inbound>
          <mock-response/> 
          <base />
      </inbound>
      <backend>
          <base />
      </backend>
      <outbound>
          <base />
      </outbound>
      <on-error>
          <base />
      </on-error>
    </policies>
XML

}