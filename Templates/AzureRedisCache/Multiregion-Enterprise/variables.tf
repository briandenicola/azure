variable "regions" {
  description   = "The Azure region to deploy to"
  type          = list(string)
  default       = ["southcentralus", "eastus2"]
}

variable "tags" {
  description = "The value for the tags"
} 