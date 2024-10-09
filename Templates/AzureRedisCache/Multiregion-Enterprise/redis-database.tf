resource "azurerm_redis_enterprise_database" "this" {
  name              = local.database_name
  cluster_id        = azurerm_redis_enterprise_cluster.this[element(var.regions, 0)].id
  client_protocol   = "Encrypted"
  clustering_policy = "EnterpriseCluster" #RedisSearch does not support OSS Clustering Policy
  eviction_policy   = "NoEviction"
  port              = 10000

  module {
    name            = "RediSearch"
  }

  linked_database_id = [
    "${azurerm_redis_enterprise_cluster.this[element(var.regions, 0)].id}/databases/${local.database_name}",
    "${azurerm_redis_enterprise_cluster.this[element(var.regions, 1)].id}/databases/${local.database_name}"
  ]

  linked_database_group_nickname = "${local.database_name}RedisDatabase"
}

data "azurerm_redis_enterprise_database" "region_1_cluster_instance" {
  depends_on          = [azurerm_redis_enterprise_database.this]
  name                = local.database_name
  cluster_id          = azurerm_redis_enterprise_cluster.this[element(var.regions, 0)].id
}

data "azurerm_redis_enterprise_database" "region_2_cluster_instance" {
  depends_on          = [azurerm_redis_enterprise_database.this]
  name                = local.database_name
  cluster_id          = azurerm_redis_enterprise_cluster.this[element(var.regions, 1)].id
}