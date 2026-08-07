variable "region" {
  description = "Region to deploy resources to"
  default     = "eastus2"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "runtime_name" {
  description = "Function App runtime stack. One of: dotnet-isolated, node, python, java, powershell."
  type        = string
  default     = "dotnet-isolated"
}

variable "runtime_version" {
  description = "Runtime version matching runtime_name (e.g. 8.0 for dotnet-isolated)."
  type        = string
  default     = "10.0"
}

variable "maximum_instance_count" {
  description = "Maximum scale-out instance count for the Flex Consumption plan."
  type        = number
  default     = 100
}

variable "instance_memory_in_mb" {
  description = "Memory size per instance. One of: 512, 2048, 4096."
  type        = number
  default     = 2048
}

variable "enable_application_insights" {
  description = "Whether to create Application Insights for the Function App. Note: ingestion still traverses Microsoft's public endpoints unless paired with an Azure Monitor Private Link Scope (not included here)."
  type        = bool
  default     = true
}

variable "bootstrap" {
  description = "Temporarily allows the storage account to be reached from the deployer's own public IP, so `terraform apply` (run from outside the VNet) can create the deployment container. Re-apply with this set back to false to seal the account fully private again."
  type        = bool
  default     = false
}
