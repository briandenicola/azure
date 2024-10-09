
resource "random_id" "this" {
  byte_length = 1 
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

resource "random_integer" "zone" {
  min = 1
  max = 3
}

locals {
  location             = var.region
  resource_name        = "${random_pet.this.id}-${random_id.this.dec}"
  vm_name              = "${local.resource_name}-vm"
  bastion_name         = "${local.resource_name}-bastion"
  nat_name             = "${local.resource_name}-nat"
  vnet_name            = "${local.resource_name}-network"
  sdlc_environment     = "Development"
  vm_sku               = var.vm_type == "Windows" ? var.windows_sku : var.linux_sku
  zone                 = local.location == "northcentralus" ? null : random_integer.zone.result
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application = var.tags
    Components  = "${var.vm_type} Virtual Machine; Virtual Network; NAT Gateway; Azure Bastion"
    Environment = local.sdlc_environment
    DeployedOn  = timestamp()
  }
}
