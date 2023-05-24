# Overview 

Some APIs and services in Microsoft Graph are metered and require payment for use. For a current list of APIs that require payment, see Metered APIs and services in Microsoft Graph.

To consume metered APIs and services in Microsoft Graph, the application registration for the Azure Active Directory application that consumes the APIs must be associated with an Azure subscription. This subscription will be billed for any metered charges. This association also allows you to use Azure Cost Management + Billing to understand and manage the costs of the application.

Currently the AzureRM provider does not support Graph Services so this method uses the Terraform AzAPI provider to create the resource

## Reference
https://learn.microsoft.com/en-us/graph/metered-api-setup?tabs=azurecloudshell#enable-an-application
https://learn.microsoft.com/en-us/rest/api/graphservices/account/create-and-update?tabs=HTTP

# Deploy
```bash
az login --scope https://graph.microsoft.com/.default #Requires the ability to create Azure AD Service Principals 
task up 
task: [up] terraform -chdir=./infrastructure workspace new southcentralus || true
task: [up] terraform -chdir=./infrastructure workspace select southcentralus
task: [up] terraform -chdir=./infrastructure init
....
Apply complete! Resources: 1 added, 1 changed, 0 destroyed.

Outputs:

AAD_SPN_CLIENT_ID = "1331dd05-af87-4143-9a0b-71136d0703fc"
APP_NAME = "blowfish-61667"
APP_RESOURCE_GROUP = "blowfish-61667_rg"
VALIDATION_URL = "https://management.azure.com/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/blowfish-61667_rg/providers/Microsoft.GraphServices/accounts/blowfish-61667-account?api-version=2022-09-22-preview"
```

# Validate
```bash
task validate
task: [validate] source ./scripts/setup-env.sh ; az rest --method get --url ${VALIDATION_URL}
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/blowfish-61667_rg/providers/Microsoft.GraphServices/accounts/blowfish-61667-account",
  "location": "global",
  "name": "blowfish-61667-account",
  "properties": {
    "appId": "1331dd05-af87-4143-9a0b-71136d0703fc",
    "billingPlanId": "1111111-aaaa-1111-bbbb-1111111111111"
  },
  "type": "microsoft.graphservices/accounts"
}
```