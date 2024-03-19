variable "authentication_failure_mode" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type = string
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

variable "semantic_search_sku" {
  type    = string
  default = "standard"
}

variable "sku" {
  type    = string
  default = "standard"
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
