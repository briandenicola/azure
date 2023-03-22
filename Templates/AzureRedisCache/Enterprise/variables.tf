variable "certificate_name" {
  description   = "The name of the PFX file"
  type          = string
  default       = "my-wildcard-cert.pfx"
}

variable "regions" {
  description   = "The Azure region to deploy to"
  type          = list(string)
  default       = ["southcentralus", "eastus2"]
}