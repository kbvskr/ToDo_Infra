data "azurerm_network_interface" "frontend_NIC" {
  name                = var.frontend_nic_name
  resource_group_name = var.resource_group_name
}

data "azurerm_network_interface" "backend_NIC" {
  name                = var.backend_nic_name
  resource_group_name = var.resource_group_name
}