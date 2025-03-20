variable "region" {
  description = "The location for this application deployment"
  default     = "southcentralus"
}

variable "tags" {
  description = "Tags to apply to Resource Group"
}

variable "apim_sku_name"{
  description = "The SKU name for the API Management service"
  default     = "Standardv2_1"
  validation {
    condition     = contains(["Standardv2_1", "Premiumv2_1"], var.apim_sku_name)
    error_message = "The SKU name must be a v2 SKU. See Readme.md for more details"
  }
}