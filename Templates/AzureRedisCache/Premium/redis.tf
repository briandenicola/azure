resource "azurerm_redis_cache" "this" {
  name                          = local.redis_name
  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  capacity                      = 2
  family                        = "P"
  sku_name                      = "Premium"
  enable_non_ssl_port           = false
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
  redis_version                 = "6"
  shard_count                   = 3
  zones                         = [1, 2, 3]

  patch_schedule {
    day_of_week    = "Monday"
    start_hour_utc = 23
  }

  redis_configuration {
    aof_backup_enabled     = false
    enable_authentication  = true
    maxmemory_reserved     = 10
    maxmemory_delta        = 2
    maxmemory_policy       = "allkeys-lru"
    notify_keyspace_events = "A"
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "${local.redis_name}-diag"
  target_resource_id         = azurerm_redis_cache.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "ConnectedClientList"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_private_endpoint" "redis" {
  name                = "${local.redis_name}-endpoint"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = azurerm_subnet.private-endpoints.id

  private_service_connection {
    name                           = "${local.redis_name}-endpoint"
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.privatelink_redis_cache_windows_net.name
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_redis_cache_windows_net.id]
  }
}
