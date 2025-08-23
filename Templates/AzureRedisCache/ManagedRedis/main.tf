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

resource "random_integer" "vnet_cidr" {
  min = 10
  max = 250
}

locals {
  location            = var.region
  resource_name       = "${random_pet.this.id}-${random_id.this.dec}"
  kv_name             = "${local.resource_name}-kv"
  vnet_name           = "${local.resource_name}-network"
  cache_name          = "${local.resource_name}-cache"
  cache_identity_name = "${local.resource_name}-identity"
  kek_name            = "${local.resource_name}-cache-kek"
  redis_database_name = "default"
  cache_sku           = "Balanced_B0"
  nsg_name            = "${local.resource_name}-nsg"
  vnet_cidr           = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  pe_subnet_cidr      = cidrsubnet(local.vnet_cidr, 8, 1)
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application = var.tags
    Components  = "Azure Redis Cache; KeyVault"
    DeployedOn  = timestamp()
  }
}
