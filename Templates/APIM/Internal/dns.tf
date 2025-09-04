
resource "azurerm_private_dns_zone" "custom_domain" {
  name                = var.custom_domain
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "custom_domain" {
  name                  = "${azurerm_virtual_network.this.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.custom_domain.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_a_record" "management" {
  name                = local.apim_mgmt_hostname
  zone_name           = azurerm_private_dns_zone.custom_domain.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records = [
    azurerm_api_management.this.private_ip_addresses[0]
  ]
}

resource "azurerm_private_dns_a_record" "scm" {
  name                = local.apim_scm_hostname
  zone_name           = azurerm_private_dns_zone.custom_domain.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records = [
    azurerm_api_management.this.private_ip_addresses[0]
  ]
}

resource "azurerm_private_dns_a_record" "developer_portal" {
  name                = local.apim_devportal_hostname
  zone_name           = azurerm_private_dns_zone.custom_domain.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records = [
    azurerm_api_management.this.private_ip_addresses[0]
  ]
}

resource "azurerm_private_dns_a_record" "api" {
  name                = local.apim_proxy_hostname
  zone_name           = azurerm_private_dns_zone.custom_domain.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records = [
    azurerm_api_management.this.private_ip_addresses[0]
  ]
}

resource "azurerm_private_dns_a_record" "portal" {
  name                = local.apim_proxy_hostname
  zone_name           = azurerm_private_dns_zone.custom_domain.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records = [
    azurerm_api_management.this.private_ip_addresses[0]
  ]
}
