data "azurerm_subnet" "private-endpoints" {
  name                 = "private-endpoints"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.virtual_network_resource_group_name
}