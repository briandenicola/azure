output "RESOURCE_GROUP" {
  value = azurerm_resource_group.this.name
}

output "FUNCTION_APP_NAME" {
  value = azurerm_function_app_flex_consumption.this.name
}

output "FUNCTION_APP_ID" {
  value = azurerm_function_app_flex_consumption.this.id
}

output "FUNCTION_APP_DEFAULT_HOSTNAME" {
  description = "Only resolvable/reachable from inside the VNet (or a peered/connected network) - the app is fully private."
  value       = azurerm_function_app_flex_consumption.this.default_hostname
}

output "FUNCTION_APP_SCM_HOSTNAME" {
  description = "SCM/Kudu endpoint, privatized by the same private endpoint as the default hostname. Only resolvable/reachable from inside the VNet."
  value       = "${azurerm_function_app_flex_consumption.this.name}.scm.azurewebsites.net"
}

output "STORAGE_ACCOUNT_NAME" {
  value = azurerm_storage_account.this.name
}

output "IDENTITY_ID" {
  value = azurerm_user_assigned_identity.this.id
}

output "VNET_ID" {
  value = azurerm_virtual_network.this.id
}
