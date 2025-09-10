resource "azurerm_user_assigned_identity" "apim" {
  name                = "${local.apim_name}-identity"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azuread_application" "self_hosted" {
  display_name = "${local.apim_name}-self-hosted-identity"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "self_hosted" {
  client_id                    = azuread_application.self_hosted.client_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

# resource "azuread_service_principal_password" "self_hosted" {
#   service_principal_id = azuread_service_principal.self_hosted.id
#   end_date = formatdate("YYYY-MM-DD'T'HH:mm:ssZ", timeadd(timestamp(), "240h")) #10 days from now in RFC3339 format
# }
