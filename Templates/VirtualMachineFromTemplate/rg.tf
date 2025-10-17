resource "azurerm_resource_group" "vm" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application = var.tags
    Components  = "${var.vm_definition.type} Virtual Machine; Managed Identity; Managed Disk"
    zone        = "Zone - ${local.zone == null ? "none" : tostring(local.zone)}"
    Environment = local.sdlc_environment
    DeployedOn  = timestamp()
  }
}