# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "fastapi-rg"
  location = "Canada Central"
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "myfastapiacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "fastapi-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "fastapi-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                    = "fastapi-public-ip"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "fastapi-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "fastapi-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location


  security_rule {
    name                       = "nsg-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Jenkins traffic
  security_rule {
    name                       = "allow-jenkins"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Fast API traffic
  security_rule {
    name                       = "allow-fastapi"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8000"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Elasticsearch traffic
  security_rule {
    name                       = "allow-elasticsearch"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9200" # Expose Elasticsearch port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Security Group Association
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "fastapi-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"

  admin_username                  = "azureuser"
  admin_password                  = "d3v$0p$2024"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  connection {
    host     = self.public_ip_address
    user     = self.admin_username
    password = self.admin_password
    type     = "ssh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl",

      "sudo apt-get install docker.io -y",
      "sudo gpasswd -a $USER docker",

      "sudo apt-get install -y fontconfig openjdk-17-jre",
      "java -version",

      "sudo wget http://ftp.kr.debian.org/debian/pool/main/i/init-system-helpers/init-system-helpers_1.60_all.deb",
      "sudo apt install ./init-system-helpers_1.60_all.deb",

      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo \"deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]\" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",

      "sudo usermod -aG docker jenkins",
      "sudo systemctl restart jenkins",
      "sudo systemctl restart docker",
    ]
  }
}

# # Azure Kubernetes Service (AKS)
# resource "azurerm_kubernetes_cluster" "aks" {
#   name                = "fastapi-aks"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   dns_prefix          = "fastapi"

#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_B2s"
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   network_profile {
#     network_plugin = "azure"
#   }

#   role_based_access_control_enabled = true

#   kubernetes_version = "1.25.5"
# }

# # Granting ACR permissions to AKS
# resource "azurerm_role_assignment" "aks_acr" {
#   principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
#   role_definition_name = "AcrPull"
#   scope                = azurerm_container_registry.acr.id
# }

