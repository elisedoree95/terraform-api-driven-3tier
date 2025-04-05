variable "sql_admin_login" {
  type        = string
  default     = "adminuser"
}

variable "sql_admin_password" {
  type        = string
  sensitive   = true
  default     = "Password123!"
}