variable "region" {
  description = "Region to deploy resources to"
  default     =  "southcentralus"
}

variable "virtual_network_name" {
  description = "The virtual network is for the storage account private endpoint"
  default     = "DevSub02-Vnet-001"
}

variable "virtual_network_resource_group_name" {
  description = "The Resource Group where the virtual network is deployed"
  default     = "Apps02_Network_RG"
}

variable "private_dns_zone_name" {
  description = "The DNS Zone for the storage account private endpoint"
  default     = "privatelink.blob.core.windows.net"
}

variable "private_dns_zone_resource_group_name" {
  description = "The RG of the DNS Zone for the storage account private endpoint"
  default     = "Core_DNS_RG"
}