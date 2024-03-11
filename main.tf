data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "infoasst-myworkspace"
  location = "EastUS"

  tags = local.tags
}

resource "azurerm_key_vault" "example" {
  name                            = "infoasst-kv-geprk"
  location                        = azurerm_resource_group.example.location
  resource_group_name             = azurerm_resource_group.example.name
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 90
  purge_protection_enabled        = false

  sku_name = "standard"
  tags     = local.tags
}

resource "azurerm_search_service" "example" {
  name                        = "infoasst-search-geprk"
  resource_group_name         = azurerm_resource_group.example.name
  location                    = azurerm_resource_group.example.location
  sku                         = "standard"
  authentication_failure_mode = "http401WithBearerChallenge"
  semantic_search_sku         = "free"

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_key_vault_secret" "AZURE_SEARCH_SERVICE_KEY" {
  name         = "AZURE-SEARCH-SERVICE-KEY"
  value        = azurerm_search_service.example.primary_key
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_cosmosdb_account" "example" {
  name                = "infoasst-cosmos-geprk"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = true

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    failover_priority = 0
    location          = "eastus"
    zone_redundant    = false
  }

  tags = local.tags
}

resource "azurerm_key_vault_secret" "COSMOSDB_KEY" {
  name         = "COSMOSDB-KEY"
  value        = azurerm_cosmosdb_account.example.primary_key
  key_vault_id = azurerm_key_vault.example.id
}


resource "azurerm_service_plan" "example1" {
  name                = "infoasst-asp-geprk"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "S1"
  tags                = local.tags
}

