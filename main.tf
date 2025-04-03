resource "azurerm_resource_group" "banking_rg" {
  name     = "banking-rg"
  location = "canadacentral"
}

# Virtual Network
resource "azurerm_virtual_network" "banking_vnet" {
  name                = "banking-vnet"
  location            = azurerm_resource_group.banking_rg.location
  resource_group_name = azurerm_resource_group.banking_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnets
resource "azurerm_subnet" "web_subnet" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.banking_rg.name
  virtual_network_name = azurerm_virtual_network.banking_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "business_subnet" {
  name                 = "business-subnet"
  resource_group_name  = azurerm_resource_group.banking_rg.name
  virtual_network_name = azurerm_virtual_network.banking_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "data_subnet" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.banking_rg.name
  virtual_network_name = azurerm_virtual_network.banking_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet" 
  resource_group_name  = azurerm_resource_group.banking_rg.name
  virtual_network_name = azurerm_virtual_network.banking_vnet.name
  address_prefixes     = ["10.0.4.0/24"]  
}

# Network Security Groups
resource "azurerm_network_security_group" "web_nsg" {
  name                = "web-nsg"
  location            = azurerm_resource_group.banking_rg.location
  resource_group_name = azurerm_resource_group.banking_rg.name
}

resource "azurerm_network_security_group" "business_nsg" {
  name                = "business-nsg"
  location            = azurerm_resource_group.banking_rg.location
  resource_group_name = azurerm_resource_group.banking_rg.name
}

resource "azurerm_network_security_group" "data_nsg" {
  name                = "data-nsg"
  location            = azurerm_resource_group.banking_rg.location
  resource_group_name = azurerm_resource_group.banking_rg.name
}

# Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = "banking-bastion"
  location            = azurerm_resource_group.banking_rg.location
  resource_group_name = azurerm_resource_group.banking_rg.name
  sku                 = "Standard"

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}

resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "bastion-pip"
  location            = azurerm_resource_group.banking_rg.location
  resource_group_name = azurerm_resource_group.banking_rg.name
  allocation_method   = "Static"
  sku                = "Standard"
}

# Web Tier Load Balancer
resource "azurerm_lb" "web_lb" {
  name                = "web-lb"
  location            = azurerm_resource_group.banking_rg.location
  resource_group_name = azurerm_resource_group.banking_rg.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "web-lb-ip"
    public_ip_address_id = azurerm_public_ip.web_lb_public_ip.id
  }
}
resource "azurerm_lb_backend_address_pool" "web_lb_backend_pool" {
  name                = "web-lb-backend-pool"
  loadbalancer_id     = azurerm_lb.web_lb.id
}

resource "azurerm_public_ip" "web_lb_public_ip" {
  name                = "web-lb-pip"
  location            = azurerm_resource_group.banking_rg.location
  resource_group_name = azurerm_resource_group.banking_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Web Server Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = "web-vmss"
  location            = azurerm_resource_group.banking_rg.location
  resource_group_name = azurerm_resource_group.banking_rg.name
  sku                 = "Standard_DS2_v2"
  instances           = 2
  admin_username      = "adminuser"

   # Specify the image for the VM
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
   admin_ssh_key {
    username   = "adminuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJOnVTM9t1c8s+XIy8BfxYDHtdwIwPrfUxHYNvVlhTJQlwzvQlVpeuiL33iVY1qK0xvEqv7w1QujQXcz0nT8Vpe6CGDujRJ3d6OqwhQOmLu3WpQpQDU7B9MImUIy70hxn1767l6czPMq6Jfuqm7YwLnpodNWyiQYIhuYLLJS20zVuB5NOiQryu0x0cV80M90B5F3CVlN+zCf+QwcFphXoug7ZXM7VPRlxJpCdS4jg7tIzy2Zx0zZR9p7g1jlP3nKfQoIlkbA1wN//g+XHtb/N4J7gMAKjKii7VfgwKXrc3N1TnV7JY9cu7iatpg8DJv848jvKApv6W/McacIROrzHdsBK9jiRXnP0h7r6Kbq6cKYoawu0PXWhO2+RGfC/f/HhVZHLxF6t3Ix/eqsz2G8/6plPG0diqXuATdbeevf/b8Uex7Z64Fvi6vXy5FMieqycFpzkBJS+TcBCveS/Bbz4NVt494sDT+F/5l7w5n6hbTdOgzcjZoDpseNHFEQX4OKh0YlNJTdErbaavEm4yvCln4IO6uIhCM/Qp+exSfRflxaES/MtE9tzQ4NF+kblDZghFRs78xribjxPu7BtsrVyaBaoLL3c5OinGDe/g3g7vlChe5V0RGdyC2sbrwGk9S0AW4fRROsZUOwzvCZhtpjoK9kY5+Rq06qKuQUclo8J66w== elise.m@metroc.ca"
  }

  network_interface {
    name    = "web-vmss-nic"
    primary = true
    ip_configuration {
      name                                   = "web-vmss-ipconfig"
      subnet_id                              = azurerm_subnet.web_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_lb_backend_pool.id]
    }
  }
}

# SQL Database with High Availability
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
resource "azurerm_mssql_server" "sql_server" {
  name                         = "banking-sql-server-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.banking_rg.name
  location                     = azurerm_resource_group.banking_rg.location
  administrator_login          = "sqladmin"
  administrator_login_password = "Password123!"
  version                      = "12.0"
}

resource "azurerm_mssql_database" "banking_db" {
  name                = "banking-db"
  server_id          = azurerm_mssql_server.sql_server.id
  collation          = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb        = 5
  sku_name           = "S1"
}
