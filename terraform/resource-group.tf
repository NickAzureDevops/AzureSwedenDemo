# Create Resoruce Group
resource "azurerm_resource_group" "rg" {
  name     = format ("rg-azuresweden-%s-%s", var.location, var.environment)
  location = var.location
}
