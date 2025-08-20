resource "azurerm_linux_virtual_machine" "this" {
  count                 = var.vm_type == "Windows" ? 0 : 1
  name                  = local.vm_name
  resource_group_name   = azurerm_resource_group.vm.name
  location              = azurerm_resource_group.vm.location
  size                  = local.vm_sku
  admin_username        = "manager"
  zone                  = local.zone
  provision_vm_agent    = true
  patch_assessment_mode = "AutomaticByPlatform"
  patch_mode            = "AutomaticByPlatform"
  reboot_setting        = "IfRequired"

  admin_ssh_key {
    username   = "manager"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
    name                 = "${local.vm_name}-osdisk"

    diff_disk_settings {
      option    = "Local"
      placement = "CacheDisk"
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
