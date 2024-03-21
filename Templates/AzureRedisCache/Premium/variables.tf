variable "certificate_name" {
  description   = "The name of the PFX file"
  type          = string
  default       = "my-wildcard-cert.pfx"
}

variable "region" {
  description   = "The Azure region to deploy to"
  type          = string
  default       = "southcentralus"
}