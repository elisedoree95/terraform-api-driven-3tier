output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.web_vmss.id
}

output "web_lb_public_ip" {
  value = azurerm_public_ip.web_lb_public_ip.ip_address
}
