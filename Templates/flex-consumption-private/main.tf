data "azurerm_client_config" "current" {}

# Deployer's public IP, used only during bootstrap (var.bootstrap = true) to scope the
# storage account's temporary network exception to this caller instead of the internet.
data "http" "myip" {
  url = "https://checkip.amazonaws.com/"
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
  location                = var.region
  resource_name           = "${random_pet.this.id}-${random_id.this.dec}"
  storage_name            = lower(substr(replace("st${random_pet.this.id}${random_id.this.dec}", "-", ""), 0, 24))
  my_ip                   = trimspace(data.http.myip.response_body)
  vnet_cidr               = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  integration_subnet_cidr = cidrsubnet(local.vnet_cidr, 8, 1)
  pe_subnet_cidr          = cidrsubnet(local.vnet_cidr, 8, 2)
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = merge(var.tags, {
    Components = "Function App (Flex Consumption, Private); Storage Account; VNet"
    DeployedOn = timestamp()
  })
}
