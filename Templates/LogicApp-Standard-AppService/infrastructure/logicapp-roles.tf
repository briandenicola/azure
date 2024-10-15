# #System Identity Roles
resource "azurerm_role_assignment" "storage_account_contributor_system_identity" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Account Contributor"
  principal_id                     = azapi_resource.this.identity.0.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "storage_data_reader_system_identity" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Blob Data Owner"
  principal_id                     = azapi_resource.this.identity.0.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "storage_queue_data_contributor_system_identity" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Queue Data Contributor"
  principal_id                     = azapi_resource.this.identity.0.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "storage_table_data_contributor_system_identity" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Table Data Contributor"
  principal_id                     = azapi_resource.this.identity.0.principal_id
  skip_service_principal_aad_check = true
}

#MSI Identity Roles

resource "azurerm_role_assignment" "storage_account_contributor_msi_identity" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Account Contributor"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "storage_data_reader_msi_identity" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Blob Data Owner"
  principal_id                     =azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "storage_queue_data_contributor_msi_identity" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Queue Data Contributor"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "storage_table_data_contributor_msi_identity" {
  scope                            = azurerm_storage_account.this.id
  role_definition_name             = "Storage Table Data Contributor"
  principal_id                     = azurerm_user_assigned_identity.this.principal_id
  skip_service_principal_aad_check = true
}

