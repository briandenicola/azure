resource "azurerm_service_plan" "this" {
  name                = "${local.resource_name}-plan"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = "FC1"
}

resource "azurerm_application_insights" "this" {
  count               = var.enable_application_insights ? 1 : 0
  name                = "${local.resource_name}-appi"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  application_type    = "web"
}

resource "azurerm_function_app_flex_consumption" "this" {
  name                = "${local.resource_name}-func"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  service_plan_id     = azurerm_service_plan.this.id

  storage_container_type            = "blobContainer"
  storage_container_endpoint        = "${azurerm_storage_account.this.primary_blob_endpoint}${azurerm_storage_container.deployments.name}"
  storage_authentication_type       = "UserAssignedIdentity"
  storage_user_assigned_identity_id = azurerm_user_assigned_identity.this.id

  runtime_name    = var.runtime_name
  runtime_version = var.runtime_version

  maximum_instance_count = var.maximum_instance_count
  instance_memory_in_mb  = var.instance_memory_in_mb

  virtual_network_subnet_id     = azurerm_subnet.integration.id
  public_network_access_enabled = false
  https_only                    = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }

  site_config {
    application_insights_connection_string = var.enable_application_insights ? azurerm_application_insights.this[0].connection_string : null
  }

  depends_on = [
    azurerm_private_endpoint.storage_blob,
    azurerm_role_assignment.function_storage_blob_owner,
  ]
}

# Group ID "sites" privatizes both the app's default hostname and its SCM/Kudu
# hostname (<name>.scm.azurewebsites.net) - Azure attaches both FQDNs to the same
# NIC, and the DNS zone group below registers A-records for both automatically.
resource "azurerm_private_endpoint" "function_sites" {
  name                = "${local.resource_name}-pe-sites"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${local.resource_name}-psc-sites"
    private_connection_resource_id = azurerm_function_app_flex_consumption.this.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sites-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.this["sites"].id]
  }
}
