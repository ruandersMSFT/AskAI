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

variable "containers" {
  type = list(object({
    name = string
    container_access_type = string
  }))
  default = []
}

variable "cors_rule" {
  type = object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    exposed_headers = list(string)
    max_age_in_seconds = number
  })
  default = null
}

variable "delete_retention_policy_days" {
  type = number
  default = null
  description = "(Optional) Specifies the number of days that the blob should be retained, between 1 and 365 days. Defaults to 7"
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "private_dns_zone_ids" {
  type        = list(any)
  description = "Private DNS Zone ID(s) for the Private Endpoint"
}

variable "queues" {
  type = list(object({
    name = string
  }))
  default = []
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
