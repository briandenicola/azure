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


locals {
  location      = var.region
  resource_name = "${random_pet.this.id}-${random_id.this.dec}"
  sa_name       = "${replace(local.resource_name, "-", "")}sa"
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Components = "storage"
    DeployedOn = timestamp()
    Deployer   = data.azurerm_client_config.current.object_id
  }
}
