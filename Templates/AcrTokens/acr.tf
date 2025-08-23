data "azurerm_container_registry" "this" {
    name                 = var.acr_name
    resource_group_name  = var.acr_resource_group   
}

resource "azurerm_container_registry_scope_map" "this" {
  name                    = "${local.token_name}-scope-map"
  container_registry_name = data.azurerm_container_registry.this.name
  resource_group_name     = data.azurerm_container_registry.this.resource_group_name
  actions = [
    "repositories/${var.container_repo}/content/read",
    "repositories/${var.container_repo}/content/write"
  ]
}

resource "azurerm_container_registry_token" "this" {
  name                    = local.token_name
  container_registry_name = data.azurerm_container_registry.this.name
  resource_group_name     = data.azurerm_container_registry.this.resource_group_name
  scope_map_id            = azurerm_container_registry_scope_map.this.id
}

resource "azurerm_container_registry_token_password" "this" {
  container_registry_token_id = azurerm_container_registry_token.this.id

  password1 {
    expiry = timeadd(timestamp(), "72h")
  }
}