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
  location                       = var.region
  resource_name                  = "${random_pet.this.id}-${random_id.this.dec}"
  app_service_name               = "${local.resource_name}-windows-hosting"
  storage_account_name_name      = "${replace(local.resource_name, "-", "")}sa"
  test_storage_account_name_name = "${replace(local.resource_name, "-", "")}test"
  logic_app_name                 = "${local.resource_name}-workflow"
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application = var.tags
    Components  = "App Servcie; Logic Apps; Functions Runtime; Storage"
    DeployedOn  = timestamp()
  }
}
