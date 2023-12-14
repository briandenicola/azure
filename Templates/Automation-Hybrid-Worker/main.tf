data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://checkip.amazonaws.com/"
}

resource "random_id" "this" {
  byte_length = 2
}

resource "random_pet" "this" {
  length = 1
  separator  = ""
}

resource "random_uuid" "id" {
  count = var.number_of_runners
}

resource "random_integer" "vnet_cidr" {
  min = 10
  max = 250
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
    location                    = var.region
    resource_name               = "${random_pet.this.id}-${random_id.this.dec}"
    automation_name             = "${local.resource_name}-automation"
    vm_name                     = "${local.resource_name}-worker"
    vnet_cidr                   = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
    pe_subnet_cidir             = cidrsubnet(local.vnet_cidr, 8, 2)
    servers_subnet_cidir        = cidrsubnet(local.vnet_cidr, 8, 3)
    powershell_install_file     = "powershell_7.4.0-1.deb_amd64.deb"
    powershell_install_uri      = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/${local.powershell_install_file}"
    powershell_install_script   = "sudo apt update && sudo apt install -y wget && wget ${local.powershell_install_uri} && sudo dpkg -i ${local.powershell_install_file} && sudo apt-get install -f && rm -f ${local.powershell_install_file}"
}


resource "azurerm_resource_group" "this" {
  name                  = "${local.resource_name}_rg"
  location              = local.location
  
  tags     = {
    Application = "Hybrid Worker Automation"
    Components  = "Azure Automation; Azure Virtual Machine"
    DeployedOn  = timestamp()
  }
}
