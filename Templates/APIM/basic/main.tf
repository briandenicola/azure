locals {
  resource_name          = "${random_pet.this.id}-${random_id.this.dec}"
  apim_name              = "${local.resource_name}-apim"
  vnet_name              = "${local.resource_name}-vnet"
  vnet_cidr              = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  pe_subnet_cidir        = cidrsubnet(local.vnet_cidr, 8, 1)
  api_subnet_cidir       = cidrsubnet(local.vnet_cidr, 8, 2)
  nodes_subnet_cidir     = cidrsubnet(local.vnet_cidr, 8, 3)
  compute_subnet_cidir   = cidrsubnet(local.vnet_cidr, 8, 4)
  sql_subnet_cidir       = cidrsubnet(local.vnet_cidr, 8, 10)
  home_ip_address        = chomp(data.http.myip.response_body)
  apim_backend_name      = "${local.resource_name}-backend"
  apim_api_path          = "api"
  swagger_url            = "https://raw.githubusercontent.com/briandenicola/openai-coin-analyzer/refs/heads/main/docs/swagger.json"
  app_apim_gateway_url   = "${azurerm_api_management.this.gateway_url}/${local.apim_api_path}/analyze"
  apim_sku_name          = "${var.apim_sku_name}_1"
}
