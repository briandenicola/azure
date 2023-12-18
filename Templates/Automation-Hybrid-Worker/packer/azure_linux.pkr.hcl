packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 1"
    }
  }
}

variable "arm_client_id" {
  type = string
  default = env("ARM_CLIENT_ID")
}

variable "arm_client_secret" {
  type = string
  default = env("ARM_CLIENT_SECRET")
}

variable "arm_subscription_id" {
  type = string
  default = env("ARM_SUBSCRIPTION_ID")
}

variable "azure_region" {
  type = string
  default = "southcentralus"
}

variable "build_resource_group_name" {
  type    = string
  default = "Core_Templates_RG"
}

variable "shared_image_gallery_name" {
  type    = string
  default = "bjdsharedgallery"
}

variable "shared_image_name" {
  type    = string
  default = "bjdazure.linux"
}

variable "shared_image_regions" {
  type    = list(string)
  default = ["centralus","southcentralus"]
}

variable "template_resource_group" {
  type    = string
  default = "Core_Templates_RG"
}

variable "vm_size" {
  type    = string
  default = "Standard_B4ms"
}

variable "build_version" {
  type    = string
}

locals {
  shared_image_version  = "1.0.${var.build_version}"
  template_name         = "bjdazure.linux.${var.build_version}"
  end_of_life           = timeadd(timestamp(), "336h")
}

source "azure-arm" "ubuntu-lts" {

  client_id                         = var.arm_client_id
  client_secret                     = var.arm_client_secret
  subscription_id                   = var.arm_subscription_id

  build_resource_group_name         = var.build_resource_group_name
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "canonical"
  image_sku                         = "22_04-lts"
  managed_image_name                = local.template_name
  managed_image_resource_group_name = var.template_resource_group
  os_type                           = "Linux"
  vm_size                           = var.vm_size
  
  shared_image_gallery_destination {
    gallery_name                        = var.shared_image_gallery_name
    image_name                          = var.shared_image_name
    image_version                       = local.shared_image_version
    replication_regions                 = var.shared_image_regions
    resource_group                      = var.template_resource_group
    storage_account_type                = "Premium_LRS"
    
  }
  shared_gallery_image_version_end_of_life_date = local.end_of_life

}

build {
  sources = ["source.azure-arm.ubuntu-lts"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline          = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update", 
      "apt-get upgrade -y", 
      "apt-get install -y wget apt-transport-https software-properties-common", 
      "wget -q https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/powershell_7.4.0-1.deb_amd64.deb", 
      "dpkg -i powershell_7.4.0-1.deb_amd64.deb", 
      "rm powershell_7.4.0-1.deb_amd64.deb", 
      "apt-get update", 
      "apt-get install -y powershell", 
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang  = "/bin/sh -x"
  }

}
