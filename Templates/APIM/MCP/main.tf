locals {
  resource_name          = "${random_pet.this.id}-${random_id.this.dec}"
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
  apim_subnet_cidir       = cidrsubnet(local.vnet_cidr, 8, 2)
  compute_subnet_cidir   = cidrsubnet(local.vnet_cidr, 8, 3)
  kubernetes_version     = "1.31"
  istio_version          = "asm-1-24"
  home_ip_address        = chomp(data.http.myip.response_body)
  apim_backend_name      = "${local.resource_name}-backend"
  apim_api_path          = "api"
  apim_identity          = "${local.resource_name}-apim-identity"
  app_apim_gateway_url   = "${azurerm_api_management.this.gateway_url}/${local.apim_api_path}/analyze"
}
