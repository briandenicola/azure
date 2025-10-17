resource "azurerm_network_interface" "this" {
  name                = "${local.vm_name}-nic"
  location            = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_definition.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}