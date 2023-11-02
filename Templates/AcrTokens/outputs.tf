output "RESOURCE_GROUP" {
   value = data.azurerm_container_registry.this.resource_group_name
   sensitive = false
}

output "ACR_TOKEN_NAME" {
   value = local.token_name
   sensitive = false
}

output "ACR_TOKEN" {
   value = azurerm_container_registry_token_password.this.password1[0].value
   sensitive = true
}