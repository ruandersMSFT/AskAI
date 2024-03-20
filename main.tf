# Need AZURE-CLIENT-SECRET key vault secret from AAD Client

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "infoasst-myworkspace"
  location = local.location

  tags = local.tags
}

module "SearchService" {
  source = "./_modules/SearchService"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  name                        = local.search_service_name
  authentication_failure_mode = "http401WithBearerChallenge"
  private_dns_zone_ids        = [azurerm_private_dns_zone.example.id]
  subnet_id                   = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags                        = local.tags
}

resource "azurerm_service_plan" "web" {
  name                = local.app_service_plan_web_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "S1"
  tags                = local.tags
}

resource "azurerm_linux_web_app" "web" {
  name                = local.web_app_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.web.location
  service_plan_id     = azurerm_service_plan.web.id

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = module.ApplicationInsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.ApplicationInsights.connection_string
    "APPLICATION_TITLE"                     = ""
    "AZURE_BLOB_STORAGE_ACCOUNT"            = module.StorageAccount.name
    "AZURE_BLOB_STORAGE_CONTAINER"          = "content"
    "AZURE_BLOB_STORAGE_ENDPOINT"           = module.StorageAccount.primary_blob_endpoint
    "AZURE_BLOB_STORAGE_KEY"                = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-BLOB-STORAGE-KEY)"
    "AZURE_BLOB_STORAGE_UPLOAD_CONTAINER"   = local.AZURE_BLOB_STORAGE_UPLOAD_CONTAINER
    "AZURE_CLIENT_ID"                       = local.azure_client_id
    "AZURE_CLIENT_SECRET"                   = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-CLIENT-SECRET)"
    "AZURE_KEY_VAULT_ENDPOINT"              = module.KeyVault.vault_uri
    "AZURE_MANAGEMENT_URL"                  = local.azure_management_url
    "AZURE_OPENAI_CHATGPT_DEPLOYMENT"       = "gpt-35-turbo-16k"
    "AZURE_OPENAI_CHATGPT_MODEL_NAME"       = ""
    "AZURE_OPENAI_CHATGPT_MODEL_VERSION"    = ""
    "AZURE_OPENAI_EMBEDDINGS_MODEL_NAME"    = ""
    "AZURE_OPENAI_EMBEDDINGS_MODEL_VERSION" = ""
    "AZURE_OPENAI_RESOURCE_GROUP"           = module.cognitive_account_openai.resource_group_name
    "AZURE_OPENAI_SERVICE"                  = module.cognitive_account_openai.name
    "AZURE_OPENAI_SERVICE_KEY"              = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-OPENAI-SERVICE-KEY)"
    "AZURE_SEARCH_INDEX"                    = local.AZURE_SEARCH_INDEX
    "AZURE_SEARCH_SERVICE"                  = module.SearchService.name
    "AZURE_SEARCH_SERVICE_ENDPOINT"         = module.SearchService.endpoint
    "AZURE_SEARCH_SERVICE_KEY"              = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/${local.AZURE_SEARCH_SERVICE_KEY})"
    "AZURE_SUBSCRIPTION_ID"                 = data.azurerm_client_config.current.subscription_id
    "AZURE_TENANT_ID"                       = data.azurerm_client_config.current.tenant_id
    "CHAT_WARNING_BANNER_TEXT"              = ""
    "COSMOSDB_KEY"                          = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/COSMOSDB-KEY)"
    "COSMOSDB_LOG_CONTAINER_NAME"           = local.COSMOSDB_LOG_CONTAINER_NAME
    "COSMOSDB_LOG_DATABASE_NAME"            = local.COSMOSDB_LOG_DATABASE_NAME
    "COSMOSDB_TAGS_CONTAINER_NAME"          = local.COSMOSDB_TAGS_CONTAINER_NAME
    "COSMOSDB_TAGS_DATABASE_NAME"           = local.COSMOSDB_TAGS_DATABASE_NAME
    "COSMOSDB_URL"                          = module.CosmosDB.endpoint
    "EMBEDDING_DEPLOYMENT_NAME"             = "text-embedding-ada-002"
    "ENABLE_ORYX_BUILD"                     = "True"
    "ENRICHMENT_APPSERVICE_NAME"            = azurerm_linux_web_app.enrichment.name
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
        "api://${local.web_app_name}",
      ]
      allowed_groups                  = []
      allowed_identities              = []
      client_id                       = "39188b98-28e5-4e26-8f0d-ac2f5d8068d2"
      jwt_allowed_client_applications = []
      jwt_allowed_groups              = []
      login_parameters                = {}
      tenant_auth_endpoint            = local.tenant_auth_endpoint
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
        "https://portal.azure.com",
      ]
      support_credentials = false
    }
  }

  tags = local.tags
}

