module "regional_resources" {
  for_each              = toset(var.locations)
  source                = "./modules/regional"
  location              = each.value
  app_name              = local.resource_name
  custom_domain         = var.custom_domain
  tags                  = var.tags
}
