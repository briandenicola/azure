resource "azurerm_key_vault_key" "this" {
  depends_on = [ 
    azurerm_key_vault_access_policy.this,
    azurerm_key_vault_access_policy.admin
    #azurerm_role_assignment.this,
    #azurerm_role_assignment.data_admin,
    #azurerm_role_assignment.admin
  ]

  name         = local.kek_name
  key_vault_id = azurerm_key_vault.this.id
 
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

}