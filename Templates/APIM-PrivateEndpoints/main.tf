locals {
  resource_name          = "${random_pet.this.id}-${random_id.this.dec}"
  aks_name               = "${local.resource_name}-aks"
  apim_name              = "${local.resource_name}-apim"
  vnet_name              = "${local.resource_name}-vnet"
  sa_name                = "${replace(local.resource_name, "-", "")}files"
  acr_name               = "${replace(local.resource_name, "-", "")}acr"
  keyvault_name          = "${replace(local.resource_name, "-", "")}kv"
  static_webapp_name     = "${local.resource_name}-ui"
  static_webapp_location = "centralus"
  app_path               = "./cluster-config"
  flux_repository        = "https://github.com/briandenicola/openai-coin-analyzer"
  environment_type       = "dev"
  vnet_cidr              = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  pe_subnet_cidir        = cidrsubnet(local.vnet_cidr, 8, 1)
  api_subnet_cidir       = cidrsubnet(local.vnet_cidr, 8, 2)
  nodes_subnet_cidir     = cidrsubnet(local.vnet_cidr, 8, 3)
  compute_subnet_cidir   = cidrsubnet(local.vnet_cidr, 8, 4)
  sql_subnet_cidir       = cidrsubnet(local.vnet_cidr, 8, 10)
  kubernetes_version     = "1.30"
  istio_version          = "asm-1-23"
  home_ip_address        = chomp(data.http.myip.response_body)
  apim_backend_name      = "${local.resource_name}-backend"
  apim_api_path          = "api"
  swagger_url            = "https://raw.githubusercontent.com/briandenicola/openai-coin-analyzer/refs/heads/main/docs/swagger.json"
  app_apim_gateway_url   = "${azurerm_api_management.this.gateway_url}/${local.apim_api_path}/analyze"
}