resource "azurerm_linux_web_app" "web" {
  name                = "infoasst-web-geprk"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example1.location
  service_plan_id     = azurerm_service_plan.example1.id

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.example.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.example.connection_string
    "APPLICATION_TITLE"                     = ""
    "AZURE_BLOB_STORAGE_ACCOUNT"            = azurerm_storage_account.infoasststoregeprk.name
    "AZURE_BLOB_STORAGE_CONTAINER"          = "content"
    "AZURE_BLOB_STORAGE_ENDPOINT"           = "https://infoasststoregeprk.blob.core.windows.net/"
    "AZURE_BLOB_STORAGE_KEY"                = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/AZURE-BLOB-STORAGE-KEY)"
    "AZURE_BLOB_STORAGE_UPLOAD_CONTAINER"   = "upload"
    "AZURE_CLIENT_ID"                       = local.azure_client_id
    "AZURE_CLIENT_SECRET"                   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/AZURE-CLIENT-SECRET)"
    "AZURE_KEY_VAULT_ENDPOINT"              = azurerm_key_vault.example.vault_uri
    "AZURE_MANAGEMENT_URL"                  = local.management_url
    "AZURE_OPENAI_CHATGPT_DEPLOYMENT"       = "gpt-35-turbo-16k"
    "AZURE_OPENAI_CHATGPT_MODEL_NAME"       = ""
    "AZURE_OPENAI_CHATGPT_MODEL_VERSION"    = ""
    "AZURE_OPENAI_EMBEDDINGS_MODEL_NAME"    = ""
    "AZURE_OPENAI_EMBEDDINGS_MODEL_VERSION" = ""
    "AZURE_OPENAI_RESOURCE_GROUP"           = "infoasst-myworkspace"
    "AZURE_OPENAI_SERVICE"                  = "infoasst-aoai-geprk"
    "AZURE_OPENAI_SERVICE_KEY"              = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/AZURE-OPENAI-SERVICE-KEY)"
    "AZURE_SEARCH_INDEX"                    = "vector-index"
    "AZURE_SEARCH_SERVICE"                  = azurerm_search_service.example.name
    "AZURE_SEARCH_SERVICE_ENDPOINT"         = "https://${azurerm_search_service.example.name}.search.windows.net/"
    "AZURE_SEARCH_SERVICE_KEY"              = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/AZURE-SEARCH-SERVICE-KEY)"
    "AZURE_SUBSCRIPTION_ID"                 = data.azurerm_client_config.current.subscription_id
    "AZURE_TENANT_ID"                       = data.azurerm_client_config.current.tenant_id
    "CHAT_WARNING_BANNER_TEXT"              = ""
    "COSMOSDB_KEY"                          = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/COSMOSDB-KEY)"
    "COSMOSDB_LOG_CONTAINER_NAME"           = "statuscontainer"
    "COSMOSDB_LOG_DATABASE_NAME"            = "statusdb"
    "COSMOSDB_TAGS_CONTAINER_NAME"          = "tagcontainer"
    "COSMOSDB_TAGS_DATABASE_NAME"           = "tagdb"
    "COSMOSDB_URL"                          = azurerm_cosmosdb_account.example.endpoint
    "EMBEDDING_DEPLOYMENT_NAME"             = "text-embedding-ada-002"
    "ENABLE_ORYX_BUILD"                     = "True"
    "ENRICHMENT_APPSERVICE_NAME"            = "infoasst-enrichmentweb-geprk"
    "IS_GOV_CLOUD_DEPLOYMENT"               = "False"
    "QUERY_TERM_LANGUAGE"                   = "English"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"        = "true"
    "TARGET_EMBEDDINGS_MODEL"               = "azure-openai_text-embedding-ada-002"
    "USE_AZURE_OPENAI_EMBEDDINGS"           = "True"
  }

  https_only = true

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    application_logs {
      file_system_level = "Verbose"
    }

    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 35
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  auth_settings_v2 {
    auth_enabled             = true
    default_provider         = "AzureActiveDirectory"
    excluded_paths           = []
    forward_proxy_convention = "NoProxy"
    http_route_api_prefix    = "/.auth"
    require_authentication   = true
    require_https            = true
    runtime_version          = "~1"
    unauthenticated_action   = "RedirectToLoginPage"

    active_directory_v2 {
      allowed_applications = []
      allowed_audiences = [
        "api://infoasst-web-geprk",
      ]
      allowed_groups                  = []
      allowed_identities              = []
      client_id                       = "39188b98-28e5-4e26-8f0d-ac2f5d8068d2"
      jwt_allowed_client_applications = []
      jwt_allowed_groups              = []
      login_parameters                = {}
      tenant_auth_endpoint            = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/v2.0"
      www_authentication_disabled     = false
    }

    login {
      allowed_external_redirect_urls    = []
      cookie_expiration_convention      = "FixedTime"
      cookie_expiration_time            = "08:00:00"
      nonce_expiration_time             = "00:05:00"
      preserve_url_fragments_for_logins = false
      token_refresh_extension_time      = 72
      token_store_enabled               = false
      validate_nonce                    = true
    }
  }

  site_config {
    always_on                               = true
    container_registry_use_managed_identity = false
    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html",
    ]
    ftps_state                        = "FtpsOnly"
    health_check_eviction_time_in_min = 2
    http2_enabled                     = false
    ip_restriction_default_action     = "Allow"
    load_balancing_mode               = "LeastRequests"
    local_mysql_enabled               = false
    managed_pipeline_mode             = "Integrated"
    minimum_tls_version               = "1.2"
    remote_debugging_enabled          = false
    scm_ip_restriction_default_action = "Allow"
    scm_minimum_tls_version           = "1.2"
    scm_use_main_ip_restriction       = false
    use_32_bit_worker                 = false
    vnet_route_all_enabled            = false
    websockets_enabled                = false
    worker_count                      = 1

    application_stack {
      python_version = "3.10"
    }

    cors {
      allowed_origins = [
        "https://ms.portal.azure.com",
        "https://portal.azure.com",
      ]
      support_credentials = false
    }
  }

  tags = local.tags
}

resource "azurerm_service_plan" "example2" {
  name                = "infoasst-enrichmentasp-geprk"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "P1v3"

  tags = local.tags
}

