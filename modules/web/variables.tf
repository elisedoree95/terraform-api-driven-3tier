variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
  default = "canadacentral"
}

variable "web_subnet_id" {
  type = string
}

variable "public_key" {
  type = string
}
