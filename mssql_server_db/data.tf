data "azurerm_mssql_server" "mssqlserver" {
  name                         = var.mssqlserver_name
  resource_group_name          = var.resource_group_name
}