resource "azurerm_linux_web_app" "enrichment" {
  name                = "infoasst-enrichmentweb-geprk"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example2.location
  service_plan_id     = azurerm_service_plan.example2.id

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"  = azurerm_application_insights.example.connection_string
    "AZURE_BLOB_STORAGE_ACCOUNT"             = azurerm_storage_account.infoasststoregeprk.name
    "AZURE_BLOB_STORAGE_CONTAINER"           = "content"
    "AZURE_BLOB_STORAGE_ENDPOINT"            = "https://infoasststoregeprk.blob.core.windows.net/"
    "AZURE_BLOB_STORAGE_KEY"                 = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/AZURE-BLOB-STORAGE-KEY)"
    "AZURE_BLOB_STORAGE_UPLOAD_CONTAINER"    = "upload"
    "AZURE_KEY_VAULT_ENDPOINT"               = azurerm_key_vault.example.vault_uri
    "AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME" = "text-embedding-ada-002"
    "AZURE_OPENAI_SERVICE"                   = "infoasst-aoai-geprk"
    "AZURE_OPENAI_SERVICE_KEY"               = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/AZURE-OPENAI-SERVICE-KEY)"
    "AZURE_SEARCH_INDEX"                     = "vector-index"
    "AZURE_SEARCH_SERVICE"                   = azurerm_search_service.example.name
    "AZURE_SEARCH_SERVICE_ENDPOINT"          = "https://infoasst-search-geprk.search.windows.net/"
    "AZURE_SEARCH_SERVICE_KEY"               = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/AZURE-SEARCH-SERVICE-KEY)"
    "BLOB_CONNECTION_STRING"                 = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/BLOB-CONNECTION-STRING)"
    "COSMOSDB_KEY"                           = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/COSMOSDB-KEY)"
    "COSMOSDB_LOG_CONTAINER_NAME"            = "statuscontainer"
    "COSMOSDB_LOG_DATABASE_NAME"             = "statusdb"
    "COSMOSDB_TAGS_CONTAINER_NAME"           = "tagcontainer"
    "COSMOSDB_TAGS_DATABASE_NAME"            = "tagdb"
    "COSMOSDB_URL"                           = azurerm_cosmosdb_account.example.endpoint
    "DEQUEUE_MESSAGE_BATCH_SIZE"             = "3"
    "EMBEDDINGS_QUEUE"                       = "embeddings-queue"
    "EMBEDDING_REQUEUE_BACKOFF"              = "60"
    "EMBEDDING_VECTOR_SIZE"                  = "1536"
    "ENABLE_ORYX_BUILD"                      = "True"
    "IS_GOV_CLOUD_DEPLOYMENT"                = "False"
    "LOG_LEVEL"                              = "DEBUG"
    "MAX_EMBEDDING_REQUEUE_COUNT"            = "5"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"         = "true"
    "TARGET_EMBEDDINGS_MODEL"                = "azure-openai_text-embedding-ada-002"
    "WEBSITES_CONTAINER_START_TIME_LIMIT"    = "600"
  }

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    application_logs {
      file_system_level = "Verbose"
    }

    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 35
      }
    }
  }

  tags = local.tags

  site_config {
    always_on                               = true
    app_command_line                        = "gunicorn -w 4 -k uvicorn.workers.UvicornWorker app:app"
    container_registry_use_managed_identity = false
    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html",
    ]
    ftps_state                        = "FtpsOnly"
    health_check_eviction_time_in_min = 2
    http2_enabled                     = false
    ip_restriction_default_action     = "Allow"
    load_balancing_mode               = "LeastRequests"
    local_mysql_enabled               = false
    managed_pipeline_mode             = "Integrated"
    minimum_tls_version               = "1.2"
    remote_debugging_enabled          = false
    scm_ip_restriction_default_action = "Allow"
    scm_minimum_tls_version           = "1.2"
    scm_use_main_ip_restriction       = false
    use_32_bit_worker                 = false
    vnet_route_all_enabled            = false
    websockets_enabled                = false
    worker_count                      = 1

    application_stack {
      python_version = "3.10"
    }
  }
}

resource "azurerm_service_plan" "example3" {
  name                = "infoasst-func-asp-geprk"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "S2"

  tags = local.tags
}

