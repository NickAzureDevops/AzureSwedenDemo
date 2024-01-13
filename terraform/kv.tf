data "azurerm_client_config" "current" {}

resource "random_string" "key_vault_name" {
  length  = 8
  special = false
}

resource "azurerm_key_vault" "kv" {
  location            = var.location
  name                = "kv-${random_string.key_vault_name.result}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

# data "azurerm_key_vault_certificate" "keyvault_cert" {
#   name         = "secret-sauce"
#   key_vault_id = azurerm_key_vault.kv.id
# }