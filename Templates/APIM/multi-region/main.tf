locals {
  resource_name        = "${random_pet.this.id}-${random_id.this.dec}"
  apim_name            = "${local.resource_name}-apim"
  apim_backend_name    = "${local.resource_name}-backend"
  apim_api_path        = "api"
  #apim_sku_name        = "${var.apim_sku}V2_1" #Premium v2 does not support multiple regions at this time
  apim_sku_name        = "${var.apim_sku}_1"

  apim_mgmt_hostname      = "management.apim.${var.custom_domain}"
  apim_portal_hostname    = "portal.apim.${var.custom_domain}"
  apim_devportal_hostname = "developer.apim.${var.custom_domain}"
  apim_scm_hostname       = "management.scm.apim.${var.custom_domain}"
  apim_proxy_hostname     = "api.apim.${var.custom_domain}"

  primary_location        = element(var.locations, 0)
}
