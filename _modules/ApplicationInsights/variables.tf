variable "application_type" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sampling_percentage" {
  type = number
}

variable "tags" {
  type = map(string)
}

variable "workspace_id" {
  type = string
}

