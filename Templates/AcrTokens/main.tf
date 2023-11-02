data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

locals {
  location             = var.region
  token_name           = "${var.container_repo}-token"
}