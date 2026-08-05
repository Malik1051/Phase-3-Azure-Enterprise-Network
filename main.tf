# =============================================================================
# Resource Group
# =============================================================================

resource "azurerm_resource_group" "novapay_rg" {
  name     = var.resource_group_name
  location = var.location
}

# =============================================================================
# Virtual Network
# =============================================================================

resource "azurerm_virtual_network" "novapay_vnet" {

  name = var.vnet_name

  location = azurerm_resource_group.novapay_rg.location

  resource_group_name = azurerm_resource_group.novapay_rg.name

  address_space = var.vnet_address_space

}

# =============================================================================
# Subnets
# =============================================================================

# -----------------------------------------------------------------------------
# Web Subnet
# Creates the Web subnet inside the NovaPay Virtual Network.
# -----------------------------------------------------------------------------

resource "azurerm_subnet" "web_subnet" {

  name = "web-subnet"

  resource_group_name = azurerm_resource_group.novapay_rg.name

  virtual_network_name = azurerm_virtual_network.novapay_vnet.name

  address_prefixes = [var.web_subnet]

}

# -----------------------------------------------------------------------------
# Application Subnet
# Creates the Application subnet inside the NovaPay Virtual Network.
# -----------------------------------------------------------------------------

resource "azurerm_subnet" "app_subnet" {

  name = "app-subnet"

  resource_group_name = azurerm_resource_group.novapay_rg.name

  virtual_network_name = azurerm_virtual_network.novapay_vnet.name

  address_prefixes = [var.app_subnet]

}

# -----------------------------------------------------------------------------
# Database Subnet
# Creates the Database subnet inside the NovaPay Virtual Network.
# -----------------------------------------------------------------------------

resource "azurerm_subnet" "db_subnet" {

  name = "db-subnet"

  resource_group_name = azurerm_resource_group.novapay_rg.name

  virtual_network_name = azurerm_virtual_network.novapay_vnet.name

  address_prefixes = [var.db_subnet]

}

# =============================================================================
# Network Security Groups
# =============================================================================

# -----------------------------------------------------------------------------
# Web Network Security Group
# Controls traffic for the Web subnet.
# -----------------------------------------------------------------------------

resource "azurerm_network_security_group" "web_nsg" {

  name = "web-nsg"

  location = azurerm_resource_group.novapay_rg.location

  resource_group_name = azurerm_resource_group.novapay_rg.name

}

# -----------------------------------------------------------------------------
# Application Network Security Group
# Controls traffic for the Application subnet.
# -----------------------------------------------------------------------------

resource "azurerm_network_security_group" "app_nsg" {

  name = "app-nsg"

  location = azurerm_resource_group.novapay_rg.location

  resource_group_name = azurerm_resource_group.novapay_rg.name

}

# -----------------------------------------------------------------------------
# Database Network Security Group
# Controls traffic for the Database subnet.
# -----------------------------------------------------------------------------

resource "azurerm_network_security_group" "db_nsg" {

  name = "db-nsg"

  location = azurerm_resource_group.novapay_rg.location

  resource_group_name = azurerm_resource_group.novapay_rg.name

}

# =============================================================================
# NSG Associations
# =============================================================================

# -----------------------------------------------------------------------------
# Associate the Web NSG with the Web Subnet.
# -----------------------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "web_nsg_assoc" {

  subnet_id = azurerm_subnet.web_subnet.id

  network_security_group_id = azurerm_network_security_group.web_nsg.id

}

# -----------------------------------------------------------------------------
# Associate the Application NSG with the Application Subnet.
# -----------------------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "app_nsg_assoc" {

  subnet_id = azurerm_subnet.app_subnet.id

  network_security_group_id = azurerm_network_security_group.app_nsg.id

}

# -----------------------------------------------------------------------------
# Associate the Database NSG with the Database Subnet.
# -----------------------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "db_nsg_assoc" {

  subnet_id = azurerm_subnet.db_subnet.id

  network_security_group_id = azurerm_network_security_group.db_nsg.id

}

# -----------------------------------------------------------------------------
# Allow SSH from the Administrator IP
# -----------------------------------------------------------------------------

resource "azurerm_network_security_rule" "allow_ssh" {

  name = "Allow-SSH"

  priority = 120

  direction = "Inbound"

  access = "Allow"

  protocol = "Tcp"

  source_port_range = "*"

  destination_port_range = "22"

  source_address_prefix = var.admin_ip

  destination_address_prefix = "*"

  resource_group_name = azurerm_resource_group.novapay_rg.name

  network_security_group_name = azurerm_network_security_group.web_nsg.name

}

# -----------------------------------------------------------------------------
# Allow HTTPS traffic to the Web subnet
# -----------------------------------------------------------------------------

