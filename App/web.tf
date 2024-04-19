resource "azurerm_service_plan" "web" {
  app_service_environment_id = module.AppServiceEnvironment.id
  name                       = local.app_service_plan_web_name
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  os_type                    = "Linux"
  sku_name                   = "I1v2"
  tags                       = local.tags
}

resource "azurerm_linux_web_app" "web" {
  name                = local.web_app_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.web.location
  service_plan_id     = azurerm_service_plan.web.id

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = module.subscriptionInsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.subscriptionInsights.connection_string
    "APPLICATION_TITLE"                     = ""
    "AZURE_BLOB_STORAGE_ACCOUNT"            = module.StorageAccount.name
    "AZURE_BLOB_STORAGE_CONTAINER"          = local.AZURE_BLOB_STORAGE_CONTAINER
    "AZURE_BLOB_STORAGE_ENDPOINT"           = module.StorageAccount.primary_blob_endpoint
    "AZURE_BLOB_STORAGE_KEY"                = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-BLOB-STORAGE-KEY)"
    "AZURE_BLOB_STORAGE_UPLOAD_CONTAINER"   = local.AZURE_BLOB_STORAGE_UPLOAD_CONTAINER
    "AZURE_CLIENT_ID"                       = local.azure_client_id
    "AZURE_CLIENT_SECRET"                   = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/AZURE-CLIENT-SECRET)"
    "AZURE_KEY_VAULT_ENDPOINT"              = module.KeyVault.vault_uri
    "AZURE_MANAGEMENT_URL"                  = local.azure_management_url
    "AZURE_OPENAI_CHATGPT_DEPLOYMENT"       = local.AZURE_OPENAI_CHATGPT_DEPLOYMENT
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
    "CHAT_WARNING_BANNER_TEXT"              = local.CHAT_WARNING_BANNER_TEXT
    "COSMOSDB_KEY"                          = "@Microsoft.KeyVault(SecretUri=${module.KeyVault.vault_uri}/secrets/COSMOSDB-KEY)"
    "COSMOSDB_LOG_CONTAINER_NAME"           = local.COSMOSDB_LOG_CONTAINER_NAME
    "COSMOSDB_LOG_DATABASE_NAME"            = local.COSMOSDB_LOG_DATABASE_NAME
    "COSMOSDB_TAGS_CONTAINER_NAME"          = local.COSMOSDB_TAGS_CONTAINER_NAME
    "COSMOSDB_TAGS_DATABASE_NAME"           = local.COSMOSDB_TAGS_DATABASE_NAME
    "COSMOSDB_URL"                          = module.CosmosDB.endpoint
    "EMBEDDING_DEPLOYMENT_NAME"             = local.EMBEDDING_DEPLOYMENT_NAME
    "ENABLE_ORYX_BUILD"                     = local.ENABLE_ORYX_BUILD
    "ENRICHMENT_APPSERVICE_NAME"            = azurerm_linux_web_app.enrichment.name
    "IS_GOV_CLOUD_DEPLOYMENT"               = local.IS_GOV_CLOUD_DEPLOYMENT
    "QUERY_TERM_LANGUAGE"                   = local.QUERY_TERM_LANGUAGE
    "SCM_DO_BUILD_DURING_DEPLOYMENT"        = local.SCM_DO_BUILD_DURING_DEPLOYMENT
    "TARGET_EMBEDDINGS_MODEL"               = local.TARGET_EMBEDDINGS_MODEL
    "USE_AZURE_OPENAI_EMBEDDINGS"           = local.USE_AZURE_OPENAI_EMBEDDINGS
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
      client_id                       = local.active_directory_client_id
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

resource "azurerm_monitor_diagnostic_setting" "web" {
  name                       = "web"
  target_resource_id         = azurerm_linux_web_app.web.id
  log_analytics_workspace_id = module.LogAnalyticsWorkspace.id

  log {
    category = "AppServiceAppLogs"

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AppServicePlatformLogs"

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "AppServiceConsoleLogs"

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
