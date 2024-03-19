output "id" {
  value = azurerm_storage_account.this.id
}

output "name" {
  value = azurerm_storage_account.this.name
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "primary_location" {
  value = azurerm_storage_account.this.primary_location
}

output "primary_access_key" {
  value = azurerm_storage_account.this.primary_access_key
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_connection_string" {
  value = azurerm_storage_account.this.primary_connection_string
}

output "secondary_location" {
  value = azurerm_storage_account.this.secondary_location
}

output "secondary_access_key" {
  value = azurerm_storage_account.this.secondary_access_key
}

output "secondary_connection_string" {
  value = azurerm_storage_account.this.secondary_connection_string
}

output "secondary_blob_endpoint" {
  value = azurerm_storage_account.this.secondary_blob_endpoint
}
