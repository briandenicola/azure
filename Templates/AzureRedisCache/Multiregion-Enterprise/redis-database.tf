resource "azurerm_redis_enterprise_database" "this" {
  depends_on = [
    azurerm_private_endpoint.this
  ]

  name              = local.database_name
  cluster_id        = azurerm_redis_enterprise_cluster.this[element(var.regions, 0)].id
  client_protocol   = "Encrypted"
  clustering_policy = "EnterpriseCluster" #RedisSearch does not support OSS Clustering Policy
  eviction_policy   = "NoEviction"
  port              = 10000

  module {
    name = "RediSearch"
  }

  linked_database_id             = [for i in local.regions_set : "${azurerm_redis_enterprise_cluster.this[i].id}/databases/${local.database_name}"]
  linked_database_group_nickname = "${local.database_name}RedisDatabase"
}

data "azurerm_redis_enterprise_database" "cluster_instance" {
  for_each   = local.regions_set
  depends_on = [azurerm_redis_enterprise_database.this]
  name       = local.database_name
  cluster_id = azurerm_redis_enterprise_cluster.this[each.key].id
}
