data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

locals {
  openai_name = "${var.resource_name}-openai"
}

