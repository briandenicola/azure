variable "resource_name" {
  description = "The root value to use for naming resources"
}

variable "resource_group" {
  description = "The resource group to deploy resources to"
  type = object({
    name     = string
    location = string
  })
}

variable "log_analytics" {
  description = "The Log Analytics Workspace ID to use for diagnostic settings"
  type = object({
    deploy       = bool
    workspace_id = string
  })
}
