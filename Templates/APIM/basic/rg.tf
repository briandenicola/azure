resource "azurerm_resource_group" "this" {
  name                  = "${local.resource_name}-infra_rg"
  location              = var.region
  tags                  = {
    Application         = var.tags
    DeployedOn          = timestamp()
    AppName             = local.resource_name
    Tier                = "Azure Virtual Network; Private DNS Zone; Private Endpoints"
  }
}

resource "azurerm_resource_group" "app" {
  name                  = "${local.resource_name}-app_rg"
  location              = var.region
  tags                  = {
    Application         = var.tags
    DeployedOn          = timestamp()
    AppName             = local.resource_name
    Tier                = "Static Web App; Azure OpenAI; Azure API Management; Azure Storage"
  }
}