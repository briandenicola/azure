output "APP_NAME" {
    value = local.resource_name
    sensitive = false
}

output "APP_RESOURCE_GROUP" {
    value = azurerm_resource_group.this.name
    sensitive = false
}

output "AAD_SPN_CLIENT_ID" {
    value = azuread_service_principal.this.application_id
    sensitive = false
}

output "VALIDATION_URL" {
    value = "https://management.azure.com/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.this.name}/providers/Microsoft.GraphServices/accounts/${local.resource_name}-account?api-version=2022-09-22-preview"
    sensitive = false
}