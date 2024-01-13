resource "azurerm_application_insights" "app_insights" {
  name                = format("app-insights-%s-%s", var.location, var.environment)
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  application_type    = "web"
}
