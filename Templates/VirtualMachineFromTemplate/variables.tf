variable "region" {
  description = "Azure region to deploy to"
  default     = "southcentralus"
}

variable "tags" {
  description = "Tags to apply for this resource"
}

variable "vm_definition" {
  type = object({
    sku                = string
    type               = string
    public_key_openssh = string
    identity_id        = string
    source_image_id    = string
    subnet_id          = string
  })
}

