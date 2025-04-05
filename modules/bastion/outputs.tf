output "bastion_host_id" {
  value = azurerm_bastion_host.bastion.id
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_public_ip.ip_address
}
