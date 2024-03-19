# Need AZURE-CLIENT-SECRET key vault secret from AAD Client

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "infoasst-myworkspace"
  location = "EastUS"

  tags = local.tags
}

resource "azurerm_private_dns_zone" "example" {
  name                = "mydomain.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }
}

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

module "SearchService" {
  source = "./_modules/SearchService"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  name                        = "infoasst-search-geprk"
  authentication_failure_mode = "http401WithBearerChallenge"
  private_dns_zone_ids        = [azurerm_private_dns_zone.example.id]
  subnet_id                   = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags                        = local.tags
}

resource "azurerm_key_vault_secret" "AZURE_SEARCH_SERVICE_KEY" {
  name         = "AZURE-SEARCH-SERVICE-KEY"
  value        = module.SearchService.primary_key
  key_vault_id = module.KeyVault.id
}

module "CosmosDB" {
  source = "./_modules/CosmosDB"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  name                 = "infoasst-cosmos-geprk"
  kind                 = "GlobalDocumentDB"
  private_dns_zone_ids = [azurerm_private_dns_zone.example.id]
  subnet_id            = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags                 = local.tags
}

resource "azurerm_cosmosdb_sql_database" "log" {
  name                = local.COSMOSDB_LOG_DATABASE_NAME
  resource_group_name = module.CosmosDB.resource_group_name
  account_name        = module.CosmosDB.name
}

resource "azurerm_cosmosdb_sql_container" "log" {
  name                  = local.COSMOSDB_LOG_CONTAINER_NAME
  resource_group_name   = module.CosmosDB.resource_group_name
  account_name          = module.CosmosDB.name
  database_name         = azurerm_cosmosdb_sql_database.log.name
  partition_key_path    = "/file_path"
  partition_key_version = 1
  throughput            = 1000

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }
  }
}

resource "azurerm_cosmosdb_sql_database" "tag" {
  name                = local.COSMOSDB_TAGS_DATABASE_NAME
  resource_group_name = module.CosmosDB.resource_group_name
  account_name        = module.CosmosDB.name
}

resource "azurerm_cosmosdb_sql_container" "tag" {
  name                  = local.COSMOSDB_TAGS_CONTAINER_NAME
  resource_group_name   = module.CosmosDB.resource_group_name
  account_name          = module.CosmosDB.name
  database_name         = azurerm_cosmosdb_sql_database.tag.name
  partition_key_path    = "/file_path"
  partition_key_version = 1
  throughput            = 1000

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }
  }
}

resource "azurerm_key_vault_secret" "COSMOSDB_KEY" {
  name         = "COSMOSDB-KEY"
  value        = module.CosmosDB.primary_key
  key_vault_id = module.KeyVault.id
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
    "AZURE_BLOB_STORAGE_KEY"                = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-BLOB-STORAGE-KEY)"
    "AZURE_BLOB_STORAGE_UPLOAD_CONTAINER"   = local.AZURE_BLOB_STORAGE_UPLOAD_CONTAINER
    "AZURE_CLIENT_ID"                       = local.azure_client_id
    "AZURE_CLIENT_SECRET"                   = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-CLIENT-SECRET)"
    "AZURE_KEY_VAULT_ENDPOINT"              = module.KeyVault.vault_uri
    "AZURE_MANAGEMENT_URL"                  = local.management_url
    "AZURE_OPENAI_CHATGPT_DEPLOYMENT"       = "gpt-35-turbo-16k"
    "AZURE_OPENAI_CHATGPT_MODEL_NAME"       = ""
    "AZURE_OPENAI_CHATGPT_MODEL_VERSION"    = ""
    "AZURE_OPENAI_EMBEDDINGS_MODEL_NAME"    = ""
    "AZURE_OPENAI_EMBEDDINGS_MODEL_VERSION" = ""
    "AZURE_OPENAI_RESOURCE_GROUP"           = azurerm_cognitive_account.open_ai.resource_group_name
    "AZURE_OPENAI_SERVICE"                  = azurerm_cognitive_account.open_ai.name
    "AZURE_OPENAI_SERVICE_KEY"              = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-OPENAI-SERVICE-KEY)"
    "AZURE_SEARCH_INDEX"                    = "vector-index"
    "AZURE_SEARCH_SERVICE"                  = module.SearchService.name
    "AZURE_SEARCH_SERVICE_ENDPOINT"         = module.SearchService.endpoint
    "AZURE_SEARCH_SERVICE_KEY"              = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-SEARCH-SERVICE-KEY)"
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
  name                         = "infoasst-enrichmentasp-geprk"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  os_type                      = "Linux"
  sku_name                     = "P1v3"
  per_site_scaling_enabled     = false
  maximum_elastic_worker_count = 3
  zone_balancing_enabled       = false
  tags                         = local.tags
}


