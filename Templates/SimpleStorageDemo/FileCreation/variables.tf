variable "region" {
  description = "Region to deploy resources to"
  default     =  "southcentralus"
}

variable "storage_account_name" {
  description = "The virtual network is for the storage account private endpoint"
}

variable "storage_account_resource_group_name" {
  description = "The Resource Group where the virtual network is deployed"
}