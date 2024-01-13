variable "environment" {
  type        = string
  description = "Environment name" 
}

variable "frontend_ip_configuration_name" {
  type        = string
  description = "Frontend IP configuration name"
  default = "azure-sweden-frontend-ip-config"
}


variable "location" {
  type        = string
  description = "Azure Location of resources"
}

locals {

  diag_appgw_logs = [
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayPerformanceLog",
    "ApplicationGatewayFirewallLog",
  ]
  diag_appgw_metrics = [
    "AllMetrics",
  ]
}

variable "acmebot_vault_base_url" {
  type        = string
  description = "ACMEbot vault base URL"
}

variable "acmebot_contacts" {
  type        = string
  description = "ACMEbot contacts"
}

variable "cloudflare_api_token" {
}

variable "microsoft_authentication_secret" {
}