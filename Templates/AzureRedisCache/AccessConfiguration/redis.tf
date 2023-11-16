resource "azurerm_redis_cache" "this" {
  name                = local.redis_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

resource "azapi_update_resource" "redis" {
  type          = "Microsoft.Cache/Redis@2023-08-01"
  resource_id   = azurerm_redis_cache.this.id

  body = jsonencode({
    properties = {
      redisConfiguration = {
        maxmemory-policy = "volatile-lru"
        aad-enabled =  "True"
      }
    }
  })
}

resource "azapi_resource" "access_policy_default" {
  type      = "Microsoft.Cache/Redis/accessPolicies@2023-05-01-preview"
  name      = "default"
  parent_id = azurerm_redis_cache.this.id

  body = jsonencode({
    properties = {
      permissions = "+@read allkeys"
    }
  })
}

resource "azapi_resource" "access_policy_assignment" {
  depends_on = [ 
    azapi_resource.access_policy_default 
  ]
  type        = "Microsoft.Cache/Redis/accessPolicyAssignments@2023-05-01-preview"
  name        = azurerm_user_assigned_identity.this.principal_id 
  parent_id   = azurerm_redis_cache.this.id

  body = jsonencode({
    name = azurerm_user_assigned_identity.this.principal_id,
    properties = {
      accessPolicyName = "default",
      objectId = azurerm_user_assigned_identity.this.principal_id 
      objectIdAlias = local.identity_name
    }
  })
}
