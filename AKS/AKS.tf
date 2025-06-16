resource "azurerm_kubernetes_cluster" "AKS" {
  name                      = var.AKS_name
  location                  = var.AKS_location
  resource_group_name       = var.resource_group_name
  kubernetes_version        = "1.32.4"
  azure_policy_enabled      = false
  dns_prefix                = "${var.AKS_name}-dns"
  node_os_upgrade_channel   = "None"
  automatic_upgrade_channel = null

  default_node_pool {
    name       = "agentpool"
    node_count = var.agentpool_node_count
    vm_size    = var.agentpool_vm_size
    max_pods   = 100
    type       = "VirtualMachineScaleSets"
    min_count  = null
    max_count  = null
    os_sku     = "Ubuntu"
    auto_scaling_enabled    = false
    node_public_ip_enabled  = false
    # zones = [ "1", "2", "3" ]
  }
  
   identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin       = "azure"
    network_policy       = var.network_policy
    load_balancer_sku    = "standard"
    network_plugin_mode  = var.plugin_mode
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
  }
  #ingress_application_gateway
  #key_management_service
  #ingress_application_gateway
}

#az aks get-credentials --resource-group ApnaRG --name ApnaAKS --overwrite-existing