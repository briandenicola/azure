resource "azurerm_resource_group" "app" {
  name                  = "${local.resource_name}-app_rg"
  location              = local.primary_location
  tags                  = {
    Application         = var.tags
    DeployedOn          = timestamp()
    AppName             = local.resource_name
    Tier                = "Azure API Management"
  }
}