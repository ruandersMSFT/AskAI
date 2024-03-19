variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "enabled_for_disk_encryption" {
  type    = bool
  default = false
}

variable "enabled_for_template_deployment" {
  type    = bool
  default = false
}

variable "purge_protection_enabled" {
  type    = bool
  default = true
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "private_dns_zone_ids" {
  type        = list(any)
  description = "Private DNS Zone ID(s) for the Private Endpoint"
}

variable "resource_group_name" {
  type = string
}

variable "soft_delete_retention_days" {
  type = number
  default = 90
}

variable "sku_name" {
  type = string
  default = "premium" # premium for HSM Backed
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "tenant_id" {
  type = string
}
