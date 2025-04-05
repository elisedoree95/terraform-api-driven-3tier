resource "azurerm_virtual_network" "banking_vnet" {
  name                = "banking-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.banking_vnet.name
  address_prefixes     = [each.value.address_prefix]
}

resource "azurerm_network_security_group" "web_nsg" {
  name                = "web-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "business_nsg" {
  name                = "business-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "data_nsg" {
  name                = "data-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

output "web_subnet_id" {
   value = { for subnet, subnet_resource in azurerm_subnet.subnets : subnet => subnet_resource.id }
}

output "bastion_subnet_id" {
  value = azurerm_subnet.subnets["bastion"]
}
