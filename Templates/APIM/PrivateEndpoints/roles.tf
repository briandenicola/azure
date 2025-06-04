resource "azurerm_role_assignment" "local_user_openai_user" {
  scope                            = module.openai.OPENAI_RESOURCE_ID
  role_definition_name             = "Cognitive Services OpenAI User"
  principal_id                     = data.azurerm_client_config.current.object_id
}