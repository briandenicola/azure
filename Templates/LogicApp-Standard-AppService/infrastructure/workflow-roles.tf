resource "azurerm_role_assignment" "test_storage_account_contributor_managed_identity" {
  scope                            = azurerm_storage_account.test_account.id
  role_definition_name             = "Storage Account Contributor"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "test_storage_data_reader_system_identity" {
  scope                            = azurerm_storage_account.test_account.id
  role_definition_name             = "Storage Blob Data Owner"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id 
  skip_service_principal_aad_check = true
}
