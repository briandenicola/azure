variable "regions" {
  description   = "The Azure region to deploy to"
  type          = list(string)
  default       = ["eastus2", "canadacentral"]
  #default       = ["eastus2"]
}

variable "tags" {
  description = "The value for the tags"
} 
