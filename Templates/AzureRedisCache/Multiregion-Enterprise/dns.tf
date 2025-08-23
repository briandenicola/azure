resource "azurerm_private_dns_zone" "privatelink_redisenterprise_cache_azure_net" {
  for_each              = local.regions_set
  name                  = "privatelink.redisenterprise.cache.azure.net"
  resource_group_name   = azurerm_resource_group.this[each.key].name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_redisenterprise_cache_azure_net" {
  for_each              = local.regions_set
  name                  = "${local.resource_name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net[each.key].name
  resource_group_name   = azurerm_resource_group.this[each.key].name
  virtual_network_id    = azurerm_virtual_network.this[each.key].id
}

#Manually add DNS records for Redis Enterprise Cluster in Region 1 to Region 2 DNS Zone
resource "azurerm_private_dns_a_record" "redis_region_1_in_region_2_dns" {
  name                = "${azurerm_redis_enterprise_cluster.this[element(var.regions, 0)].name}.${element(var.regions, 0)}"
  zone_name           = azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net[element(var.regions, 1)].name
  resource_group_name = azurerm_resource_group.this[element(var.regions, 1)].name
  ttl                 = 300
  records             = [azurerm_private_endpoint.this[element(var.regions, 0)].private_service_connection[0].private_ip_address]
}

#Manually add DNS records for Redis Enterprise Cluster in Region 2 to Region 1 DNS Zone
resource "azurerm_private_dns_a_record" "redis_region_2_in_region_1_dns" {
  name                = "${azurerm_redis_enterprise_cluster.this[element(var.regions, 1)].name}.${element(var.regions, 1)}"
  zone_name           = azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net[element(var.regions, 0)].name
  resource_group_name = azurerm_resource_group.this[element(var.regions, 0)].name
  ttl                 = 300
  records             = [azurerm_private_endpoint.this[element(var.regions, 1)].private_service_connection[0].private_ip_address]
}
