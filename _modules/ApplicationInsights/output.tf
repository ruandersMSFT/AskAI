output "app_id" {
  value = azurerm_application_insights.this.app_id
}

output "id" {
  value = azurerm_application_insights.this.id
}

output "instrumentation_key" {
  value = azurerm_application_insights.this.instrumentation_key
}

output "name" {
  value = azurerm_application_insights.this.name
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "connection_string" {
  value = azurerm_application_insights.this.connection_string
}
