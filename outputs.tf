output "id" {
  value       = azurerm_linux_function_app.main.id
  description = "The ID of the Function App."
}

output "name" {
  value       = azurerm_linux_function_app.main.name
  description = "The name of the Function App."
}

output "hostname" {
  value       = azurerm_linux_function_app.main.default_hostname
  description = "The default hostname for the Function App."
}

output "domain_verification_id" {
  value       = azurerm_linux_function_app.main.custom_domain_verification_id
  description = "An identifier used by App Service to perform domain ownership verification via DNS TXT record."
}

output "outbound_ips" {
  value       = split(",", azurerm_linux_function_app.main.outbound_ip_addresses)
  description = "A list of outbound IP addresses for the Function App."
}

output "possible_outbound_ips" {
  value       = split(",", azurerm_linux_function_app.main.possible_outbound_ip_addresses)
  description = "A list of possible outbound IP addresses for the Function App. Superset of outbound_ips."
}

output "plan" {
  value = {
    id = azurerm_linux_function_app.main.service_plan_id
  }
  description = "A mapping of Function App plan properties."
}

output "identity" {
  value = {
    principal_id = azurerm_linux_function_app.main.identity[0].principal_id
    tenant_id    = azurerm_linux_function_app.main.identity[0].tenant_id
  }
  description = "A mapping og identity properties for the web app."
}
