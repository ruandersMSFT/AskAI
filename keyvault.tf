module "KeyVault" {
  source = "./_modules/KeyVault"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  name                            = "infoasst-kv-geprk"
  enabled_for_template_deployment = true
  private_dns_zone_ids            = [azurerm_private_dns_zone.example.id]
  subnet_id                       = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags                            = local.tags
  tenant_id                       = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_key_vault_secret" "search_service_key" {
  name         = local.AZURE_SEARCH_SERVICE_KEY
  value        = module.SearchService.primary_key
  key_vault_id = module.KeyVault.id
}

resource "azurerm_key_vault_secret" "COSMOSDB_KEY" {
  name         = "COSMOSDB-KEY"
  value        = module.CosmosDB.primary_key
  key_vault_id = module.KeyVault.id
}

resource "azurerm_key_vault_secret" "AZURE_OPENAI_SERVICE_KEY" {
  name         = "AZURE-OPENAI-SERVICE-KEY"
  value        = module.cognitive_account_openai.primary_access_key
  key_vault_id = module.KeyVault.id
}

resource "azurerm_key_vault_secret" "form_recognizer_key" {
  name         = local.AZURE_FORM_RECOGNIZER_KEY
  value        = module.cognitive_account_form_recognizer.primary_access_key
  key_vault_id = module.KeyVault.id
}

resource "azurerm_key_vault_secret" "ENRICHMENT_KEY" {
  name         = "ENRICHMENT-KEY"
  value        = module.cognitive_account_enrichment.primary_access_key
  key_vault_id = module.KeyVault.id
}

resource "azurerm_key_vault_secret" "AZURE_BLOB_STORAGE_KEY" {
  name         = "AZURE-BLOB-STORAGE-KEY"
  value        = module.StorageAccount.primary_access_key
  key_vault_id = module.KeyVault.id
}

resource "azurerm_key_vault_secret" "BLOB_CONNECTION_STRING" {
  name         = "BLOB-CONNECTION-STRING"
  value        = module.StorageAccount.primary_connection_string
  key_vault_id = module.KeyVault.id
}
