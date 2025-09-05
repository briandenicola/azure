variable "region" {
  description = "The location for this application deployment"
}

variable "tags" {
  description = "Tags to apply to Resource Group"
}

variable "apim_sku"{
  description = "The SKU name for the API Management service"
  default     = "Developer"
  validation {
    condition     = contains(["Developer"], var.apim_sku)
    error_message = "The SKU name must be a v2 SKU. See Readme.md for more details"
  }
}

variable "apim_virtual_network_type" {
  description = "The type of virtual network configuration for the APIM instance. Possible values 'External' or 'Internal'"
  default     = "External"
  validation {
    condition     = contains(["External", "Internal"], var.apim_virtual_network_type)
    error_message = "The virtual network type must be 'External' or 'Internal'"
  }
  
}
