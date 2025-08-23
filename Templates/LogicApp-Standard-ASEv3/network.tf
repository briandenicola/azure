data "azurerm_virtual_network" "this" {
  name                = "${var.ase_app_name}-network"
  resource_group_name = local.ase_rg_name
}

data "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoints"
  resource_group_name  = local.ase_rg_name
  virtual_network_name = data.azurerm_virtual_network.this.name
}