resource "azurerm_storage_account" "storageaccount" {
  account_kind                    = "Storage"
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  location                        = var.location
  name                            = "stfunazuresweden"
  resource_group_name             = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_storage_container" "webjobs_hosts" {
  name                 = "azure-webjobs-hosts"
  storage_account_name = azurerm_storage_account.storageaccount.name
}
resource "azurerm_storage_container" "webjobs_secrets" {
  name                 = "azure-webjobs-secrets"
  storage_account_name = azurerm_storage_account.storageaccount.name
}
resource "azurerm_storage_container" "app_container" {
  name                 = "funcazureswedensssw-applease"
  storage_account_name = azurerm_storage_account.storageaccount.name
}
resource "azurerm_storage_container" "container" {
  name                 = "funcazureswedensssw-leases"
  storage_account_name = azurerm_storage_account.storageaccount.name
}
resource "azurerm_storage_share" "share" {
  name                 = "func-azure-sweden-sssw"
  quota                = 5120
  storage_account_name = azurerm_storage_account.storageaccount.name
}
resource "azurerm_storage_queue" "control-00" {
  name                 = "funcazureswedensssw-control-00"
  storage_account_name = azurerm_storage_account.storageaccount.name
}
resource "azurerm_storage_queue" "control-01" {
  name                 = "funcazureswedensssw-control-01"
  storage_account_name = azurerm_storage_account.storageaccount.name
}

resource "azurerm_service_plan" "plan" {
  location            = var.location
  name                = format("plan-%s-%s", var.location, var.environment)
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Y1"
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
