resource "azapi_resource" "cache" {
  depends_on = [
    azurerm_key_vault_key.this
  ]

  type      = "Microsoft.Cache/redisEnterprise@2023-11-01"
  name      = local.cache_name
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.this.id
    ]
  }

  body = jsonencode({
    properties = {
      minimumTlsVersion = "1.2"
    }
    sku = {
      capacity = 4
      name     = "Enterprise_E20"
    }
  })
}

resource "azapi_update_resource" "cache" {
  depends_on = [
    azapi_resource.cache
  ]

  type                    = "Microsoft.Cache/redisEnterprise@2023-11-01"
  resource_id             = azapi_resource.cache.id
  ignore_missing_property = true
  
  body = jsonencode({
    properties = {
      encryption = {
        customerManagedKeyEncryption = {
          keyEncryptionKeyIdentity = {
            identityType                   = "userAssignedIdentity"
            userAssignedIdentityResourceId = azurerm_user_assigned_identity.this.id
          }
          keyEncryptionKeyUrl = azurerm_key_vault_key.this.id
        }
      }
    }
  })
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  depends_on = [
    azapi_resource.cache
  ]
  name                       = "${local.cache_name}-diag"
  target_resource_id         = azapi_resource.cache.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  metric {
    category = "AllMetrics"
  }
}

# resource "azurerm_private_endpoint" "this" {
#   name                = "${local.cache_name}-endpoint"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = azurerm_resource_group.this.location
#   subnet_id           = azurerm_subnet.private-endpoints.id

#   private_service_connection {
#     name                           = "${local.cache_name}-endpoint"
#     private_connection_resource_id = azurerm_redis_enterprise_cluster.this.id
#     subresource_names              = ["redisEnterprise"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net.name
#     private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_redisenterprise_cache_azure_net.id]
#   }
# }
