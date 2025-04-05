resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "banking-sql-server-${random_string.suffix.result}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

  tags = {
    environment = "dev"
  }
  version                      = "12.0"
}

resource "azurerm_mssql_database" "banking_db" {
  name        = "banking-db"
  server_id   = azurerm_mssql_server.sql_server.id
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = 5
  sku_name    = "S1"
}
