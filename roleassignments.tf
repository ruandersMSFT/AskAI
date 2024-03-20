resource "azurerm_role_assignment" "user_search_openai" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Cognitive Services OpenAI User" # 5e0bd9bd-7b93-4f28-af87-19fc36ad61bd
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "user_storage_reader" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Storage Blob Data Reader" # 2a2b9908-6ea1-4ae2-8e65-a410df84e7d1
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "user_storage_contributor" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Storage Blob Data Contributor" # ba92f5b4-2d11-453d-a403-e96b0029c9fe
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "user_search_reader" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Search Index Data Reader" # 1407120a-92aa-4202-b7e9-c0e197c71c8f
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "user_search_contributor" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Search Index Data Contributor" # 8ebe5a00-799e-43f5-93ac-243d3dce84a7
  principal_id         = data.azurerm_client_config.current.object_id
}

# SYSTEM IDENTITIES
resource "azurerm_role_assignment" "backend_openai" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Cognitive Services OpenAI User" # 7f951dda-4ed3-4680-a7ca-43fe172d538d
  principal_id         = azurerm_linux_web_app.web.identity[0].principal_id
}

resource "azurerm_role_assignment" "webapp_acrpull" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "AcrPull" # 5e0bd9bd-7b93-4f28-af87-19fc36ad61bd
  principal_id         = azurerm_linux_web_app.enrichment.identity[0].principal_id
}

resource "azurerm_role_assignment" "backend_storage" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Storage Blob Data Reader" # 2a2b9908-6ea1-4ae2-8e65-a410df84e7d1
  principal_id         = azurerm_linux_web_app.web.identity[0].principal_id
}

resource "azurerm_role_assignment" "backend_search" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Search Index Data Reader" # 1407120a-92aa-4202-b7e9-c0e197c71c8f
  principal_id         = azurerm_linux_web_app.web.identity[0].principal_id
}

resource "azurerm_role_assignment" "function_storage" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Storage Blob Data Reader" # 2a2b9908-6ea1-4ae2-8e65-a410df84e7d1
  principal_id         = azurerm_linux_function_app.function.identity[0].principal_id
}

resource "azurerm_role_assignment" "aad_acrpush" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "AcrPush" # 8311e382-0749-4cb8-b61a-304f252e45ec
  principal_id         = local.azure_client_id
}

resource "azurerm_role_assignment" "aad_openai" {
  scope                = azurerm_resource_group.example.id
  role_definition_name = "Cognitive Services OpenAI User" # 5e0bd9bd-7b93-4f28-af87-19fc36ad61bd
  principal_id         = local.azure_client_id
}
