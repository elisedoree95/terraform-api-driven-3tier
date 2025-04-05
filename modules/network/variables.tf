variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
  default = "canadacentral"
}

variable "vnet_address_space" {
  type = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnets" {
  type = map(object({
    name           = string
    address_prefix = string
  }))
}
