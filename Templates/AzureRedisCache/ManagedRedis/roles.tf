resource "azurerm_role_assignment" "this" {
  scope                            = azurerm_key_vault.this.id
  role_definition_name             = "Key Vault Crypto Service Encryption User"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "data_admin" {
  scope                            = azurerm_key_vault.this.id
  role_definition_name             = "Key Vault Data Access Administrator"
  principal_id                     = data.azurerm_client_config.current.object_id
  }

resource "azurerm_role_assignment" "admin" {
  scope                            = azurerm_key_vault.this.id
  role_definition_name             = "Key Vault Administrator"
  principal_id                     = data.azurerm_client_config.current.object_id
}