resource "azurerm_monitor_autoscale_setting" "example2" {
  name                = "iinfoasst-enrichmentasp-geprk-Autoscale"
  resource_group_name = azurerm_service_plan.example2.name
  location            = azurerm_service_plan.example2.location
  target_resource_id  = azurerm_service_plan.example2.id

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
        metric_resource_id = azurerm_service_plan.example2.id
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
        metric_resource_id = azurerm_service_plan.example2.id
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
  name                = "infoasst-enrichmentweb-geprk"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example2.location
  service_plan_id     = azurerm_service_plan.example2.id

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"  = azurerm_application_insights.example.connection_string
    "AZURE_BLOB_STORAGE_ACCOUNT"             = azurerm_storage_account.infoasststoregeprk.name
    "AZURE_BLOB_STORAGE_CONTAINER"           = "content"
    "AZURE_BLOB_STORAGE_ENDPOINT"            = "https://infoasststoregeprk.blob.core.windows.net/"
    "AZURE_BLOB_STORAGE_KEY"                 = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-BLOB-STORAGE-KEY)"
    "AZURE_BLOB_STORAGE_UPLOAD_CONTAINER"    = local.AZURE_BLOB_STORAGE_UPLOAD_CONTAINER
    "AZURE_KEY_VAULT_ENDPOINT"               = module.KeyVault.vault_uri
    "AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME" = "text-embedding-ada-002"
    "AZURE_OPENAI_SERVICE"                   = azurerm_cognitive_account.open_ai.name
    "AZURE_OPENAI_SERVICE_KEY"               = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-OPENAI-SERVICE-KEY)"
    "AZURE_SEARCH_INDEX"                     = "vector-index"
    "AZURE_SEARCH_SERVICE"                   = module.SearchService.name
    "AZURE_SEARCH_SERVICE_ENDPOINT"          = module.SearchService.endpoint
    "AZURE_SEARCH_SERVICE_KEY"               = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-SEARCH-SERVICE-KEY)"
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

resource "azurerm_service_plan" "example3" {
  name                = "infoasst-func-asp-geprk"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "S2"

  tags = local.tags
}

resource "azurerm_monitor_autoscale_setting" "example3" {
  name                = "infoasst-func-asp-geprk-Autoscale"
  resource_group_name = azurerm_service_plan.example3.name
  location            = azurerm_service_plan.example3.location
  target_resource_id  = azurerm_service_plan.example3.id

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
        metric_resource_id = azurerm_service_plan.example3.id
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
        metric_resource_id = azurerm_service_plan.example3.id
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
    "AZURE_BLOB_STORAGE_KEY"                     = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-BLOB-STORAGE-KEY)"
    "AZURE_FORM_RECOGNIZER_ENDPOINT"             = "https://${azurerm_cognitive_account.form_recognizer.name}.cognitiveservices.azure.com/"
    "AZURE_FORM_RECOGNIZER_KEY"                  = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-FORM-RECOGNIZER-KEY)"
    "AZURE_SEARCH_INDEX"                         = "vector-index"
    "AZURE_SEARCH_SERVICE_ENDPOINT"              = module.SearchService.endpoint
    "AZURE_SEARCH_SERVICE_KEY"                   = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-SEARCH-SERVICE-KEY)"
    "BLOB_CONNECTION_STRING"                     = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/BLOB-CONNECTION-STRING)"
    "BLOB_STORAGE_ACCOUNT"                       = azurerm_storage_account.infoasststoregeprk.name
    "BLOB_STORAGE_ACCOUNT_ENDPOINT"              = "https://infoasststoregeprk.blob.core.windows.net/"
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
    "ENRICHMENT_ENDPOINT"                        = "https://eastus.api.cognitive.microsoft.com/"
    "ENRICHMENT_KEY"                             = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/ENRICHMENT-KEY)"
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
  key_vault_id = module.KeyVault.id
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
  key_vault_id = module.KeyVault.id
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
  key_vault_id = module.KeyVault.id
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

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = local.tags
}

