output "SUBSCRIPTION_ID" {
  value     = data.azurerm_subscription.current.subscription_id
  sensitive = false
}

output "APP_NAME" {
  value     = local.resource_name
  sensitive = false
}

output "APIM_NAME" {
  value     = azurerm_api_management.this.name
  sensitive = false
}

output "APP_RESOURCE_GROUP" {
  value     = azurerm_resource_group.this.name
  sensitive = false
}

output "SELF_HOSTED_GW_CLIENT_ID" {
  value     = azuread_service_principal.self_hosted.client_id
  sensitive = false
}

# Uncomment to output the client secret
# output "SELF_HOSTED_GW_CLIENT_SECRET" {
#   value     = azuread_service_principal_password.self_hosted.value
#   sensitive = true
# }