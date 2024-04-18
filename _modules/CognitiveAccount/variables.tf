variable "custom_subdomain_name" {
  type    = string
  default = null
}

variable "deployments" {
  type = list(object({
    model = object({
      format  = string
      name    = string
      version = string
    })
    name            = string
    rai_policy_name = string
    scale = object({
      type     = string
      capacity = number
    })
  }))
  default = []
}

variable "name" {
  type = string
}

variable "sku_name" {
  type = string
}

variable "location" {
  type = string
}

variable "kind" {
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

variable "subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
