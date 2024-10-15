output "RESOURCE_GROUP" {
    value = azurerm_resource_group.this.name
    sensitive = false
}

output "LOGIC_APP_NAME" {
    value = azapi_resource.this.name
    sensitive = false
}

output "WORKFLOW_STORAGE_ACCOUNT_NAME" {
    value = azurerm_storage_account.test_account.name
    sensitive = false
}