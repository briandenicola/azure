resource "azurerm_user_assigned_identity" "this" {
  name                = "${local.resource_name}-app-identity"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azapi_resource" "this" {

  type      = "Microsoft.Web/sites@2022-09-01"
  name      = "${local.logic_app_name}-001"
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }

  body = {
    kind = "workflowapp,functionapp"
    properties = {
      serverFarmId = azurerm_service_plan.this.id
      clientAffinityEnabled = false
      siteConfig = {
        functionsRuntimeScaleMonitoringEnabled = true
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
            value = "[1.*, 2.0.0)" 
          },          
          {
            name  = "FUNCTIONS_WORKER_RUNTIME"
            value = "dotnet"
          },
          {
            name  = "FUNCTIONS_EXTENSION_VERSION"
            value = "~4"
          },
          {
            name  = "WEBSITE_RUN_FROM_PACKAGE"
            value = "1"
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
            name  = "AzureWebJobsStorage__credential"
            value = "managedIdentity"
          },
          {
            name  = "AzureWebJobsStorage__managedIdentityResourceId"
            value = azurerm_user_assigned_identity.this.id
          },
          {
            name  = "AzureWebJobsStorage__accountName"
            value = azurerm_storage_account.this.name
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
          },
## Region: CreateBlob Workflow Required Variables 
          {
            name  = "Workflows.CreateBlob.OperationOptionsUri"
            value = "WithStatelessRunHistory"
          },
          {
            name  = "WORKFLOWS_SUBSCRIPTION_ID"
            value = data.azurerm_client_config.current.subscription_id
          },
          {
            name  = "WORKFLOWS_LOCATION_NAME"
            value = azurerm_resource_group.this.location
          },
          {
            name  = "WORKFLOWS_RESOURCE_GROUP_NAME"
            value = azurerm_resource_group.this.name
          },
          {
            name  = "WORKFLOWS_BLOB_STORAGE_ACCOUNT_NAME"
            value = azurerm_storage_account.test_account.name
          },          
          {
            name  = "BLOB_CONNECTION_RUNTIME_URL"
            value = "__REPLACE__ME__"
          },
## End Region
        ]
      }
    }
  }
}
