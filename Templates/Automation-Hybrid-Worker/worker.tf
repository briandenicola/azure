resource "azurerm_network_interface" "this" {
  count               = var.number_of_runners
  name                = "${local.vm_name}-${count.index}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = local.vm_name
    subnet_id                     = azurerm_subnet.servers.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  count               = var.number_of_runners
  name                = "${local.vm_name}-${count.index}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  admin_username      = "manager"
  size                = var.vm_sku

  network_interface_ids = [
    azurerm_network_interface.this[count.index].id,
  ]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  admin_ssh_key {
    username   = "manager"
    public_key = tls_private_key.rsa.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${local.vm_name}-${count.index}-osdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "this" {
    count                = var.number_of_runners
    name                 = "${local.vm_name}-${count.index}"
    virtual_machine_id   = azurerm_linux_virtual_machine.this[count.index].id
    publisher            = "Microsoft.Azure.Automation.HybridWorker"
    type                 = "HybridWorkerForLinux"
    type_handler_version = "1.1"
    automatic_upgrade_enabled = true
    auto_upgrade_minor_version = true

    settings = <<SETTINGS
    {
        "AutomationAccountURL": "${azurerm_automation_account.this.hybrid_service_url}"
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "powershell" {
  count                = var.number_of_runners
  name                 = "powershell-install"
  virtual_machine_id   = azurerm_linux_virtual_machine.this[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute":"${local.powershell_install_script}"
 }
SETTINGS

}
