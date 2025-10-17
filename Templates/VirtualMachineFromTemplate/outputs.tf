output "RESOURCE_GROUP" {
    value = azurerm_resource_group.vm.name
    sensitive = false
}

output "VM_NAME" {
    value = azurerm_linux_virtual_machine.this.name
    sensitive = false
}
