## Not required here. DB gets created via ToDo backend.

# resource "azurerm_mssql_database" "mssqldb" {
#   name         = var.mssql_db_name
#   server_id    = data.azurerm_mssql_server.mssqlserver.id
#   collation    = "SQL_Latin1_General_CP1_CI_AS"
#   license_type = "LicenseIncluded"
#   max_size_gb  = 1
#   sku_name     = "S0"
#   enclave_type = "VBS"
# }