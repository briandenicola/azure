resource "azurerm_redis_enterprise_cluster" "this" {
  for_each            = local.regions_set
  name                = "${local.resource_name}-cache"
  resource_group_name = azurerm_resource_group.this[each.key].name
  location            = each.key
  zones               = [1, 2, 3]
  sku_name            = "Enterprise_E20-4"
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each                   = local.regions_set
  name                       = "${local.resource_name}-${each.key}-diag"
  target_resource_id         = azurerm_redis_enterprise_cluster.this[each.key].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this[each.key].id

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_private_endpoint" "this" {
  for_each            = local.regions_set
  name                = "${local.resource_name}-endpoint"
  resource_group_name = azurerm_resource_group.this[each.key].name
  location            = each.key
  subnet_id           = azurerm_subnet.private-endpoints[each.key].id

  private_service_connection {
    name                           = "${local.resource_name}-endpoint"
    private_connection_resource_id = azurerm_redis_enterprise_cluster.this[each.key].id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net[each.key].name
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net[each.key].id]
  }
}

resource "azurerm_redis_enterprise_database" "this" {
  name                = "default"

  cluster_id        = azurerm_redis_enterprise_cluster.this[element(var.regions, 0)].id
  client_protocol   = "Encrypted"
  clustering_policy = "EnterpriseCluster"
  eviction_policy   = "NoEviction"
  port              = 10000

  module {
    name = "RediSearch"
  }

  linked_database_id = [
    "${azurerm_redis_enterprise_cluster.this[element(var.regions, 0)].id}/databases/default",
    "${azurerm_redis_enterprise_cluster.this[element(var.regions, 1)].id}/databases/default"
  ]

  linked_database_group_nickname = "TestRedisCluster"
}


