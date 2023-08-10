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
  name        = "9f4e1571-e838-4641-989e-af19e5b4ed62"
  parent_id   = azurerm_redis_cache.this.id

  body = jsonencode({
    name = "9f4e1571-e838-4641-989e-af19e5b4ed62",
    properties = {
      accessPolicyName = "default",
      objectId = "9f4e1571-e838-4641-989e-af19e5b4ed62",
      objectIdAlias = "ewe-61208-httpbin-app-identity"
    }
  })
}