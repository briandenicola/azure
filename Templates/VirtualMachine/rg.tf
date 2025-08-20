resource "azurerm_resource_group" "vm" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application = var.tags
    Components  = "${var.vm_type} Virtual Machine; Managed Identity; Managed Disk"
    zone        = "Zone - ${local.zone == null ? "none" : tostring(local.zone)}"
    Environment = local.sdlc_environment
    DeployedOn  = timestamp()
  }
}

resource "azurerm_resource_group" "network" {
  name     = "${local.resource_name}_network_rg"
  location = local.location

  tags = {
    Application = var.tags
    Components  = "Virtual Network; NAT Gateway; Azure Bastion"
    Environment = local.sdlc_environment
    DeployedOn  = timestamp()
  }
}