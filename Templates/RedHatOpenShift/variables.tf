variable "region" {
  description = "Region to deploy resources to"
  default     = "southcentralus"
}

variable "domain" {
  description = "The default domain of OpenShift"
  default     = "bjdazuretech"
}

variable "aro_rp_aad_sp_object_id" {
  description = "Azure Red Hat OpenShift RP"
  type        = string
  default     = "1679a87a-3db8-4d2a-af43-79d10ff9006c"
}