resource "azurerm_service_plan" "enrichment" {
  name                         = local.app_service_plan_enrichment_name
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  os_type                      = "Linux"
  sku_name                     = "P1v3"
  per_site_scaling_enabled     = false
  maximum_elastic_worker_count = 3
  zone_balancing_enabled       = false
  tags                         = local.tags
}

resource "azurerm_monitor_autoscale_setting" "enrichment" {
  name                = "${local.app_service_plan_enrichment_name}-Autoscale"
  resource_group_name = azurerm_service_plan.enrichment.name
  location            = azurerm_service_plan.enrichment.location
  target_resource_id  = azurerm_service_plan.enrichment.id

  profile {
    name = "Scale out condition"

    capacity {
      default = 1
      minimum = 1
      maximum = 5
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.enrichment.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 60
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.enrichment.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 20
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT15M"
      }
    }
  }
}

resource "azurerm_linux_web_app" "enrichment" {
  name                = local.web_enrichment_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.enrichment.location
  service_plan_id     = azurerm_service_plan.enrichment.id

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"  = module.ApplicationInsights.connection_string
    "AZURE_BLOB_STORAGE_ACCOUNT"             = module.StorageAccount.name
    "AZURE_BLOB_STORAGE_CONTAINER"           = "content"
    "AZURE_BLOB_STORAGE_ENDPOINT"            = module.StorageAccount.primary_blob_endpoint
    "AZURE_BLOB_STORAGE_KEY"                 = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-BLOB-STORAGE-KEY)"
    "AZURE_BLOB_STORAGE_UPLOAD_CONTAINER"    = local.AZURE_BLOB_STORAGE_UPLOAD_CONTAINER
    "AZURE_KEY_VAULT_ENDPOINT"               = module.KeyVault.vault_uri
    "AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME" = "text-embedding-ada-002"
    "AZURE_OPENAI_SERVICE"                   = module.cognitive_account_openai.name
    "AZURE_OPENAI_SERVICE_KEY"               = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-OPENAI-SERVICE-KEY)"
    "AZURE_SEARCH_INDEX"                     = local.AZURE_SEARCH_INDEX
    "AZURE_SEARCH_SERVICE"                   = module.SearchService.name
    "AZURE_SEARCH_SERVICE_ENDPOINT"          = module.SearchService.endpoint
    "AZURE_SEARCH_SERVICE_KEY"               = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/${local.AZURE_SEARCH_SERVICE_KEY})"
    "BLOB_CONNECTION_STRING"                 = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/BLOB-CONNECTION-STRING)"
    "COSMOSDB_KEY"                           = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/COSMOSDB-KEY)"
    "COSMOSDB_LOG_CONTAINER_NAME"            = local.COSMOSDB_LOG_CONTAINER_NAME
    "COSMOSDB_LOG_DATABASE_NAME"             = local.COSMOSDB_LOG_DATABASE_NAME
    "COSMOSDB_TAGS_CONTAINER_NAME"           = local.COSMOSDB_TAGS_CONTAINER_NAME
    "COSMOSDB_TAGS_DATABASE_NAME"            = local.COSMOSDB_TAGS_DATABASE_NAME
    "COSMOSDB_URL"                           = module.CosmosDB.endpoint
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

resource "azurerm_service_plan" "function" {
  name                = local.app_service_plan_function_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "S2"

  tags = local.tags
}

