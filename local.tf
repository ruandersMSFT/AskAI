locals {
  azure_client_id = "3aff5d4e-1f13-4a7d-947e-612aae549f5d" # Russell's Tenant
  management_url  = "https://management.core.windows.net/"

  COSMOSDB_LOG_CONTAINER_NAME  = "statuscontainer"
  COSMOSDB_LOG_DATABASE_NAME   = "statusdb"
  COSMOSDB_TAGS_CONTAINER_NAME = "tagcontainer"
  COSMOSDB_TAGS_DATABASE_NAME  = "tagdb"


  tags = {
    "FISMA_Id"      = ""
    "TerraformRepo" = "SomePath"
  }
}