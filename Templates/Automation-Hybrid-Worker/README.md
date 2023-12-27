# Azure Automation Hybrid Worker Demo 

## Overview 
Azure Automation is a service that allows you to automate tasks in Azure. Azure Automation allows you to run runbooks in the cloud or on-premises. It is a standard command-and-control architecture, where the Azure Automation service sends jobs to workers. The workers performs the jobs.  Sometimes these jobs require access to Azure resources that are not accessible from the public internet. In this case, you can use a Hybrid Worker. 

A Hybrid Worker is a virtual machine that is deployed in your Azure subscription. The Hybrid Worker is registered with the Azure Automation service. 

This demo shows how to deploy a disposalable Hybrid Workers using Terraform and Packer without any interaction with the actual virtual machines.  All software is installed via Cloud Init and the Hybrid Worker is registered with the Azure Automation service using the Azure Automation VM Extension.

## Components
Component | Usage
------ | ------
Azure Automation | Automation Account for Runbooks 
Azure Virtual Machine | Hybrid Workers
Azure Virtual Network | Virtual Network for Hybrid Workers

## Architecture
![Architecture](./.assets/Architecture.png)

## Prerequisite 
* A Linux machine or Windows Subsytem for Linux or Docker for Windows 
* Azure Cli and an Azure Subscription
* Terraform 
* [Task](https://taskfile.dev/#/installation)
* Azure subscription with Owner access permissions

# Setup
### Azure Infrastructure 
```bash
az login
task up -- southcentralus
```
### Azure Virtual Machines
```bash
az login
task runners -- {APP_NAME} # APP_NAME is the name of the Azure Automation Account from the previous step
```

### Azure Golden Image
```bash
az login
task packer -- {APP_NAME} # APP_NAME is the name of the Azure Automation Account from the previous step
```

### Deploy Azure Automation Environment
```bash
az login
task down
```

## Validate 
* Login in to the Azure Portal and navigate to the Azure Automation Account
* Click on the **Runbooks** blade and click on the **Test Pane** for the **print-host-info** runbook
* Select **Hybrid Workers**. Click on **Start**. Wait for the runbook to complete
* Click on the **Output** tab to see the output of the runbook. Validate that it ran on one of the Hybrid Workers
