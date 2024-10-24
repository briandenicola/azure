resource "azurerm_managed_disk" "this" {
  count                = var.vm_type == "Windows" ? 1 : 0
  name                 = "${local.vm_name}-datadisk"
  location             = azurerm_resource_group.this.location
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "127"
}

resource "azurerm_windows_virtual_machine" "this" {
  count                 = var.vm_type == "Windows" ? 1 : 0
  name                  = local.vm_name
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  size                  = local.vm_sku
  admin_username        = "manager"
  admin_password        = random_password.password.result
  zone                  = local.zone
  provision_vm_agent    = true
  patch_assessment_mode = "AutomaticByPlatform"
  patch_mode            = "AutomaticByPlatform"
  reboot_setting        = "IfRequired"
  hotpatching_enabled   = true
  license_type          = "Windows_Server"

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
    name                 = "${local.vm_name}-osdisk"
    disk_size_gb         = 30
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
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-hotpatch-smalldisk"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = var.vm_type == "Windows" ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.this[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.this[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}
