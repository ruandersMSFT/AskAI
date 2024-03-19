variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "private_connection_resource_id" {
  type = string
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

variable "subresource_names" {
  type = list(any)
}
