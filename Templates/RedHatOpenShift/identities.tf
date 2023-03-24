resource "azuread_application" "this" {
  display_name = "${local.aro_name}-identity"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "this" {
  application_id               = azuread_application.this.application_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_application_password" "this" {
  display_name          = "default"
  application_object_id = azuread_application.this.object_id
}