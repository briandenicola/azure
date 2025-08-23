resource "azurerm_log_analytics_workspace" "this" {
  for_each            = local.regions_set
  name                = "${local.resource_name}-${each.key}-logs"
  location            = each.key
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  daily_quota_gb      = 0.5
}