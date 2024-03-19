output "endpoint" {
  value = azurerm_cosmosdb_account.this.endpoint
}

output "id" {
  value = azurerm_cosmosdb_account.this.id
}

output "name" {
  value = azurerm_cosmosdb_account.this.name
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "primary_key" {
  value = azurerm_cosmosdb_account.this.primary_key
}

output "primary_readonly_key" {
  value = azurerm_cosmosdb_account.this.primary_readonly_key
}

output "secondary_key" {
  value = azurerm_cosmosdb_account.this.secondary_key
}

output "secondary_readonly_key" {
  value = azurerm_cosmosdb_account.this.secondary_readonly_key
}
