resource "random_integer" "vnet_cidr" {
  min = 10
  max = 250
}

locals {
  resource_name        = "${var.app_name}-${var.location}"
  vnet_name            = "${local.resource_name}-vnet"
  vnet_cidr            = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  pe_subnet_cidir      = cidrsubnet(local.vnet_cidr, 8, 1)
  apim_subnet_cidir    = cidrsubnet(local.vnet_cidr, 8, 2)
  compute_subnet_cidir = cidrsubnet(local.vnet_cidr, 8, 3)
  home_ip_address      = chomp(data.http.myip.response_body)
}
