resource "azurerm_api_management" "this" {
  depends_on = [ 
    azurerm_subnet.apim,
    azurerm_subnet_network_security_group_association.apim
  ]

  name                          = local.apim_name
  location                      = azurerm_resource_group.app.location
  resource_group_name           = azurerm_resource_group.app.name
  publisher_name                = "BD"
  publisher_email               = "admin@bjdazure.tech"
  sku_name                      = local.apim_sku_name
  public_network_access_enabled = true
  virtual_network_type          = "Internal"

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }

  hostname_configuration {
    management {
      host_name            = local.apim_mgmt_hostname
      certificate          = var.certificate_base64_encoded
      certificate_password = var.certificate_password
      #key_vault_certificate_id = module.key_vault.KEY_VAULT_CERTIFICATE_ID --> This should be used in production instead of embedding the certificate
    }
    portal {
      host_name            = local.apim_portal_hostname
      certificate          = var.certificate_base64_encoded
      certificate_password = var.certificate_password
    }
    developer_portal {
      host_name            = local.apim_devportal_hostname
      certificate          = var.certificate_base64_encoded
      certificate_password = var.certificate_password
    }
    scm {
      host_name            = local.apim_scm_hostname
      certificate          = var.certificate_base64_encoded
      certificate_password = var.certificate_password
    }
    proxy {
      host_name            = local.apim_proxy_hostname
      certificate          = var.certificate_base64_encoded
      certificate_password = var.certificate_password
    }
  }

  protocols {
    http2_enabled = true
  }

}

resource "azurerm_api_management_logger" "this" {
  name                = "${local.apim_name}-logger"
  api_management_name = azurerm_api_management.this.name
  resource_group_name = azurerm_api_management.this.resource_group_name

  application_insights {
    connection_string = module.azure_monitor.APP_INSIGHTS_CONNECTION_STRING
  }
}
