data "azurerm_private_dns_zone" "privatelink_blob_core_windows_net" {
  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}