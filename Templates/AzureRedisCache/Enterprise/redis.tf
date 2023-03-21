resource "azurerm_redis_enterprise_cluster" "primary" {
  name                = "${local.redis_name}-1"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  zones               = [1, 2, 3]
  sku_name            = "Enterprise_E20-4"
}

resource "azurerm_monitor_diagnostic_setting" "primary" {
  name                       = "${local.redis_name}-diag"
  target_resource_id         = azurerm_redis_enterprise_cluster.primary.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_private_endpoint" "primary" {
  name                = "${local.redis_name}-1-endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.private-endpoints.id

  private_service_connection {
    name                           = "${local.redis_name}-1-endpoint"
    private_connection_resource_id = azurerm_redis_enterprise_cluster.primary.id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net.name
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net.id]
  }
}

resource "azurerm_redis_enterprise_cluster" "secondary" {
  name                = "${local.redis_name}-2"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  zones               = [1, 2, 3]
  sku_name            = "Enterprise_E20-4"
}

resource "azurerm_monitor_diagnostic_setting" "secondary" {
  name                       = "${local.redis_name}-diag"
  target_resource_id         = azurerm_redis_enterprise_cluster.secondary.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_private_endpoint" "secondary" {
  name                = "${local.redis_name}-2-endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.private-endpoints.id

  private_service_connection {
    name                           = "${local.redis_name}-2-endpoint"
    private_connection_resource_id = azurerm_redis_enterprise_cluster.secondary.id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net.name
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net.id]
  }
}

resource "azurerm_redis_enterprise_database" "this" {
  name                = "default"
  resource_group_name = azurerm_resource_group.this.name

  cluster_id        = azurerm_redis_enterprise_cluster.primary.id
  client_protocol   = "Encrypted"
  clustering_policy = "EnterpriseCluster"
  eviction_policy   = "AllKeysRandom"
  port              = 10000

  module {
    name = "RediSearch"
  }

  linked_database_id = [
    "${azurerm_redis_enterprise_cluster.primary.id}/databases/default",
    "${azurerm_redis_enterprise_cluster.secondary.id}/databases/default"
  ]

  linked_database_group_nickname = "TestRedisCluster"
}



