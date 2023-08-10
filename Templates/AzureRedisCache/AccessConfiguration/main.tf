data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "random_id" "this" {
  byte_length = 2
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

resource "random_uuid" "this" {
}

locals {
  location             = var.region
  resource_name        = "${random_pet.this.id}-${random_id.this.dec}"
  rg_name              = "${local.resource_name}_rg"
  redis_name           = "${local.resource_name}-cache"
  identity_name        = "${local.resource_name}-identity"
}

resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = local.location
}
