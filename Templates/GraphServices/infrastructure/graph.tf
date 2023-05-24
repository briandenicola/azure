resource "azapi_resource" "this" {
  depends_on = [ 
    azuread_service_principal.this
  ]
  name      = "${local.resource_name}-account"
  parent_id = azurerm_resource_group.this.id
  location = "global"
  type      = "Microsoft.GraphServices/accounts@2022-09-22-preview"
  body      = jsonencode({
    properties = {
      appId  = azuread_application.this.application_id
    }
  })
}
