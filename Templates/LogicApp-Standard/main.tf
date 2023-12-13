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
  min = 25
  max = 250
}

locals {
  location                  = data.azurerm_app_service_environment_v3.this.location
  resource_name             = "${random_pet.this.id}-${random_id.this.dec}"
  ase_name                  = "${var.ase_app_name}-ase"
  ase_rg_name               = "${var.ase_app_name}_rg"
  storage_account_name_name = "${replace(local.resource_name,"-","")}sa"
  logic_app_name            = "${local.resource_name}-workflow"
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application = "Logic App Standard"
    Components  = "ase; logic apps;"
    DeployedOn  = timestamp()
  }
}
