resource "azurerm_windows_function_app" "func" {
  app_settings = {
    "Acmebot:Contacts"                       = var.acmebot_contacts
    "Acmebot:Endpoint"                       = "https://acme-v02.api.letsencrypt.org/directory"
    "Acmebot:Environment"                    = "AzureCloud"
    "Acmebot:VaultBaseUrl"                   = azurerm_key_vault.kv.vault_uri
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = var.microsoft_authentication_secret
    "Acmebot:Cloudflare:ApiToken"            = var.cloudflare_api_token
    "WEBSITE_RUN_FROM_PACKAGE"               = "https://stacmebotprod.blob.core.windows.net/keyvault-acmebot/v4/latest.zip"
  }
  builtin_logging_enabled    = false
  client_certificate_mode    = "Required"
  location                   = var.location
  name                       = format("func-insights-%s-%s", var.location, var.environment)
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_access_key = azurerm_storage_account.storageaccount.primary_access_key
  storage_account_name       = azurerm_storage_account.storageaccount.name
  auth_settings_v2 {
    auth_enabled           = false
    default_provider       = "azureactivedirectory"
    require_authentication = true
    active_directory_v2 {
      allowed_audiences          = ["api://12ce76e9-bf13-4bca-9e50-8a86d35b21b6"]
      client_id                  = "12ce76e9-bf13-4bca-9e50-8a86d35b21b6"
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      tenant_auth_endpoint       = "https://sts.windows.net/edb75dc6-1736-4e41-97cc-d8a56f171897/v2.0"
    }
    login {
      token_store_enabled = true
    }
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    application_insights_connection_string = azurerm_application_insights.app_insights.connection_string
  }
  sticky_settings {
    app_setting_names = ["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"]
  }
  depends_on = [
    azurerm_service_plan.plan,
  ]
}
