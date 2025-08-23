variable "region" {
  description = "The location for this application deployment"
}

variable "tags" {
  description = "Tags to apply to Resource Group"
}

variable "apim_sku_name"{
  description = "The SKU name for the API Management service"
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.apim_sku_name)
    error_message = "The SKU name must be a v2 SKU. See Readme.md for more details"
  }
}