locals {
  resource_name          = "${random_pet.this.id}-${random_id.this.dec}"
  apim_name              = "${local.resource_name}-apim"
  vnet_name              = "${local.resource_name}-vnet"
  environment_type       = "dev"
  vnet_cidr              = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  pe_subnet_cidir        = cidrsubnet(local.vnet_cidr, 8, 1)
  apim_subnet_cidir      = cidrsubnet(local.vnet_cidr, 8, 2)
  compute_subnet_cidir   = cidrsubnet(local.vnet_cidr, 8, 3)
  home_ip_address        = chomp(data.http.myip.response_body)
  apim_api_path          = "api"
  apim_identity          = "${local.resource_name}-apim-identity"
  portal_root_url        = "https://portal.azure.com?Microsoft_Azure_ApiManagement=mcp&feature.customportal=true#@"
  portal_url             = "${local.portal_root_url}${data.azurerm_client_config.current.tenant_id}/resource${azurerm_api_management.this.id}/overview"
}