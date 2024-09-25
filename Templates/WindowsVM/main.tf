
resource "random_id" "this" {
  byte_length = 2
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

locals {
  location             = var.region
  resource_name        = "${random_pet.this.id}-${random_id.this.dec}"
  vm_name              = "${local.resource_name}-vm"
  bastion_name         = "${local.resource_name}-bastion"
  nat_name             = "${local.resource_name}-nat"
  vnet_name            = "${local.resource_name}-network"
  sdlc_environment     = "Development"
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application = var.tags
    Components  = "Windows Virtual Machine; Virtual Network; NAT Gateway; Azure Bastion"
    Environment = local.sdlc_environment
    DeployedOn  = timestamp()
  }
}
