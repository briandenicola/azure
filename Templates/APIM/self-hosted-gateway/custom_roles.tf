resource "azurerm_role_definition" "apim_config_api_validator" {
  name        = "API Management Configuration API Access Validator Service Role (${local.apim_name})"
  scope       = data.azurerm_subscription.current.id
  description = "Can access RBAC permissions on the API Management resource to authorize requests in Configuration API."

  permissions {
    actions = [
      "Microsoft.Authorization/*/read"
    ]
    not_actions     = []
    data_actions    = []
    not_data_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}

resource "azurerm_role_definition" "apim_gateway_config_reader" {
  name        = "API Management Gateway Configuration Reader Role (${local.apim_name})"
  scope       = data.azurerm_subscription.current.id
  description = "Can read self-hosted gateway configuration from Configuration API"

  permissions {
    actions          = []
    not_actions      = []
    data_actions = [
      "Microsoft.ApiManagement/service/gateways/getConfiguration/action"
    ]
    not_data_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}
