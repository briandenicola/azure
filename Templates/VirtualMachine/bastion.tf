resource "azurerm_bastion_host" "this" {
  depends_on = [ 
    azurerm_subnet_network_security_group_association.compute,
    azurerm_subnet_network_security_group_association.pe,
    azurerm_nat_gateway.this,
    azurerm_linux_virtual_machine.this
  ]
  name                = local.bastion_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  sku                 = "Developer"
  virtual_network_id  = azurerm_virtual_network.this.id 
}
