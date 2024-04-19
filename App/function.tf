resource "azurerm_service_plan" "function" {
  app_service_environment_id = module.AppServiceEnvironment.id
  name                       = local.app_service_plan_function_name
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  os_type                    = "Linux"
  sku_name                   = "I1v2"

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
    "BLOB_STORAGE_ACCOUNT_LOG_CONTAINER_NAME"    = local.LOGS_CONTAINER
    "BLOB_STORAGE_ACCOUNT_OUTPUT_CONTAINER_NAME" = local.AZURE_BLOB_STORAGE_CONTAINER
    "BLOB_STORAGE_ACCOUNT_UPLOAD_CONTAINER_NAME" = local.AZURE_BLOB_STORAGE_UPLOAD_CONTAINER
    "CHUNK_TARGET_SIZE"                          = "750"
    "COSMOSDB_KEY"                               = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/COSMOSDB-KEY)"
    "COSMOSDB_LOG_CONTAINER_NAME"                = local.COSMOSDB_LOG_CONTAINER_NAME
    "COSMOSDB_LOG_DATABASE_NAME"                 = local.COSMOSDB_LOG_DATABASE_NAME
    "COSMOSDB_TAGS_CONTAINER_NAME"               = local.COSMOSDB_TAGS_CONTAINER_NAME
    "COSMOSDB_TAGS_DATABASE_NAME"                = local.COSMOSDB_TAGS_DATABASE_NAME
    "COSMOSDB_URL"                               = module.CosmosDB.endpoint
    "EMBEDDINGS_QUEUE"                           = local.EMBEDDINGS_QUEUE
    "ENABLE_DEV_CODE"                            = local.ENABLE_DEV_CODE
    "ENRICHMENT_BACKOFF"                         = "60"
    "ENRICHMENT_ENDPOINT"                        = module.cognitive_account_enrichment.endpoint
    "ENRICHMENT_KEY"                             = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/ENRICHMENT-KEY)"
    "ENRICHMENT_LOCATION"                        = local.location
    "ENRICHMENT_NAME"                            = module.cognitive_account_enrichment.name
    "FR_API_VERSION"                             = "2023-07-31"
    "IMAGE_ENRICHMENT_QUEUE"                     = local.IMAGE_ENRICHMENT_QUEUE
    "MAX_ENRICHMENT_REQUEUE_COUNT"               = "10"
    "MAX_POLLING_REQUEUE_COUNT"                  = "10"
    "MAX_READ_ATTEMPTS"                          = "5"
    "MAX_SECONDS_HIDE_ON_UPLOAD"                 = "300"
    "MAX_SUBMIT_REQUEUE_COUNT"                   = "10"
    "MEDIA_SUBMIT_QUEUE"                         = local.MEDIA_SUBMIT_QUEUE
    "NON_PDF_SUBMIT_QUEUE"                       = local.NON_PDF_SUBMIT_QUEUE
    "PDF_POLLING_QUEUE"                          = local.PDF_POLLING_QUEUE
    "PDF_SUBMIT_QUEUE"                           = local.PDF_SUBMIT_QUEUE
    "PDF_SUBMIT_QUEUE_BACKOFF"                   = "60"
    "POLLING_BACKOFF"                            = "30"
    "POLL_QUEUE_SUBMIT_BACKOFF"                  = "60"
    "SUBMIT_REQUEUE_HIDE_SECONDS"                = "1200"
    "TARGET_PAGES"                               = "ALL"
    "TARGET_TRANSLATION_LANGUAGE"                = "en"
    "TEXT_ENRICHMENT_QUEUE"                      = local.TEXT_ENRICHMENT_QUEUE
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
    application_insights_connection_string  = module.subscriptionInsights.connection_string
    application_insights_key                = module.subscriptionInsights.instrumentation_key
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
