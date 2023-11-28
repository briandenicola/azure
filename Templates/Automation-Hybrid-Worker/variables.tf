variable "region" {
  description = "The Azure region to deploy to"
  type        = string
  default     = "southcentralus"
}

variable "vm_sku" {
  default     = "Standard_B1s"
  type        = string
  description = "The Sku for the Azure Virtual Machine"
}
