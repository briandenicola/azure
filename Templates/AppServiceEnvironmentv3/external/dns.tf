resource "azurerm_private_dns_zone" "appserviceenvironment_net" {
  name                      = "${local.ase_name}.appserviceenvironment.net"
  resource_group_name       = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "appserviceenvironment_net_link" {
  name                  = "${local.ase_name}-link"
  resource_group_name   = azurerm_resource_group.this.name

  private_dns_zone_name = azurerm_private_dns_zone.appserviceenvironment_net.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_a_record" "wildcard_for_app_services" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.appserviceenvironment_net.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records             = azurerm_app_service_environment_v3.this.internal_inbound_ip_addresses
}

resource "azurerm_private_dns_a_record" "wildcard_for_kudu" {
  name                = "*.scm"
  zone_name           = azurerm_private_dns_zone.appserviceenvironment_net.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records             = azurerm_app_service_environment_v3.this.internal_inbound_ip_addresses
}

resource "azurerm_private_dns_a_record" "root_domain" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.appserviceenvironment_net.name
  resource_group_name = azurerm_resource_group.this.name
  ttl                 = 300
  records             = azurerm_app_service_environment_v3.this.internal_inbound_ip_addresses
}
