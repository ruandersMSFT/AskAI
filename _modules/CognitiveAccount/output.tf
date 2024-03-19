output "endpoint" {
  value = azurerm_cognitive_account.this.endpoint
}

output "id" {
  value = azurerm_cognitive_account.this.id
}

output "name" {
  value = azurerm_cognitive_account.this.name
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "primary_access_key" {
  value = azurerm_cognitive_account.this.primary_access_key
}

output "secondary_access_key" {
  value = azurerm_cognitive_account.this.secondary_access_key
}
