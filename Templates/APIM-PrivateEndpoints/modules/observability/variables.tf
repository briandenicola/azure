variable "region" {
  description = "Azure region to deploy to"
  default     = "southcentralus"
}

variable "resource_name" {
  description = "The root value to use for naming resources"
}

variable "tags" {
  description = "Tags to apply for this resource"
}

variable "apim_sku_name" {
  description = "The SKU name for the API Management service"
  default     = "Developer_1"
  validation {
    condition     =  contains(["Developer_1"],  var.apim_sku_name )
    error_message = "The SKU name must be Developer for now. See https://github.com/hashicorp/terraform-provider-azurerm/issues/24377"
  }
}