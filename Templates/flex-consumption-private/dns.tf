locals {
  private_dns_zones = {
    blob  = "privatelink.blob.core.windows.net"
    sites = "privatelink.azurewebsites.net"
  }
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each               = local.private_dns_zones
  name                   = "${each.key}-link"
  resource_group_name    = azurerm_resource_group.this.name
  private_dns_zone_name  = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id     = azurerm_virtual_network.this.id
  registration_enabled   = false
}
