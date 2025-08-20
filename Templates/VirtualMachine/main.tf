
locals {
  location             = var.region
  non_az_regions       = ["northcentralus", "canadaeast", "westcentralus", "westus"]
  resource_name        = "${random_pet.this.id}-${random_id.this.dec}"
  vm_name              = "${local.resource_name}-vm"
  bastion_name         = "${local.resource_name}-bastion"
  nat_name             = "${local.resource_name}-nat"
  vnet_name            = "${local.resource_name}-network"
  sdlc_environment     = "Development"
  vm_sku               = var.vm_type == "Windows" ? var.windows_sku : var.linux_sku
  zone                 = contains(local.non_az_regions, local.location) ? null : random_integer.zone.result
}


