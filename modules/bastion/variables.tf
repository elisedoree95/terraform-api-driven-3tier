variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
  default = "canadacentral"
}

variable "bastion_subnet_id" {
  type = string
}

variable "bastion_pip_name" {
  type = string
}
