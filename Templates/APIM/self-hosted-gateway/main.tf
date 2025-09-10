locals {
  resource_name         = "${random_pet.this.id}-${random_id.this.dec}"
  apim_name             = "${local.resource_name}-apim"
  apim_pip_name         = "${local.resource_name}-apim-pip"
  vnet_name             = "${local.resource_name}-vnet"
  vnet_cidr             = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  pe_subnet_cidir       = cidrsubnet(local.vnet_cidr, 8, 1)
  apim_subnet_cidir     = cidrsubnet(local.vnet_cidr, 8, 2)
  compute_subnet_cidir  = cidrsubnet(local.vnet_cidr, 8, 3)
  home_ip_address       = chomp(data.http.myip.response_body)
  apim_backend_name     = "${local.resource_name}-backend"
  apim_api_path         = "api"
  apim_sku_name         = "${var.apim_sku}_1"
}
