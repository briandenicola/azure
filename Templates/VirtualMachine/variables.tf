variable "region" {
  description = "Azure region to deploy to"
  default     = "northcentralus"
}

variable "windows_sku" {
  description = "The default SKU for a Windows VM"
  default     = "Standard_B4ms"
}

variable "linux_sku" {
  description = "The default SKU for a Linux VM"
  default     = "Standard_B1ms"
}

variable "tags" {
  description = "Tags to apply for this resource"
}

variable "vm_type" {
  default = "Windows"
  validation {
    condition     = contains(["Windows", "Linux"], var.vm_type)
    error_message = "Valid values for var: vm_type are (Windows, Linux)."
  } 
}