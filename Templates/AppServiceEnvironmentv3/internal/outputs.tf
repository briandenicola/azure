output "ASE_RESOURCE_GROUP" {
    value = azurerm_app_service_environment_v3.this.resource_group_name
    sensitive = false
}

output "ASE_NAME" {
    value = azurerm_app_service_environment_v3.this.name
    sensitive = false
}