output "id" {
  value = azurerm_log_analytics_workspace.this.id
}

output "name" {
  value = azurerm_log_analytics_workspace.this.name
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "primary_shared_key" {
  value = azurerm_log_analytics_workspace.this.primary_shared_key
}

output "secondary_shared_key" {
  value = azurerm_log_analytics_workspace.this.secondary_shared_key
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.this.workspace_id
}
