variable "name" {
  type = string
}

variable "sku" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "retention_in_days" {
  type    = number
  default = 30
}
