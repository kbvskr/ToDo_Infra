output "Frontend_PIP" {
  value = module.frontend_public_ip.public_ip_address
}
output "Backend_PIP" {
  value = module.backend_public_ip.public_ip_address
}
output "VMuserSecret" {
  value = data.azurerm_key_vault_secret.LinuxVM_creds.name
}
output "VMpwdSecret" {
  value = data.azurerm_key_vault_secret.LinuxVM_creds.value
  sensitive = true
}
output "DBuserSecret" {
  value = data.azurerm_key_vault_secret.MSSQL_creds.name
}
output "DBpwdSecret" {
  value = data.azurerm_key_vault_secret.MSSQL_creds.value
  sensitive = true
}