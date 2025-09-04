variable "region" {
  description = "The location for this application deployment"
}

variable "tags" {
  description = "Tags to apply to Resource Group"
}

variable "apim_sku"{
  description = "The SKU name for the API Management service"
  default     = "Developer"
  validation {
    condition     = contains(["Developer"], var.apim_sku)
    error_message = "The SKU name must be a v2 SKU. See Readme.md for more details"
  }
}

variable "certificate_base64_encoded" {
  description = "TLS Certificate for Istio Ingress Gateway"
}

variable "certificate_password" {
  description = "Password for TLS Certificate"
}

variable "certificate_name" {
  description = "The name of the certificate to use for TLS"
  default     = "apim-certificate"
}

variable "custom_domain" {
  description = "The custom domain to use for the APIM deployment"
}
