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
