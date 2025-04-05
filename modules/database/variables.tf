variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
  default = "canadacentral"
}

variable "sql_admin_login" {
  type        = string
  default     = "adminuser"
}

variable "sql_admin_password" {
  type        = string
  sensitive   = true
  default     = "Password123!"
}
