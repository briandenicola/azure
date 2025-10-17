
locals {
  location             = var.region
  non_az_regions       = ["northcentralus", "canadaeast", "westcentralus", "westus"]
  resource_name        = "${random_pet.this.id}-${random_id.this.dec}"
  vm_name              = "${local.resource_name}-vm"
  sdlc_environment     = "Development"
  zone                 = contains(local.non_az_regions, local.location) ? null : random_integer.zone.result
}


