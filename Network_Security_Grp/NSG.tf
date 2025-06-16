
resource "azurerm_network_security_group" "NSG" {
  name                = var.nsg_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22-9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "NSG_association_frontend" {
  network_interface_id      = data.azurerm_network_interface.frontend_NIC.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}

resource "azurerm_network_interface_security_group_association" "NSG_association_backend" {
  network_interface_id      = data.azurerm_network_interface.backend_NIC.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}
