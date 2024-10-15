# Overview

Create a keyless Azure Logic Apps Standard Environment. This will deploy Logic Apps without a Azure Files dependency.

## Prerequisites
* Azure CLI
* Azure Subscription
* [Task](https://taskfile.dev/#/installation)

# Instrastructure Deployment
## Automated Steps
```bash
    task up
    task connection
``` 

## Manual Steps
* Log into the Azure Portal.
* Navigate to the Logic App API Connection (azureblob).
* Click Settings > Access Policies
* Add 
* Select the System Managed Identity of your Workflow. It will be something like peacock-52212-workflow-001
* Click Save
* Click Overview
* Revoke Keys

## Workflow Deployment
```bash
    task publish
``` 

## Validate
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