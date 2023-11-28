output "RESOURCE_GROUP" {
    value = azurerm_resource_group.this.name
    sensitive = false
}

output "VM_PRIVATE_KEY" {
    value = tls_private_key.rsa.private_key_openssh
    sensitive = true
}