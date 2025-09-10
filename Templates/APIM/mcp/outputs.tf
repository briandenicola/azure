output "APP_NAME" {
  value     = local.resource_name
  sensitive = false
}

output "APP_RESOURCE_GROUP" {
    value = azurerm_resource_group.app.name
    sensitive = false
}

output "OPENAI_ENDPOINT" {
    value = module.openai.OPENAI_ENDPOINT
    sensitive = false
}

output "PORTAL_URL" {
    value = local.portal_url
    sensitive = false
}