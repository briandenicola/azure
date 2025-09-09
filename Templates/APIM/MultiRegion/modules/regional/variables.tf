variable "location" {
  description = "The location for this application deployment"
}

variable "app_name" {
  description = "The root name for this application deployment"
}

variable "tags" {
  description = "The tags for this application deployment"
  type        = string
}

variable "custom_domain" {
  description = "The domain to use for the APIM deployment"
}