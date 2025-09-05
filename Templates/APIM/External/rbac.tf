resource "azurerm_role_assignment" "apim_config_validator_rg_scoped" {
  depends_on = [
    azurerm_api_management.this,
    azurerm_role_definition.apim_config_api_validator
  ]
  scope                            = azurerm_resource_group.this.id
  role_definition_name             = azurerm_role_definition.apim_config_api_validator.name
  principal_id                     = azurerm_api_management.this.identity[0].principal_id
  skip_service_principal_aad_check = true
}
