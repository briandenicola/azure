resource "azurerm_linux_virtual_machine" "this" {
  name                  = local.vm_name
  resource_group_name   = azurerm_resource_group.vm.name
  location              = azurerm_resource_group.vm.location
  size                  = var.vm_definition.sku
  admin_username        = "manager"
  zone                  = local.zone
  provision_vm_agent    = true
  
  admin_ssh_key {
    username   = "manager"
    public_key = file(var.vm_definition.public_key_openssh)
  }

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
    name                 = "${local.vm_name}-osdisk"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this.id,
      var.vm_definition.identity_id
    ]
  }

  source_image_id = var.vm_definition.source_image_id
}
