data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "AKV" {
  name                = var.AKV_name
  resource_group_name = var.Shared_RG_name
  depends_on          = [ module.AKV ]
}

data "azurerm_key_vault_secret" "LinuxVM_creds" {
  name         = "vmadmin"
  key_vault_id = data.azurerm_key_vault.AKV.id
  depends_on   = [ module.AKV ]
}

data "azurerm_key_vault_secret" "MSSQL_creds" {
  name         = "dbadmin"
  key_vault_id = data.azurerm_key_vault.AKV.id
  depends_on   = [ module.AKV ]
}

