resource "azurerm_role_assignment" "storage_data_reader" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Blob Data Owner"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "storage_file_data_smb_contributor" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage File Data SMB Share Contributor"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "storage_queue_data_contributor" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Queue Data Contributor"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "storage_table_data_contributor" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Table Data Contributor"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}