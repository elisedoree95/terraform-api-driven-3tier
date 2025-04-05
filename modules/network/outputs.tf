output "vnet_id" {
  value = azurerm_virtual_network.banking_vnet.id
}

output "subnet_ids" {
  value = { for subnet, subnet_resource in azurerm_subnet.subnets : subnet => subnet_resource.id }
  description = "Id of the subnets"
}