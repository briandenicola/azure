data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://checkip.amazonaws.com/"
}

resource "random_id" "this" {
  byte_length = 2
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

resource "random_password" "password" {
  length  = 25
  special = true
}

resource "random_integer" "vnet_cidr" {
  min = 10
  max = 250
}

locals {
  location      = var.regions
  resource_name = "${random_pet.this.id}-${random_id.this.dec}"
}

resource "azurerm_resource_group" "this" {
  for_each = local.regions_set
  name     = "${local.resource_name}_${each.key}_rg"
  location = each.key

  tags = {
    Application = var.tags
    Components  = "Azure Enterpise Redis Cache, ${each.key}"
    DeployedOn  = timestamp()
  }
}
