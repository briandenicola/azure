resource "random_password" "password" {
  length  = 25
  special = true
}
