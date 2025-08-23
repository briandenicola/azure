resource "azurerm_private_dns_zone" "privatelink_blob_core_windows_net" {
  name                      = "privatelink.blob.core.windows.net"
  resource_group_name       = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_blob_core_windows_net" {
  name                      = "${data.azurerm_virtual_network.this.name}-link"
  private_dns_zone_name     = azurerm_private_dns_zone.privatelink_blob_core_windows_net.name
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_id        = data.azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone" "privatelink_file_core_windows_net" {
  name                      = "privatelink.file.core.windows.net"
  resource_group_name       = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_file_core_windows_net" {
  name                      = "${data.azurerm_virtual_network.this.name}-link"
  private_dns_zone_name     = azurerm_private_dns_zone.privatelink_file_core_windows_net.name
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_id        = data.azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone" "privatelink_table_core_windows_net" {
  name                      = "privatelink.table.core.windows.net"
  resource_group_name       = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_table_core_windows_net" {
  name                      = "${data.azurerm_virtual_network.this.name}-link"
  private_dns_zone_name     = azurerm_private_dns_zone.privatelink_table_core_windows_net.name
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_id        = data.azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone" "privatelink_queue_core_windows_net" {
  name                      = "privatelink.queue.core.windows.net"
  resource_group_name       = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_queue_core_windows_net" {
  name                      = "${data.azurerm_virtual_network.this.name}-link"
  private_dns_zone_name     = azurerm_private_dns_zone.privatelink_queue_core_windows_net.name
  resource_group_name       = azurerm_resource_group.this.name
  virtual_network_id        = data.azurerm_virtual_network.this.id
}