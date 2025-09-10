locals {
  location_map = { for idx, val in var.locations : idx => val }
  location_map_slice = { for idx, val in var.locations : idx => val if idx != 0 }
}

resource "azurerm_private_dns_a_record" "management" {
  depends_on = [
    azurerm_api_management.this
  ]
  for_each            = local.location_map
  name                = local.apim_mgmt_hostname
  zone_name           = var.custom_domain
  resource_group_name = "${local.resource_name}-${each.value}-infra_rg"
  ttl                 = 300
  records = [
    azurerm_api_management.this.private_ip_addresses[0]
  ]
}

resource "azurerm_private_dns_a_record" "scm" {
  depends_on = [
    azurerm_api_management.this
  ]
  for_each            = local.location_map
  name                = local.apim_scm_hostname
  zone_name           = var.custom_domain
  resource_group_name = "${local.resource_name}-${each.value}-infra_rg"
  ttl                 = 300
  records = [
    azurerm_api_management.this.private_ip_addresses[0]
  ]
}

resource "azurerm_private_dns_a_record" "developer_portal" {
  depends_on = [
    azurerm_api_management.this
  ]
  for_each            = local.location_map
  name                = local.apim_devportal_hostname
  zone_name           = var.custom_domain
  resource_group_name = "${local.resource_name}-${each.value}-infra_rg"
  ttl                 = 300
  records = [
    azurerm_api_management.this.private_ip_addresses[0]
  ]
}

resource "azurerm_private_dns_a_record" "portal" {
  depends_on = [
    azurerm_api_management.this
  ]
  for_each            = local.location_map
  name                = local.apim_portal_hostname
  zone_name           = var.custom_domain
  resource_group_name = "${local.resource_name}-${each.value}-infra_rg"
  ttl                 = 300
  records = [
    azurerm_api_management.this.private_ip_addresses[0]
  ]
}

resource "azurerm_private_dns_a_record" "api_primary_region" {
  depends_on = [
    azurerm_api_management.this
  ]
  name                = local.apim_proxy_hostname
  zone_name           = var.custom_domain
  resource_group_name = "${local.resource_name}-${local.primary_location}-infra_rg"
  ttl                 = 300
  records = [
    azurerm_api_management.this.private_ip_addresses[0]
  ]
}

resource "azurerm_private_dns_a_record" "api" {
  depends_on = [
    azurerm_api_management.this
  ]
  for_each            = local.location_map_slice
  name                = local.apim_proxy_hostname
  zone_name           = var.custom_domain
  resource_group_name = "${local.resource_name}-${each.value}-infra_rg"
  ttl                 = 300
  records = [
    azurerm_api_management.this.additional_location[(each.key)-1].private_ip_addresses[0]
  ]
}