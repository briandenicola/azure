locals {
  subnets     = [for region in var.regions : cidrsubnet("10.0.0.0/8", 8, index(var.regions, region) + 137)]
  regions_set = toset(var.regions)
}

resource "azurerm_virtual_network" "this" {
  for_each            = local.regions_set
  name                = "${local.resource_name}-${each.key}-network"
  address_space       = [local.subnets[index(var.regions, each.key)]]
  location            = each.key
  resource_group_name = azurerm_resource_group.this[each.key].name
}

resource "azurerm_subnet" "private-endpoints" {
  for_each             = local.regions_set
  name                 = "private-endpoints"
  resource_group_name  = azurerm_resource_group.this[each.key].name
  virtual_network_name = azurerm_virtual_network.this[each.key].name
  address_prefixes     = [cidrsubnet(local.subnets[index(var.regions, each.key)], 8, 5)]
}

resource "azurerm_network_security_group" "this" {
  for_each            = local.regions_set
  name                = "${local.resource_name}-${each.key}-nsg"
  location            = each.key
  resource_group_name = azurerm_resource_group.this[each.key].name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = local.regions_set
  subnet_id                 = azurerm_subnet.private-endpoints[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
