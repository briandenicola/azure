terraform {
  required_version = ">= 1.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.73.0"
    }
  }
}

provider "azuread" {
  tenant_id = "834bd397-f53b-4659-XXXX-YYYYYYYY"
}

provider "azurerm" {
  features {}
}

data "azuread_client_config" "current" {}

data "azurerm_key_vault" "vault1" {
  name                = "vault1"
  resource_group_name = "Core-KeyVault-RG"
}

/*
 * Azure Cli Example
 * $pass = New-Password -Length 25 -ExcludeSpecialCharacters 
 * $appId = az ad app create --display-name bjd_cli --password $pass --query 'appId' -o tsv
 * az ad sp create --id $appId
*/

resource "azuread_application" "bjd_example_app" {
    display_name = "bjdTerraform-azuread_application"
    owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "bjd_example_spn" {
    application_id = azuread_application.bjd_example_app.application_id
    owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "bjd_example_app_password" {
    display_name            = "bjd_example_app_password"
    application_object_id   = azuread_application.bjd_example_app.object_id
}

resource "azuread_application" "bjd_example_app2" {
    display_name = "bjdTerraform_azuread_service_principal"
    owners       = [data.azuread_client_config.current.object_id]
}
resource "azuread_service_principal" "bjd_example2_spn" {
    application_id = azuread_application.bjd_example_app2.application_id
    owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "service_principal_passwords"{
    service_principal_id = azuread_service_principal.bjd_example2_spn.object_id
}

resource "azurerm_key_vault_secret" "bjd_example_app_password" {
    name            = "AppPassword"
    value           = azuread_application_password.bjd_example_app_password.value
    key_vault_id    = data.azurerm_key_vault.vault1.id
}

resource "azurerm_key_vault_secret" "bjd_example_spn_passwords" {
    name            = "SPNPassword"
    value           = azuread_service_principal_password.service_principal_passwords.value
    key_vault_id    = data.azurerm_key_vault.vault1.id
}
