module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.banking_rg.name
  location            = azurerm_resource_group.banking_rg.location
   vnet_address_space = ["10.0.0.0/16"]

  subnets = {
    web = {
      name           = "web-subnet"
      address_prefix = "10.0.1.0/24"
    },
    business = {
      name           = "business-subnet"
      address_prefix = "10.0.2.0/24"
    },
    data = {
      name           = "data-subnet"
      address_prefix = "10.0.3.0/24"
    },
    bastion = {
      name           = "AzureBastionSubnet"
      address_prefix = "10.0.4.0/24"
    }
  }
}

module "bastion" {
  source              = "./modules/bastion"
  resource_group_name = azurerm_resource_group.banking_rg.name
  location            = azurerm_resource_group.banking_rg.location
  bastion_subnet_id           = module.network.subnet_ids["bastion"]
  bastion_pip_name    = "bastion-pip"
}

module "web" {
  source                      = "./modules/web"
  resource_group_name         = azurerm_resource_group.banking_rg.name
  location                    = azurerm_resource_group.banking_rg.location
  public_key                  = file("C:/Users/USER/.ssh/id_rsa.pub")
  web_subnet_id               = module.network.subnet_ids["web"]
}

module "database" {
  source              = "./modules/database"
  resource_group_name = azurerm_resource_group.banking_rg.name
  location            = azurerm_resource_group.banking_rg.location
  sql_admin_login     = var.sql_admin_login
  sql_admin_password  = var.sql_admin_password
}

resource "azurerm_resource_group" "banking_rg" {
  name     = "banking-rg"
  location = "canadacentral"
}