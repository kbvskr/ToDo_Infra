
resource "azurerm_key_vault" "AKV" {
  name                        = var.key_vault_name
  location                    = var.resource_group_location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.ARM_TENANT_ID
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
  enable_rbac_authorization   = true
  enabled_for_template_deployment = true
}

resource "azurerm_key_vault_secret" "LinuxVM_creds" {
  name         = var.linuxVMuser
  value        = var.linuxVMpwd
  key_vault_id = azurerm_key_vault.AKV.id
}

resource "azurerm_key_vault_secret" "MSSQL_creds" {
  name         = var.mssqlDBuser
  value        = var.mssqlDBpwd
  key_vault_id = azurerm_key_vault.AKV.id
}