resource "azurerm_linux_function_app" "example" {
  name                = "infoasst-func-geprk"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  builtin_logging_enabled    = false
  client_certificate_mode    = "Required"
  storage_account_name       = azurerm_storage_account.infoasststoregeprk.name
  storage_account_access_key = azurerm_storage_account.infoasststoregeprk.primary_access_key
  service_plan_id            = azurerm_service_plan.example3.id

  app_settings = {
    "AZURE_BLOB_STORAGE_KEY"                     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/AZURE-BLOB-STORAGE-KEY)"
    "AZURE_FORM_RECOGNIZER_ENDPOINT"             = "https://${azurerm_cognitive_account.form_recognizer.name}.cognitiveservices.azure.com/"
    "AZURE_FORM_RECOGNIZER_KEY"                  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/AZURE-FORM-RECOGNIZER-KEY)"
    "AZURE_SEARCH_INDEX"                         = "vector-index"
    "AZURE_SEARCH_SERVICE_ENDPOINT"              = "https://${azurerm_search_service.example.name}.search.windows.net/"
    "AZURE_SEARCH_SERVICE_KEY"                   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/AZURE-SEARCH-SERVICE-KEY)"
    "BLOB_CONNECTION_STRING"                     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/BLOB-CONNECTION-STRING)"
    "BLOB_STORAGE_ACCOUNT"                       = azurerm_storage_account.infoasststoregeprk.name
    "BLOB_STORAGE_ACCOUNT_ENDPOINT"              = "https://infoasststoregeprk.blob.core.windows.net/"
    "BLOB_STORAGE_ACCOUNT_LOG_CONTAINER_NAME"    = "logs"
    "BLOB_STORAGE_ACCOUNT_OUTPUT_CONTAINER_NAME" = "content"
    "BLOB_STORAGE_ACCOUNT_UPLOAD_CONTAINER_NAME" = "upload"
    "CHUNK_TARGET_SIZE"                          = "750"
    "COSMOSDB_KEY"                               = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/COSMOSDB-KEY)"
    "COSMOSDB_LOG_CONTAINER_NAME"                = "statuscontainer"
    "COSMOSDB_LOG_DATABASE_NAME"                 = "statusdb"
    "COSMOSDB_TAGS_CONTAINER_NAME"               = "tagcontainer"
    "COSMOSDB_TAGS_DATABASE_NAME"                = "tagdb"
    "COSMOSDB_URL"                               = azurerm_cosmosdb_account.example.endpoint
    "EMBEDDINGS_QUEUE"                           = "embeddings-queue"
    "ENABLE_DEV_CODE"                            = "False"
    "ENRICHMENT_BACKOFF"                         = "60"
    "ENRICHMENT_ENDPOINT"                        = "https://eastus.api.cognitive.microsoft.com/"
    "ENRICHMENT_KEY"                             = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.example.vault_uri}/secrets/ENRICHMENT-KEY)"
    "ENRICHMENT_LOCATION"                        = "EastUS"
    "ENRICHMENT_NAME"                            = "infoasst-enrichment-cog-geprk"
    "FR_API_VERSION"                             = "2023-07-31"
    "IMAGE_ENRICHMENT_QUEUE"                     = "image-enrichment-queue"
    "MAX_ENRICHMENT_REQUEUE_COUNT"               = "10"
    "MAX_POLLING_REQUEUE_COUNT"                  = "10"
    "MAX_READ_ATTEMPTS"                          = "5"
    "MAX_SECONDS_HIDE_ON_UPLOAD"                 = "300"
    "MAX_SUBMIT_REQUEUE_COUNT"                   = "10"
    "MEDIA_SUBMIT_QUEUE"                         = "media-submit-queue"
    "NON_PDF_SUBMIT_QUEUE"                       = "non-pdf-submit-queue"
    "PDF_POLLING_QUEUE"                          = "pdf-polling-queue"
    "PDF_SUBMIT_QUEUE"                           = "pdf-submit-queue"
    "PDF_SUBMIT_QUEUE_BACKOFF"                   = "60"
    "POLLING_BACKOFF"                            = "30"
    "POLL_QUEUE_SUBMIT_BACKOFF"                  = "60"
    "SUBMIT_REQUEUE_HIDE_SECONDS"                = "1200"
    "TARGET_PAGES"                               = "ALL"
    "TARGET_TRANSLATION_LANGUAGE"                = "en"
    "TEXT_ENRICHMENT_QUEUE"                      = "text-enrichment-queue"
  }

  connection_string {
    name  = "BLOB_CONNECTION_STRING"
    value = azurerm_storage_account.infoasststoregeprk.primary_connection_string
    type  = "MySql"
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = true
    app_scale_limit                         = 0
    application_insights_connection_string  = azurerm_application_insights.example.connection_string
    application_insights_key                = azurerm_application_insights.example.instrumentation_key
    container_registry_use_managed_identity = false
    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
    ]
    elastic_instance_minimum          = 0
    ftps_state                        = "FtpsOnly"
    health_check_eviction_time_in_min = 2
    http2_enabled                     = true
    ip_restriction_default_action     = "Allow"
    load_balancing_mode               = "LeastRequests"
    managed_pipeline_mode             = "Integrated"
    minimum_tls_version               = "1.2"
    pre_warmed_instance_count         = 0
    remote_debugging_enabled          = false
    runtime_scale_monitoring_enabled  = false
    scm_ip_restriction_default_action = "Allow"
    scm_minimum_tls_version           = "1.2"
    scm_use_main_ip_restriction       = false
    use_32_bit_worker                 = false
    vnet_route_all_enabled            = false
    websockets_enabled                = false
    worker_count                      = 1

    application_stack {
      python_version = "3.10"
    }
  }

  tags = local.tags
}

resource "azurerm_cognitive_account" "open_ai" {
  name                  = "infoasst-aoai-geprk"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  kind                  = "OpenAI"
  custom_subdomain_name = "infoasst-aoai-geprk"

  sku_name = "S0"

  tags = local.tags
}

resource "azurerm_key_vault_secret" "AZURE_OPENAI_SERVICE_KEY" {
  name         = "AZURE-OPENAI-SERVICE-KEY"
  value        = azurerm_cognitive_account.open_ai.primary_access_key
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_cognitive_account" "form_recognizer" {
  name                  = "infoasst-fr-geprk"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  kind                  = "FormRecognizer"
  custom_subdomain_name = "infoasst-fr-geprk"

  sku_name = "S0"

  tags = local.tags
}

