resource "azurerm_logic_app_standard" "this" {
  depends_on = [
    azurerm_private_endpoint.blob_private_endpoint,
    azurerm_private_endpoint.file_private_endpoint,
    azurerm_private_endpoint.table_private_endpoint,
    azurerm_private_endpoint.queue_private_endpoint,
  ]

  name                       = local.logic_app_name
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  app_service_plan_id        = data.azurerm_service_plan.app_service_plan_windows.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"     = "node"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
  }
}
