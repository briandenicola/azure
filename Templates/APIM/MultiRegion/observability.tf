module "azure_monitor" {
  depends_on = [ 
    azurerm_resource_group.app,
  ]
  source               = "./modules/observability"
  region               = local.primary_location
  resource_name        = local.resource_name
  tags                 = var.tags
}