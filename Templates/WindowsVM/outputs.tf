output "RESOURCE_GROUP" {
    value = azurerm_resource_group.this.name
    sensitive = false
}

output "VM_NAME" {
    value = azurerm_virtual_network.this.name
    sensitive = false
}

output "admin_password" {
    value = random_password.password.result
    sensitive = true
}