resource "azurerm_logic_app_standard" "this" {
  # depends_on = [
  #   azurerm_private_endpoint.blob_private_endpoint,
  #   azurerm_private_endpoint.table_private_endpoint,
  #   azurerm_private_endpoint.queue_private_endpoint,
  # ]
  depends_on = [
    azurerm_role_assignment.storage_data_reader,
    azurerm_role_assignment.storage_queue_data_contributor,
    azurerm_role_assignment.storage_table_data_contributor
  ]

  name                       = local.logic_app_name
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  app_service_plan_id        = azurerm_app_service_plan.this.id
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
    "FUNCTIONS_EXTENSION_VERSION"  = "~4"
    "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
    "WEBSITE_RUN_FROM_PACKAGE"     = 1
    "AzureWebJobsStorage__accountName"     = azurerm_storage_account.this.name
    "AzureWebJobsStorage__clientId"        = azurerm_user_assigned_identity.this.client_id
    "AzureWebJobsStorage__queueServiceUri" = "https://${azurerm_storage_account.this.name}.queue.core.windows.net"
    "AzureWebJobsStorage__tableServiceUri" = "https://${azurerm_storage_account.this.name}.table.core.windows.net"
    "AzureWebJobsStorage__blobServiceUri"  = "https://${azurerm_storage_account.this.name}.blob.core.windows.net"
  }
}
