variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_tier" {
  type = string
}

variable "account_replication_type" {
  type = string
}

variable "allow_nested_items_to_be_public" {
  type    = bool
  default = false
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

variable "subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
