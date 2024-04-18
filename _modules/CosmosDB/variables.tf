variable "name" {
  type = string
}

variable "automatic_failover_enabled" {
  type    = bool
  default = true
}

variable "location" {
  type = string
}

variable "kind" {
  type    = string
  default = "GlobalDocumentDB"
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
