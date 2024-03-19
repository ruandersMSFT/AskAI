output "id" {
  value = azurerm_search_service.this.id
}

output "name" {
  value = azurerm_search_service.this.name
}

output "primary_key" {
  value = azurerm_search_service.this.primary_key
}

output "secondary_key" {
  value = azurerm_search_service.this.secondary_key
}

output "endpoint" {
  value = "https://${azurerm_search_service.this.name}.search.windows.net/"
}
