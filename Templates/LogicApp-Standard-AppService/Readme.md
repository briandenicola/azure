# Overview

Create a keyless Azure Logic Apps Standard Environment. This will deploy Logic Apps without a Azure Files dependency.

## Prerequisites
* Azure CLI
* Azure Subscription
* [Task](https://taskfile.dev/#/installation)

# Infrastructure
* The Azure resources are created using Terraform. They are all named with a prefix of ${random_pet}-${random_id}, leveraging providers from Terraform.
* By default, the resources are created in the Canada East region.
* The Logic Apps will have two identities
    * A User Managed Identity used to access the runtime Storage Account. This is required to standup a keyless Logic App environment
    * A System Managed Identity used by the API Connection and the Logic App Workflow to access a Test Storage Account. 

## Details 
Component | Name | Usage
------ | ------ | ------
Azure Storage Account | ${resource_name}sa | This Storage Account is used by the Logic App Runtime for state management.
Azure Storage Account |  ${resource_name}test | This Storage Account is used by the CreateBlob Workflow
Azure App Service Plan | ${resource_name}-windows-hosting | Windows-based App Service Plan to host the Logic App
Azure User Managed Identity |${resource_name}-app-identity | The User Managed Identity is used by the Logic App runtime to access the Storage Account
Azure Logic App | ${resource_name}-workflow-001 | The Logic App Standard Environment
Azure Log Analytics Workspace | ${resource_name}-logs | The Log Analytics Workspace is used by the App Insights to store logs
Azure Application Insight | ${resource_name}-appinsights | The Application Insights is used by the Logic App to storage application logs
Azure API Connection | azureblob | The managed connection used by the CreateBlob Logic App to access the Test Storage Account

## Deployment
### Automated Steps
```bash
    task up
    task connection
``` 

### Manual Steps
* Log into the Azure Portal.
* Navigate to the Logic App API Connection (azureblob).
* Click Settings > Access Policies
* Add 
* Select the System Managed Identity of your Workflow. It will be something like peacock-52212-workflow-001
* Click Save
* Click Overview
* Revoke Keys

# Workflow Deployment
```bash
    task publish
``` 

# Validate
* Navigate to the Logic App in the Azure Portal.
* Click Workflows> CreateBlob
* The Workflow runs every 2 minutes.  Confirm that the runs have been successful
* Navigate to the Test Storage Account in the Azure Portal.
* Click Containers > apps.
* Confirm that the test.log file has been created and that it has been updated.
* It should container 'This is an update at' and the current date.

# Clean Up
```bash
    task down
```