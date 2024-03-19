output "id" {
  value = azurerm_key_vault.this.id
}

output "name" {
  value = azurerm_key_vault.this.name
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}
