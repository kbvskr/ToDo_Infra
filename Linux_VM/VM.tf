
resource "azurerm_linux_virtual_machine" "LinuxVM" {
  name                = var.linux_VM_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = "Standard_D2s_v3"
  admin_username      = data.azurerm_key_vault_secret.LinuxVM_creds.name
  admin_password      = data.azurerm_key_vault_secret.LinuxVM_creds.value
  disable_password_authentication = false

  network_interface_ids = [data.azurerm_network_interface.NIC.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  custom_data = var.custom_data_file
}
