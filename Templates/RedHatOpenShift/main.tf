data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

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

resource "random_integer" "vnet_cidr" {
  min = 10
  max = 250
}

resource "random_integer" "services_cidr" {
  min = 64
  max = 90
}

resource "random_integer" "pod_cidr" {
  min = 91
  max = 127
}

locals {
  location            = var.region
  resource_name       = "${random_pet.this.id}-${random_id.this.dec}"
  aro_name            = replace("${local.resource_name}-aro", "-", "")
  vnet_cidr           = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  master_subnet_cidir = cidrsubnet(local.vnet_cidr, 8, 2)
  worker_subnet_cidir = cidrsubnet(local.vnet_cidr, 7, 2)
  resource_group_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_name}_aro_rg"
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application = "tbd"
    Components  = "aro"
    DeployedOn  = timestamp()
  }
}