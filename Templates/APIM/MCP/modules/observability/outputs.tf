output "MONITOR_RESOURCE_GROUP" {
  value     = azurerm_resource_group.this.name
  sensitive = false
}

output "LOG_ANALYTICS_RESOURCE_ID" {
  value     = azurerm_log_analytics_workspace.this.id
  sensitive = false
}

output "APP_INSIGHTS_RESOURCE_ID" {
  value     = azurerm_application_insights.this.id
  sensitive = false
}

output "APP_INSIGHTS_CONNECTION_STRING" {
  value     = azurerm_application_insights.this.connection_string
  sensitive = true
}
