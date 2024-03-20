locals {
  location = "EastUS"

  search_service_name              = "infoasst-search-geprk"
  web_app_name                     = "infoasst-web-geprk"
  app_service_plan_web_name        = "infoasst-asp-geprk"
  app_service_plan_enrichment_name = "infoasst-enrichmentasp-geprk"
  web_enrichment_name              = "infoasst-enrichmentweb-geprk"
  app_service_plan_function_name   = "infoasst-func-asp-geprk"
  function_name                    = "infoasst-func-geprk"


  azure_client_id      = "3aff5d4e-1f13-4a7d-947e-612aae549f5d" # Russell's Tenant
  azure_management_url = "https://management.core.windows.net/"

  COSMOSDB_LOG_CONTAINER_NAME  = "statuscontainer"
  COSMOSDB_LOG_DATABASE_NAME   = "statusdb"
  COSMOSDB_TAGS_CONTAINER_NAME = "tagcontainer"
  COSMOSDB_TAGS_DATABASE_NAME  = "tagdb"

  AZURE_SEARCH_INDEX        = "vector-index"
  AZURE_FORM_RECOGNIZER_KEY = "AZURE-FORM-RECOGNIZER-KEY"
  AZURE_SEARCH_SERVICE_KEY  = "AZURE-SEARCH-SERVICE-KEY"


  tenant_auth_endpoint = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"

  AZURE_BLOB_STORAGE_UPLOAD_CONTAINER = "upload"

  tags = {
    "FISMA_Id"      = ""
    "TerraformRepo" = "SomePath"
  }

}