resource "azurerm_cognitive_deployment" "gpt" {
  name                 = "gpt-4o"
  cognitive_account_id = azurerm_cognitive_account.this.id
  model {
    format    = "OpenAI"
    name      = "gpt-4o"
    version   = "2024-11-20"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 10
  }
}
