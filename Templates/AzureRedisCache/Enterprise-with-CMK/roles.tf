# resource "azurerm_role_assignment" "this" {
#   scope                            = azurerm_key_vault.this.id
#   role_definition_name             = "Key Vault Crypto Service Encryption User"
#   principal_id                     = azurerm_user_assigned_identity.this.principal_id
#   skip_service_principal_aad_check = true
# }

# resource "azurerm_role_assignment" "data_admin" {
#   scope                            = azurerm_key_vault.this.id
#   role_definition_name             = "Key Vault Data Access Administrator"
#   principal_id                     = data.azurerm_client_config.current.object_id
#   skip_service_principal_aad_check = true
# }

# resource "azurerm_role_assignment" "admin" {
#   scope                            = azurerm_key_vault.this.id
#   role_definition_name             = "Key Vault Administrator"
#   principal_id                     = data.azurerm_client_config.current.object_id
#   skip_service_principal_aad_check = true
# }

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.this.principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey"
  ]

}

resource "azurerm_key_vault_access_policy" "admin" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Backup", 
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
    "Release",
    "Rotate",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
}