
resource "random_id" "this" {
  byte_length = 1 
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

resource "random_integer" "zone" {
  min = 1
  max = 3
}

resource "random_integer" "vnet_cidr" {
  min = 10
  max = 250
}

resource "random_password" "password" {
  length  = 25
  special = true
}
