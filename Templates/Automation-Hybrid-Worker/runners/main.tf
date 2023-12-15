data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://checkip.amazonaws.com/"
}

resource "random_id" "this" {
  byte_length = 2
}

resource "random_uuid" "id" {
  count = var.number_of_runners
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
    resource_name               = var.app_name
    automation_name             = "${local.resource_name}-automation"
    vm_name                     = "${local.resource_name}-${random_id.this.dec}-worker"
    worker_group_name           = "${local.automation_name}-workers"
    powershell_install_file     = "powershell_7.4.0-1.deb_amd64.deb"
    powershell_install_uri      = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/${local.powershell_install_file}"
    powershell_install_script   = "sudo apt update && sudo apt install -y wget && wget ${local.powershell_install_uri} && sudo dpkg -i ${local.powershell_install_file} && sudo apt-get install -f && rm -f ${local.powershell_install_file}"
}

data "azurerm_resource_group" "automation_rg" {
  name                  = "${local.resource_name}_rg"
}

resource "azurerm_resource_group" "this" {
  name                  = "${local.resource_name}-runners-${random_id.this.dec}_rg"
  location              = data.azurerm_resource_group.automation_rg.location
  
  tags     = {
    Application = "Hybrid Worker Automation Demo"
    Components  = "Azure Automation; Azure Virtual Machines"
    DeployedOn  = timestamp()
    ExpiresOn   = timeadd(timestamp(), "168h") #7 days
  }
}
