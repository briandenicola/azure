variable "region" {
  description = "The region to deploy to"
  default     = "canadaeast"
}

variable tags {
  description = "Tags to apply to the resource group"
  type        = string
}