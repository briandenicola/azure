module "azure_monitor" {
  depends_on = [ 
    azurerm_resource_group.this,
  ]
  source               = "./modules/observability"
  region               = var.region
  resource_name        = local.resource_name
  tags                 = var.tags
}