resource "azurerm_storage_container" "content" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.infoasststoregeprk.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "logs" {
  name                  = "logs"
  storage_account_name  = azurerm_storage_account.infoasststoregeprk.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "function" {
  name                  = "function"
  storage_account_name  = azurerm_storage_account.infoasststoregeprk.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "upload" {
  name                  = "upload"
  storage_account_name  = azurerm_storage_account.infoasststoregeprk.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "website" {
  name                  = "website"
  storage_account_name  = azurerm_storage_account.infoasststoregeprk.name
  container_access_type = "private"
}

resource "azurerm_storage_queue" "pdf_submit_queue" {
  name                 = "pdf-submit-queue"
  storage_account_name = azurerm_storage_account.infoasststoregeprk.name
}

resource "azurerm_storage_queue" "pdf_polling_queue" {
  name                 = "pdf-polling-queue"
  storage_account_name = azurerm_storage_account.infoasststoregeprk.name
}

resource "azurerm_storage_queue" "non_pdf_submit_queue" {
  name                 = "non-pdf-submit-queue"
  storage_account_name = azurerm_storage_account.infoasststoregeprk.name
}

resource "azurerm_storage_queue" "media_submit_queue" {
  name                 = "media-submit-queue"
  storage_account_name = azurerm_storage_account.infoasststoregeprk.name
}

resource "azurerm_storage_queue" "text_enrichment_queue" {
  name                 = "text-enrichment-queue"
  storage_account_name = azurerm_storage_account.infoasststoregeprk.name
}

resource "azurerm_storage_queue" "image_enrichment_queue" {
  name                 = "image-enrichment-queue"
  storage_account_name = azurerm_storage_account.infoasststoregeprk.name
}

resource "azurerm_storage_queue" "embeddings_queue" {
  name                 = "embeddings-queue"
  storage_account_name = azurerm_storage_account.infoasststoregeprk.name
}

resource "azurerm_key_vault_secret" "AZURE_BLOB_STORAGE_KEY" {
  name         = "AZURE-BLOB-STORAGE-KEY"
  value        = azurerm_storage_account.infoasststoregeprk.primary_access_key
  key_vault_id = module.KeyVault.id
}

resource "azurerm_key_vault_secret" "BLOB_CONNECTION_STRING" {
  name         = "BLOB-CONNECTION-STRING"
  value        = azurerm_storage_account.infoasststoregeprk.primary_connection_string
  key_vault_id = module.KeyVault.id
}

resource "azurerm_storage_account" "infoasststoremediageprk" {
  name                            = "infoasststoremediageprk"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = local.tags
}

resource "azurerm_media_services_account" "example" {
  name                = "examplemediaacc"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  public_network_access_enabled = false
  storage_account {
    id         = azurerm_storage_account.infoasststoremediageprk.id
    is_primary = true
  }

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

resource "azurerm_key_vault_access_policy" "function_app" {
  key_vault_id = module.KeyVault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_function_app.example.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "web" {
  key_vault_id = module.KeyVault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.web.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "enrichment" {
  key_vault_id = module.KeyVault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.enrichment.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = module.KeyVault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
    "Release",
    "Rotate",
    "GetRotationPolicy",
    "SetRotationPolicy",
  ]

  secret_permissions = [
    "Backup",
    "Get",
    "Delete",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]
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
  principal_id         = azurerm_linux_function_app.example.identity[0].principal_id
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
