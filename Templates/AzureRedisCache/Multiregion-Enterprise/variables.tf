variable "regions" {
  description   = "The Azure region to deploy to"
  type          = list(string)
  default       = ["eastus2", "canadacentral"]
}

variable "tags" {
  description = "The value for the tags"
} 