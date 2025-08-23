resource "azurerm_private_dns_zone" "privatelink_redisenterprise_cache_azure_net" {
  name                = "privatelink.redisenterprise.cache.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_redisenterprise_cache_azure_net" {
  for_each              = local.regions_set
  name                  = "${local.resource_name}-${each.key}-link"
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this[each.key].id
}
