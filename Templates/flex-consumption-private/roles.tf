# Grants the Function App's user-assigned identity data-plane access to the
# deployment storage account, since shared keys are disabled on the account.
resource "azurerm_role_assignment" "function_user_assigned_storage_blob_owner" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "function_user_assigned_storage_queue_owner" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

resource "azurerm_role_assignment" "function_identity_storage_blob_owner" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_function_app_flex_consumption.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "function_identity_storage_queue_owner" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_function_app_flex_consumption.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "deployer_storage_blob_owner" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "deployer_storage_queue_owner" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Azure RBAC assignments can take up to a couple of minutes to propagate; without this,
# the container create call below can still race ahead and hit a 403.
resource "time_sleep" "wait_for_deployer_rbac" {
  depends_on      = [azurerm_role_assignment.deployer_storage_blob_owner]
  create_duration = "90s"
}