resource "azurerm_monitor_autoscale_setting" "function" {
  name                = "${local.app_service_plan_function_name}-Autoscale"
  resource_group_name = azurerm_service_plan.function.name
  location            = azurerm_service_plan.function.location
  target_resource_id  = azurerm_service_plan.function.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.function.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 60
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "2"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.function.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 40
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "2"
        cooldown  = "PT2M"
      }
    }
  }
}

resource "azurerm_linux_function_app" "function" {
  name                = local.function_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  builtin_logging_enabled    = false
  client_certificate_mode    = "Required"
  storage_account_name       = module.StorageAccount.name
  storage_account_access_key = module.StorageAccount.primary_access_key
  service_plan_id            = azurerm_service_plan.function.id

  app_settings = {
    "AZURE_BLOB_STORAGE_KEY"                     = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-BLOB-STORAGE-KEY)"
    "AZURE_FORM_RECOGNIZER_ENDPOINT"             = "https://${module.cognitive_account_form_recognizer.name}.cognitiveservices.azure.com/"
    "AZURE_FORM_RECOGNIZER_KEY"                  = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/${local.AZURE_FORM_RECOGNIZER_KEY})"
    "AZURE_SEARCH_INDEX"                         = local.AZURE_SEARCH_INDEX
    "AZURE_SEARCH_SERVICE_ENDPOINT"              = module.SearchService.endpoint
    "AZURE_SEARCH_SERVICE_KEY"                   = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/${local.AZURE_SEARCH_SERVICE_KEY})"
    "BLOB_CONNECTION_STRING"                     = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/BLOB-CONNECTION-STRING)"
    "BLOB_STORAGE_ACCOUNT"                       = module.StorageAccount.name
    "BLOB_STORAGE_ACCOUNT_ENDPOINT"              = module.StorageAccount.primary_blob_endpoint
    "BLOB_STORAGE_ACCOUNT_LOG_CONTAINER_NAME"    = "logs"
    "BLOB_STORAGE_ACCOUNT_OUTPUT_CONTAINER_NAME" = "content"
    "BLOB_STORAGE_ACCOUNT_UPLOAD_CONTAINER_NAME" = local.AZURE_BLOB_STORAGE_UPLOAD_CONTAINER
    "CHUNK_TARGET_SIZE"                          = "750"
    "COSMOSDB_KEY"                               = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/COSMOSDB-KEY)"
    "COSMOSDB_LOG_CONTAINER_NAME"                = local.COSMOSDB_LOG_CONTAINER_NAME
    "COSMOSDB_LOG_DATABASE_NAME"                 = local.COSMOSDB_LOG_DATABASE_NAME
    "COSMOSDB_TAGS_CONTAINER_NAME"               = local.COSMOSDB_TAGS_CONTAINER_NAME
    "COSMOSDB_TAGS_DATABASE_NAME"                = local.COSMOSDB_TAGS_DATABASE_NAME
    "COSMOSDB_URL"                               = module.CosmosDB.endpoint
    "EMBEDDINGS_QUEUE"                           = "embeddings-queue"
    "ENABLE_DEV_CODE"                            = "False"
    "ENRICHMENT_BACKOFF"                         = "60"
    "ENRICHMENT_ENDPOINT"                        = module.cognitive_account_enrichment.endpoint
    "ENRICHMENT_KEY"                             = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/ENRICHMENT-KEY)"
    "ENRICHMENT_LOCATION"                        = local.location
    "ENRICHMENT_NAME"                            = module.cognitive_account_enrichment.name
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
    value = module.StorageAccount.primary_connection_string
    type  = "MySql"
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = true
    app_scale_limit                         = 0
    application_insights_connection_string  = module.ApplicationInsights.connection_string
    application_insights_key                = module.ApplicationInsights.instrumentation_key
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

module "LogAnalyticsWorkspace" {
  source = "./_modules/LogAnalyticsWorkspace"

  name                = local.log_analytics_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

# todo russell this template_data is not correct
resource "azurerm_application_insights_workbook_template" "example" {
  name                = "infoasst-lw-geprk"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  priority            = 1

  galleries {
    category      = "Deployed Template"
    name          = "infoasst-lw-geprk"
    order         = 1
    resource_type = "Azure Monitor"
    type          = "workbook"
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
