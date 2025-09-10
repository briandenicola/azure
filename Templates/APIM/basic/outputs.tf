output "APP_NAME" {
  value     = local.resource_name
  sensitive = false
}

output "APP_RESOURCE_GROUP" {
    value = azurerm_resource_group.app.name
    sensitive = false
}

output "APIM_GATEWAY" {
    value = local.app_apim_gateway_url
    sensitive = false
}