locals {
  resource_name        = "${random_pet.this.id}-${random_id.this.dec}"
  apim_name            = "${local.resource_name}-apim"
  vnet_name            = "${local.resource_name}-vnet"
  vnet_cidr            = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  pe_subnet_cidir      = cidrsubnet(local.vnet_cidr, 8, 1)
  apim_subnet_cidir    = cidrsubnet(local.vnet_cidr, 8, 2)
  compute_subnet_cidir = cidrsubnet(local.vnet_cidr, 8, 3)
  home_ip_address      = chomp(data.http.myip.response_body)
  apim_backend_name    = "${local.resource_name}-backend"
  apim_api_path        = "api"
  apim_sku_name        = "${var.apim_sku}_1"

  apim_mgmt_hostname      = "management.apim.${var.custom_domain}"
  apim_portal_hostname    = "portal.apim.${var.custom_domain}"
  apim_devportal_hostname = "developer.apim.${var.custom_domain}"
  apim_scm_hostname       = "management.scm.apim.${var.custom_domain}"
  apim_proxy_hostname     = "api.apim.${var.custom_domain}"
}
