variable "region" {
  description = "Azure region to deploy to"
  default     = "southcentralus"
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
}

variable "acr_resource_group" {
  description = "The name of the Azure Container Registry Resource Group"
}

variable "container_repo" {
  description = "The name of the Azure Container Registry Repo for the scope map"
  default     = "httpdemo"
}