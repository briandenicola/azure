variable "region" {
  description = "Azure region to deploy to"
  default     = "northcentralus"
}

variable "vm_sku" {
  description = "The value for the VM SKU"
  default     = "Standard_B4ms"
}

variable "tags" {
  description = "Tags to apply for this resource"
}
