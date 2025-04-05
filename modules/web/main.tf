resource "azurerm_public_ip" "web_lb_public_ip" {
  name                = "web-lb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "web_lb" {
  name                = "web-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "web-lb-ip"
    public_ip_address_id = azurerm_public_ip.web_lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_lb_backend_pool" {
  name            = "web-lb-backend-pool"
  loadbalancer_id = azurerm_lb.web_lb.id
}

resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = "web-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_DS2_v2"
  instances           = 2
  admin_username      = "adminuser"

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
    public_key = file("C:/Users/USER/.ssh/id_rsa.pub")
  }

  network_interface {
    name    = "web-vmss-nic"
    primary = true
    ip_configuration {
      name                                   = "web-vmss-ipconfig"
      subnet_id                              = var.web_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_lb_backend_pool.id]
    }
  }
}

output "web_lb_public_ip_id" {
  value = azurerm_public_ip.web_lb_public_ip.id
}

output "web_lb_backend_pool_id" {
  value = azurerm_lb_backend_address_pool.web_lb_backend_pool.id
}