resource "azurerm_key_vault_secret" "AZURE_FORM_RECOGNIZER_KEY" {
  name         = "AZURE-FORM-RECOGNIZER-KEY"
  value        = azurerm_cognitive_account.form_recognizer.primary_access_key
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_cognitive_account" "enrichment" {
  name                       = "infoasst-enrichment-cog-geprk"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  kind                       = "CognitiveServices"
  dynamic_throttling_enabled = false
  fqdns                      = []
  sku_name                   = "S0"

  tags = local.tags
}

resource "azurerm_key_vault_secret" "ENRICHMENT_KEY" {
  name         = "ENRICHMENT-KEY"
  value        = azurerm_cognitive_account.enrichment.primary_access_key
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "infoasst-la-geprk"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

resource "azurerm_application_insights" "example" {
  name                = "infoasst-ai-geprk"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
  sampling_percentage = 0
  workspace_id        = azurerm_log_analytics_workspace.example.id

  tags = local.tags
}

resource "azurerm_storage_account" "infoasststoregeprk" {
  name                            = "infoasststoregeprk"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false

  tags = local.tags
}

resource "azurerm_key_vault_secret" "AZURE_BLOB_STORAGE_KEY" {
  name         = "AZURE-BLOB-STORAGE-KEY"
  value        = azurerm_storage_account.infoasststoregeprk.primary_access_key
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_key_vault_secret" "BLOB_CONNECTION_STRING" {
  name         = "BLOB-CONNECTION-STRING"
  value        = azurerm_storage_account.infoasststoregeprk.primary_connection_string
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_storage_account" "infoasststoremediageprk" {
  name                            = "infoasststoremediageprk"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false

  tags = local.tags
}

resource "azurerm_monitor_action_group" "example" {
  name                = "Application Insights Smart Detection"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "SmartDetect"

  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }

  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }

  tags = local.tags
}

resource "azurerm_monitor_smart_detector_alert_rule" "example" {
  name                = "Failure Anomalies - infoasst-ai-geprk"
  resource_group_name = azurerm_resource_group.example.name
  severity            = "Sev3"
  scope_resource_ids  = [azurerm_application_insights.example.id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"
  description         = "Detects if your application experiences an abnormal rise in the rate of HTTP requests or dependency calls that are reported as failed. The anomaly detection uses machine learning algorithms and occurs in near real time, therefore there's no need to define a frequency for this signal.<br><br>To help you triage and diagnose the problem, an analysis of the characteristics of the failures and related telemetry is provided with the detection. This feature works for any app, hosted in the cloud or on your own servers, that generates request or dependency telemetry - for example, if you have a worker role that calls <a class=\"ext-smartDetecor-link\" href=\\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackrequest\\\" target=\\\"_blank\\\">TrackRequest()</a> or <a class=\"ext-smartDetecor-link\" href=\\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackdependency\\\" target=\\\"_blank\\\">TrackDependency()</a>.<br/><br/><a class=\"ext-smartDetecor-link\" href=\\\"https://docs.microsoft.com/azure/azure-monitor/app/proactive-failure-diagnostics\\\" target=\\\"_blank\\\">Learn more about Failure Anomalies</a><br><br><p style=\\\"font-size: 13px; font-weight: 700;\\\">A note about your data privacy:</p><br><br>The service is entirely automatic and only you can see these notifications. <a class=\\\"ext-smartDetecor-link\\\" href=\\\"https://docs.microsoft.com/en-us/azure/azure-monitor/app/data-retention-privacy\\\" target=\\\"_blank\\\">Read more about data privacy</a><br><br>Smart Alerts conditions can't be edited or added for now."

  action_group {
    ids = [azurerm_monitor_action_group.example.id]
  }

  tags = local.tags
}

resource "azurerm_application_insights_workbook_template" "example" {
  name                = "infoasst-lw-geprk"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  priority            = 1

  galleries {
    category      = "workbook"
    name          = "test"
    order         = 100
    resource_type = "microsoft.insights/components"
    type          = "tsg"
  }

  template_data = jsonencode({
    "version" : "Notebook/1.0",
    "items" : [
      {
        "type" : 1,
        "content" : {
          "json" : "## New workbook\n---\n\nWelcome to your new workbook."
        },
        "name" : "text - 2"
      }
    ],
    "styleSettings" : {},
    "$schema" : "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
  })

  tags = local.tags
}
