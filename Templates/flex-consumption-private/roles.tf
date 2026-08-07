# Grants the Function App's user-assigned identity data-plane access to the
# deployment storage account, since shared keys are disabled on the account.
resource "azurerm_role_assignment" "function_storage_blob_owner" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# The identity running `terraform apply` also needs data-plane RBAC, since with
# shared_access_key_enabled = false the provider's post-create blob service check and
# the azurerm_storage_container resource both authenticate as this caller via Azure AD
# (storage_use_azuread in providers.tf) rather than an account key.
resource "azurerm_role_assignment" "deployer_storage_blob_owner" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Azure RBAC assignments can take up to a couple of minutes to propagate; without this,
# the container create call below can still race ahead and hit a 403.
resource "time_sleep" "wait_for_deployer_rbac" {
  depends_on      = [azurerm_role_assignment.deployer_storage_blob_owner]
  create_duration = "90s"
}
