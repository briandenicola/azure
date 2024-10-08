resource "azurerm_public_ip" "linux" {
  for_each            = local.regions_set
  name                = "${local.resource_name}-${each.key}-pip"
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "linux" {
  for_each            = local.regions_set
  name                = "${local.resource_name}-${each.key}-nic"
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.compute[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each            = local.regions_set
  name                = "${local.resource_name}-${each.key}-vm"
  location            = azurerm_resource_group.this[each.key].location
  resource_group_name = azurerm_resource_group.this[each.key].name

  size                = local.vm_sku
  admin_username      = "manager"

  network_interface_ids = [
    azurerm_network_interface.linux[each.key].id,
  ]

  admin_ssh_key {
    username   = "manager"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${local.resource_name}-linux-osdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
