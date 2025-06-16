module "resource_group" {
  source = "../resource_group"
  resource_group_name     = var.RG_name
  resource_group_location = var.RG_location
}

module "vnet" {
    source = "../virtual_network"
    resource_group_name     = var.RG_name
    resource_group_location = var.RG_location
    vnet_name               = var.Vnet_name
    vnet_address_space      = var.Vnet_address_space
    depends_on = [ module.resource_group ]
}

module "frontend_subnet" {
    source = "../subnet"
    resource_group_name     = var.RG_name
    subnet_name             = var.frontend_subnet_name
    vnet_name               = var.Vnet_name
    subnet_address_prefix   = var.frontend_subnet_address_prefix
    depends_on = [ module.vnet ]
}


module "backend_subnet" {
    source = "../subnet"
    resource_group_name     = var.RG_name
    subnet_name             = var.backend_subnet_name
    vnet_name               = var.Vnet_name
    subnet_address_prefix   = var.backend_subnet_address_prefix
    depends_on = [ module.vnet ]
}

module "frontend_public_ip" {
    source = "../public_ip"
    resource_group_name     = var.RG_name
    public_ip_name          = var.frontend_PIP_name
    resource_group_location = var.RG_location
    depends_on = [ module.resource_group ]
}

module "backend_public_ip" {
    source = "../public_ip"
    resource_group_name     = var.RG_name
    public_ip_name          = var.backend_PIP_name
    resource_group_location = var.RG_location
    depends_on = [ module.resource_group ]
}

module "mssqlserver_db" {               #Creating server. DB gets created via backend
    source = "../mssql_server_db"
    mssqlserver_name         = var.mssqlserver_name
    resource_group_name      = var.RG_name
    DBusername               = data.azurerm_key_vault_secret.MSSQL_creds.name
    DBpassword               = data.azurerm_key_vault_secret.MSSQL_creds.value
    mssql_db_name            = var.mssql_db_name
    depends_on = [ module.resource_group, module.AKV ]
}

module "frontend_network_interface" {
    source = "../Network_interface"
    nic_name                = var.frontend_NIC_name
    resource_group_name     = var.RG_name
    resource_group_location = var.RG_location
    subnet_name           = var.frontend_subnet_name
    public_ip_name        = var.frontend_PIP_name
    vnet_name             = var.Vnet_name
    depends_on = [ module.frontend_subnet, module.frontend_public_ip ]
}

module "backend_network_interface" {
    source = "../Network_interface"
    nic_name                = var.backend_NIC_name
    resource_group_name     = var.RG_name
    resource_group_location = var.RG_location
    subnet_name           = var.backend_subnet_name
    public_ip_name        = var.backend_PIP_name
    vnet_name             = var.Vnet_name
    depends_on = [ module.backend_subnet, module.backend_public_ip ]
}

module "nsg" {
    source = "../Network_Security_Grp"
    nsg_name                = var.NSG_name
    resource_group_name     = var.RG_name
    resource_group_location = var.RG_location
    frontend_nic_name       = var.frontend_NIC_name
    backend_nic_name        = var.backend_NIC_name
    depends_on = [ module.frontend_network_interface , module.backend_network_interface ]
}
 
module "frontend_VM" {
    source = "../Linux_VM"
    linux_VM_name           = var.frontend_VM_name
    resource_group_name     = var.RG_name
    resource_group_location = var.RG_location
    admin_username          = data.azurerm_key_vault_secret.LinuxVM_creds.name
    admin_password          = data.azurerm_key_vault_secret.LinuxVM_creds.value
    nic_name                = var.frontend_NIC_name
    key_vault_name          = var.AKV_name
    depends_on = [ module.frontend_network_interface, module.AKV ]
    custom_data_file = base64encode(<<-EOF
                #!/bin/bash
                sudo su
                apt update
                apt install -y nginx
                systemctl enable nginx
                systemctl start nginx
                apt install git-all
                curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
                apt-get install -y nodejs
                git clone https://github.com/kbvskr/ToDoFrontend.git
                cd /ToDoFrontend
                sudo su
                npm install
                npm run build
                cp -r build/* /var/www/html
                rm /var/www/html/index.nginx-debian.html
                EOF
    )
}

module "backend_VM" {
    source = "../Linux_VM"
    linux_VM_name           = var.backend_VM_name
    resource_group_name     = var.RG_name
    resource_group_location = var.RG_location
    admin_username          = data.azurerm_key_vault_secret.LinuxVM_creds.name
    admin_password          = data.azurerm_key_vault_secret.LinuxVM_creds.value
    nic_name                = var.backend_NIC_name
    key_vault_name          = var.AKV_name
    depends_on = [ module.backend_network_interface, module.AKV ]
    custom_data_file = base64encode(<<-EOF
                #!/bin/bash
                sudo su
                apt-get update && apt-get install -y unixodbc unixodbc-dev
                curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
                curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
                apt-get update
                ACCEPT_EULA=Y apt-get install -y msodbcsql17
                apt install -y python3-pip
                apt install git-all
                git clone https://github.com/kbvskr/ToDoBackend.git
                cd /ToDoBackend/
                pip install -r requirements.txt
                ##
                uvicorn app:app --host 0.0.0.0 --port 8000
                EOF
    )
}

module "shared_resource_group" {
  source = "../resource_group"
  resource_group_name     = var.Shared_RG_name
  resource_group_location = var.Shared_RG_location
}

# module "AKS" {
#   source                = "../AKS"
#   AKS_name              = var.AKS_name
#   AKS_location          = var.Shared_RG_location
#   resource_group_name   = var.Shared_RG_name
#   agentpool_node_count  = var.worker_node_count
#   agentpool_vm_size     = var.worker_node_size
#   plugin_mode           = var.plugin_mode
#   network_policy        = var.network_policy
#   depends_on            = [ module.shared_resource_group ]
# }

module "AKV" {
    source                = "../Key_Vault"
    key_vault_name        = var.AKV_name
    resource_group_name   = var.Shared_RG_name
    resource_group_location = var.Shared_RG_location
    linuxVMuser           = var.LinuxVMusername
    linuxVMpwd            = var.LinuxVMpassword
    mssqlDBuser           = var.mssqlDBuserID
    mssqlDBpwd            = var.mssqlDBpassword
    ARM_TENANT_ID         = data.azurerm_client_config.current.tenant_id
    depends_on            = [ module.shared_resource_group ]
}
