resource "azapi_resource" "this" {
  depends_on = [
    azurerm_role_assignment.storage_data_reader_managed_identity,
    azurerm_role_assignment.storage_queue_data_contributor_managed_identity,
    azurerm_role_assignment.storage_account_contributor_managed_identity
  ]

  type      = "Microsoft.Web/sites@2022-09-01"
  name      = "${local.logic_app_name}-001"
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  body = jsonencode({
    kind = "workflowapp,functionapp"
    properties = {
      serverFarmId = azurerm_service_plan.this.id
      siteConfig = {
        appSettings = [
          {
            name  = "APP_KIND"
            value = "workflowApp"
          },
          {
            name  = "AzureFunctionsJobHost__extensionBundle__id"
            value = "Microsoft.Azure.Functions.ExtensionBundle.Workflows"
          },
          {
            name = "AzureFunctionsJobHost__extensionBundle__version"
            value = "[4.0.0, 5.0.0)" #"[1.*, 2.0.0)"
          },          
          {
            name  = "FUNCTIONS_WORKER_RUNTIME"
            value = "node"
          },
          {
            name  = "FUNCTIONS_EXTENSION_VERSION"
            value = "~4"
          },
          {
            name  = "WEBSITE_NODE_DEFAULT_VERSION"
            value = "~18"
          },

          {
            name  = "WEBSITE_RUN_FROM_PACKAGE"
            value = "1"
          },
          {
            name  = "AzureWebJobsStorage__accountName"
            value = azurerm_storage_account.this.name
          },
          {
            name  = "APPINSIGHTS_INSTRUMENTATIONKEY"
            value = azurerm_application_insights.this.instrumentation_key
          },
          {
            name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
            value = azurerm_application_insights.this.connection_string
          },
          {
            name  = "AzureWebJobsStorage__queueServiceUri"
            value = "https://${azurerm_storage_account.this.name}.queue.core.windows.net"
          },
          {
            name  = "AzureWebJobsStorage__tableServiceUri"
            value = "https://${azurerm_storage_account.this.name}.table.core.windows.net"
          },
          {
            name  = "AzureWebJobsStorage__blobServiceUri"
            value = "https://${azurerm_storage_account.this.name}.blob.core.windows.net"  
          }                                                   
        ]
      }
      clientAffinityEnabled = false
    }
  })
}
