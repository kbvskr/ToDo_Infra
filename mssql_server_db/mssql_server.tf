
resource "azurerm_mssql_server" "mssqlserver" {
  name                         = var.mssqlserver_name
  resource_group_name          = var.resource_group_name
  location                     = "francecentral"
  version                      = "12.0"
  administrator_login          = var.DBusername
  administrator_login_password = var.DBpassword
  public_network_access_enabled = true
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.mssqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}