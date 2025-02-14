
locals {
  rgname = azurerm_resource_group.rg.name
  rglocation =azurerm_resource_group.rg.location
  vnetname = azurerm_virtual_network.vnet.name
  subnet_id = azurerm_subnet.subnet.id
  nic_id = azurerm_network_interface.nic.id
  pub_id = azurerm_public_ip.pub_ip.id
  nsg_name = azurerm_network_security_group.nsg1.name
  nsg_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_resource_group" "rg" {
  name = var.rgname
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name = var.vnetname
  location = local.rglocation
  resource_group_name = local.rgname
  address_space = var.vnet_address_space

  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_subnet" "subnet" {
  name = var.subnetname
  address_prefixes = var.subnet_address_prifixes
  virtual_network_name = local.vnetname
  resource_group_name = local.rgname

  depends_on = [ azurerm_virtual_network.vnet ]
}


resource "azurerm_public_ip" "pub_ip" {
  name = "name of ip" 
  sku = "Standard"
  allocation_method = "Static"
  resource_group_name = local.rgname
  location = local.rglocation
  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_network_security_group" "nsg1" {
  name                = var.nsgname
  resource_group_name = local.rgname
  location            = local.rglocation

  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.rgname
  network_security_group_name = local.nsg_name
  
  depends_on = [ azurerm_network_security_group.nsg1 ]
}

# like the above nsg rule we can add nsg rules for diferent ports 

resource "azurerm_subnet_network_security_group_association" "nsg_assoc1" {
  subnet_id                 = local.subnet_id
  network_security_group_id = local.nsg_id

  depends_on = [ azurerm_subnet.subnet, azurerm_network_security_group.nsg1 ]
}

resource "azurerm_network_interface" "nic" {
  name = var.nicname
  resource_group_name = local.rgname
  location = local.rglocation

  ip_configuration {
    name = "internal"
    subnet_id = local.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = local.pub_id
  }

  depends_on = [ azurerm_virtual_network.vnet, azurerm_subnet.subnet ]
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = var.vmname
  resource_group_name             = local.rgname
  location                        = local.rglocation
  size                            = "vm size" # example Standard_B1s, Standard_D2s
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [ local.nic_id ]

  /*vm login with ssh key
  make "disable_password_authentication = true" and define the below block
  admin_ssh_key {
    username   = "adminuser"
    # ssh-keygen -t rsa -f C:\Terraform\SSHKeys\id_rsa  <-- command to generate keys in windows
    public_key = file("C:/Terraform/SSHKeys/azurevm_rsa.pub") 
  }*/


  source_image_reference {
    publisher = "define publisher"  # Example: "Canonical" for Ubuntu, "MicrosoftWindowsServer" for Windows
    offer     = "image offer"   #  Specifies the image offer (e.g., "UbuntuServer" or "WindowsServer")
    sku       = "spcify sku"  # Specifies the specific SKU (e.g., "18.04-LTS" or "2019-Datacenter")
    version   = "specify the version of image"  # Specifies the image version, usually "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"  #Defines the disk type (Standard_LRS, Premium_LRS, etc.).
    caching              = "ReadWrite"  # Defines caching behavior (ReadWrite for OS, ReadOnly for data disks).
  }
}