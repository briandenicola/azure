resource "azurerm_role_assignment" "local_user_openai_user" {
  scope                            = module.openai.OPENAI_RESOURCE_ID
  role_definition_name             = "Cognitive Services OpenAI User"
  principal_id                     = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "apim_openai_user" {
  scope                            = module.openai.OPENAI_RESOURCE_ID
  role_definition_name             = "Cognitive Services OpenAI User"
  principal_id                     = azurerm_user_assigned_identity.apim_identity.principal_id
}