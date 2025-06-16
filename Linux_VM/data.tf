data "azurerm_network_interface" "NIC" {
  name                = var.nic_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "AKV" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "LinuxVM_creds" {
  name         = "vmadmin"
  key_vault_id = data.azurerm_key_vault.AKV.id
}