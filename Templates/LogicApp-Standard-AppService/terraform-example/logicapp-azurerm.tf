# Error: Error: creating Logic App Standard: (Site Name "muskrat-24768-workflow" / Resource Group "muskrat-24768_rg"): 
#        web.AppsClient#CreateOrUpdate: Failure sending request: StatusCode=0 -- Original Error: autorest/azure: Service returned an error. Status=<nil> <nil>
# Details: "Code":"Conflict","Message":"Cannot modify this site because another operation is in progress.
#           Details: Id: befd9c0a-7854-47b9-8df9-9aa292940519, OperationName: Create, CreatedTime: 9/6/2024 4:11:07 PM, RequestId: 3096cd20-4698-4f78-af41-dafcfe06e81b, EntityType: 3",
#           "Target":null,"Details":[{"Message":"Cannot modify this site because another operation is in progress. 
#           Details: Id: befd9c0a-7854-47b9-8df9-9aa292940519, OperationName: Create, CreatedTime: 9/6/2024 4:11:07 PM, RequestId: 3096cd20-4698-4f78-af41-dafcfe06e81b, EntityType: 3"},
#           {"Code":"Conflict"},{"ErrorEntity":{"ExtendedCode":"59203","MessageTemplate":"Cannot modify this site because another operation is in progress. Details: {0}"

# resource "azurerm_logic_app_standard" "this" {
#   depends_on = [
#     azurerm_role_assignment.storage_data_reader,
#     azurerm_role_assignment.storage_queue_data_contributor,
#     azurerm_role_assignment.storage_table_data_contributor,
#     azurerm_role_assignment.storage_account_contributor
#   ]

#   name                       = local.logic_app_name
#   location                   = azurerm_resource_group.this.location
#   resource_group_name        = azurerm_resource_group.this.name
#   app_service_plan_id        = azurerm_service_plan.this.id
#   storage_account_name       = azurerm_storage_account.this.name
#   storage_account_access_key = azurerm_storage_account.this.primary_access_key

#   identity {
#     type = "UserAssigned"
#     identity_ids = [
#       azurerm_user_assigned_identity.this.id
#     ]
#   }

#   app_settings = {
#     "FUNCTIONS_WORKER_RUNTIME"     = "node"
#     "FUNCTIONS_EXTENSION_VERSION"  = "~4"
#     "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
#     "WEBSITE_RUN_FROM_PACKAGE"     = 1
#     "AzureWebJobsStorage__accountName"     = azurerm_storage_account.this.name
#     "AzureWebJobsStorage__clientId"        = azurerm_user_assigned_identity.this.client_id
#     "AzureWebJobsStorage__queueServiceUri" = "https://${azurerm_storage_account.this.name}.queue.core.windows.net"
#     "AzureWebJobsStorage__tableServiceUri" = "https://${azurerm_storage_account.this.name}.table.core.windows.net"
#     "AzureWebJobsStorage__blobServiceUri"  = "https://${azurerm_storage_account.this.name}.blob.core.windows.net"
#   }
# }