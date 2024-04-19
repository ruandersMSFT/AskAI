locals {
  location = "EastUS"
  environment = "d"
  subscription = "askai"

  form_recognizer_name = "${local.environment}-${local.subscription}-formrecognizer"
  openai_name = "${local.environment}-${local.subscription}-openai"
  enrichment_name = "${local.environment}-${local.subscription}-enrichment"
  key_vault_name = "${local.environment}-${local.subscription}-kv"
  search_service_name              = "${local.environment}-${local.subscription}-search"
  web_app_name                     = "${local.environment}-${local.subscription}-web"
  app_service_plan_web_name        = "${local.environment}-${local.subscription}-asp"
  app_service_plan_enrichment_name = "${local.environment}-${local.subscription}-enrichmentasp"
  web_enrichment_name              = "${local.environment}-${local.subscription}-enrichmentweb"
  app_service_plan_function_name   = "${local.environment}-${local.subscription}-func-asp"
  function_name                    = "${local.environment}-${local.subscription}-func"
  log_analytics_name               = "${local.environment}-${local.subscription}-la"
  application_insights_name        = "${local.environment}-${local.subscription}-ai"
  app_service_environment_name     = "${local.environment}-${local.subscription}-asev3"
  cosmos_db_name = "${local.environment}-${local.subscription}-cosmos"
  storage_name = "${local.environment}${local.subscription}storage"
  storage_media_name = "${local.environment}${local.subscription}media"
  

  azure_client_id            = "3aff5d4e-1f13-4a7d-947e-612aae549f5d" # Russell's Tenant
  active_directory_client_id = "39188b98-28e5-4e26-8f0d-ac2f5d8068d2" # Russell's Tenant
  azure_management_url       = "https://management.core.windows.net/"

  COSMOSDB_LOG_CONTAINER_NAME  = "statuscontainer"
  COSMOSDB_LOG_DATABASE_NAME   = "statusdb"
  COSMOSDB_TAGS_CONTAINER_NAME = "tagcontainer"
  COSMOSDB_TAGS_DATABASE_NAME  = "tagdb"

  AZURE_SEARCH_INDEX        = "vector-index"
  AZURE_FORM_RECOGNIZER_KEY = "AZURE-FORM-RECOGNIZER-KEY"
  AZURE_SEARCH_SERVICE_KEY  = "AZURE-SEARCH-SERVICE-KEY"

  tenant_auth_endpoint = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"

  AZURE_BLOB_STORAGE_UPLOAD_CONTAINER = "upload"
  LOGS_CONTAINER                      = "logs"
  FUNCTION_CONTAINER                  = "function"
  AZURE_BLOB_STORAGE_CONTAINER        = "content"

  AZURE_OPENAI_CHATGPT_DEPLOYMENT = "gpt-35-turbo-16k"
  CHAT_WARNING_BANNER_TEXT        = ""
  QUERY_TERM_LANGUAGE             = "English"
  EMBEDDING_DEPLOYMENT_NAME       = "text-embedding-ada-002"
  TARGET_EMBEDDINGS_MODEL         = "azure-openai_${local.EMBEDDING_DEPLOYMENT_NAME}"
  IS_GOV_CLOUD_DEPLOYMENT         = "False"
  USE_AZURE_OPENAI_EMBEDDINGS     = "True"
  SCM_DO_BUILD_DURING_DEPLOYMENT  = "true"
  ENABLE_ORYX_BUILD               = "True"
  ENABLE_DEV_CODE                 = "False"

  EMBEDDINGS_QUEUE       = "embeddings-queue"
  IMAGE_ENRICHMENT_QUEUE = "image-enrichment-queue"
  MEDIA_SUBMIT_QUEUE     = "media-submit-queue"
  NON_PDF_SUBMIT_QUEUE   = "non-pdf-submit-queue"
  PDF_SUBMIT_QUEUE       = "pdf-submit-queue"
  PDF_POLLING_QUEUE      = "pdf-polling-queue"
  TEXT_ENRICHMENT_QUEUE  = "text-enrichment-queue"

  private_dns_zone_id_cognitiveservices = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/privateDnsZones/privateDnsZoneValue"
  private_dns_zone_id_cosmos            = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/privateDnsZones/privateDnsZoneValue"
  private_dns_zone_id_key_vault         = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/privateDnsZones/privateDnsZoneValue"
  private_dns_zone_id_search            = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/privateDnsZones/privateDnsZoneValue"
  private_dns_zone_id_storage_blob      = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.Network/privateDnsZones/privateDnsZoneValue"

  tags = {
    "FISMA_Id"      = "8675309"
    "TerraformRepo" = "AskJenny"
  }

}