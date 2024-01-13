resource "azurerm_user_assigned_identity" "base" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = format("mi-appgw-keyvault-%s-%s", var.location, var.environment)
}

resource "azurerm_virtual_network" "vnet" {
  name                = format("vnet-azuresweden-%s-%s", var.location, var.environment)
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = ["10.21.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                = format("subnet1-%s-%s", var.location, var.environment)
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.21.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                = format("backend-subnet-%s-%s", var.location, var.environment)
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.21.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = format("pub-%s-%s", var.location, var.environment)
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "main" {
  name                = format("azure-swewden-app-gateway-%s-%s", var.location, var.environment)
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = format("gw-ip-config-%s-%s", var.location, var.environment)
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = format("frontend-port-%s-%s", var.location, var.environment)
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
    name = format("backend-address-pool-%s-%s", var.location, var.environment)
  }

  backend_http_settings {
    name                  = format("http-setting-%s-%s", var.location, var.environment)
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = format("http-listener-%s-%s", var.location, var.environment)
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = format("frontend-port-%s-%s", var.location, var.environment)
    protocol                       = "Http"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.base.id]
  }

  # ssl_certificate {
  #   name = "app_listener"
  #   key_vault_secret_id = data.azurerm_key_vault_certificate.keyvault_cert.secret_id
  # }

  request_routing_rule {
    name                       = format("request-routing-rule-%s-%s", var.location, var.environment)
    rule_type                  = "Basic"
    http_listener_name         = format("http-listener-%s-%s", var.location, var.environment)
    backend_address_pool_name  = format("backend-address-pool-%s-%s", var.location, var.environment)
    backend_http_settings_name = format("http-setting-%s-%s", var.location, var.environment)
    priority                   = 1
  }
}


resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = format("nic-azure-sweden-%s-%s-%d", var.location, var.environment, count.index+1)
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = format("nic-ipconfig-%s-%s-%d", var.location, var.environment, count.index+1)
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = format("nic-ipconfig-%s-%s-%d", var.location, var.environment, count.index+1)
  backend_address_pool_id = one(azurerm_application_gateway.main.backend_address_pool).id
}

resource "random_password" "password" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = 2
  name                = "azure-sweden-${count.index+1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "azureadmin"
  admin_password      = random_password.password.result

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_virtual_machine_extension" "vm-extensions" {
  count               = 2
  name                = "ext${count.index+1}"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
    }
SETTINGS

}

# Stop the Application Gateway
# az network application-gateway stop --name azure-swden-app-gateway-uksouth-dev --resource-group rg-azuresweden-uksouth-dev

# Start the Application Gateway
# az network application-gateway start --name azure-swden-app-gateway-uksouth-dev --resource-group rg-azuresweden-uksouth-dev