resource "azurerm_network_security_rule" "allow_https" {

  name = "Allow-HTTPS"

  priority = 110

  direction = "Inbound"

  access = "Allow"

  protocol = "Tcp"

  source_port_range = "*"

  destination_port_range = "443"

  source_address_prefix = "*"

  destination_address_prefix = "*"

  resource_group_name = azurerm_resource_group.novapay_rg.name

  network_security_group_name = azurerm_network_security_group.web_nsg.name

}

# -----------------------------------------------------------------------------
# Allow HTTP traffic to the Web subnet
# -----------------------------------------------------------------------------

resource "azurerm_network_security_rule" "allow_http" {

  name = "Allow-HTTP"

  priority = 100

  direction = "Inbound"

  access = "Allow"

  protocol = "Tcp"

  source_port_range = "*"

  destination_port_range = "80"

  source_address_prefix = "*"

  destination_address_prefix = "*"

  resource_group_name = azurerm_resource_group.novapay_rg.name

  network_security_group_name = azurerm_network_security_group.web_nsg.name

}

# -----------------------------------------------------------------------------
# Allow Web Subnet to communicate with the Application Subnet
# -----------------------------------------------------------------------------

resource "azurerm_network_security_rule" "allow_web_to_app" {

  name = "Allow-Web-To-App"

  priority = 100

  direction = "Inbound"

  access = "Allow"

  protocol = "Tcp"

  source_port_range = "*"

  destination_port_range = "8080"

  source_address_prefix = var.web_subnet

  destination_address_prefix = "*"

  resource_group_name = azurerm_resource_group.novapay_rg.name

  network_security_group_name = azurerm_network_security_group.app_nsg.name

}

# -----------------------------------------------------------------------------
# Allow Application Subnet to communicate with the Database Subnet
# -----------------------------------------------------------------------------

resource "azurerm_network_security_rule" "allow_app_to_db" {

  name = "Allow-App-To-DB"

  priority = 100

  direction = "Inbound"

  access = "Allow"

  protocol = "Tcp"

  source_port_range = "*"

  destination_port_range = "3306"

  source_address_prefix = var.app_subnet

  destination_address_prefix = "*"

  resource_group_name = azurerm_resource_group.novapay_rg.name

  network_security_group_name = azurerm_network_security_group.db_nsg.name

}

# =============================================================================
# Public IP Addresses
# =============================================================================

# -----------------------------------------------------------------------------
# Public IP for the Web Virtual Machine
# -----------------------------------------------------------------------------

resource "azurerm_public_ip" "web_public_ip" {

  # Public IP resource name
  name = "pip-web-novapay"

  # Azure region
  location = azurerm_resource_group.novapay_rg.location

  # Resource Group
  resource_group_name = azurerm_resource_group.novapay_rg.name

  # Static IP address
  allocation_method = "Static"

  # Standard SKU
  sku = "Standard"

}

# =============================================================================
# Network Interfaces
# =============================================================================

# -----------------------------------------------------------------------------
# Network Interface for the Web Virtual Machine
# -----------------------------------------------------------------------------

resource "azurerm_network_interface" "web_nic" {

  # NIC name
  name = "nic-web-novapay"

  # Azure region
  location = azurerm_resource_group.novapay_rg.location

  # Resource Group
  resource_group_name = azurerm_resource_group.novapay_rg.name

  ip_configuration {

    # Configuration name
    name = "internal"

    # Connect this NIC to the Web subnet
    subnet_id = azurerm_subnet.web_subnet.id

    # Assign the Public IP to this NIC
    public_ip_address_id = azurerm_public_ip.web_public_ip.id

    # Private IP assigned automatically
    private_ip_address_allocation = "Dynamic"

  }

}

# =============================================================================
# Virtual Machines
# =============================================================================

# -----------------------------------------------------------------------------
# Web Virtual Machine
# -----------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "web_vm" {

  # Virtual Machine name
  name = "vm-web-novapay"

  # Azure region
  location = azurerm_resource_group.novapay_rg.location

  # Resource Group
  resource_group_name = azurerm_resource_group.novapay_rg.name

  # VM size
  size = var.vm_size

  # Administrator username
  admin_username = "azureuser"

  # Attach the Network Interface
  network_interface_ids = [
    azurerm_network_interface.web_nic.id
  ]

  # Disable password authentication
  disable_password_authentication = true

  # SSH public key
  admin_ssh_key {

    username = "azureuser"

    public_key = file("~/.ssh/id_rsa.pub")

  }

  # Operating System disk
  os_disk {

    caching = "ReadWrite"

    storage_account_type = "Standard_LRS"

  }

  # Ubuntu image
  source_image_reference {

    publisher = "Canonical"

    offer = "0001-com-ubuntu-server-jammy"

    sku = "22_04-lts-gen2"

    version = "latest"

  }

}
