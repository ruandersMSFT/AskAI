module "StorageAccount" {
  source = "./../_modules/StorageAccount"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  containers = [
    {
      name                  = local.AZURE_BLOB_STORAGE_CONTAINER,
      container_access_type = "private"
    },
    {
      name                  = local.LOGS_CONTAINER,
      container_access_type = "private"
    },
    {
      name                  = local.FUNCTION_CONTAINER,
      container_access_type = "private"
    },
    {
      name                  = "upload",
      container_access_type = "private"
    },
    {
      name                  = "website",
      container_access_type = "private"
    }
  ]
  cors_rule = {
    allowed_headers    = ["*"]
    allowed_methods    = ["GET", "PUT", "OPTIONS", "POST", "PATCH", "HEAD"]
    allowed_origins    = ["*"]
    exposed_headers    = ["*"]
    max_age_in_seconds = 86400
  }
  delete_retention_policy_days = 7
  name                         = "infoasststoregeprk"
  account_tier                 = "Standard"
  account_replication_type     = "LRS"
  private_dns_zone_ids         = [azurerm_private_dns_zone.example.id]
  queues = [
    {
      name = local.PDF_SUBMIT_QUEUE
    },
    {
      name = local.PDF_POLLING_QUEUE
    },
    {
      name = local.NON_PDF_SUBMIT_QUEUE
    },
    {
      name = local.MEDIA_SUBMIT_QUEUE
    },
    {
      name = local.TEXT_ENRICHMENT_QUEUE
    },
    {
      name = local.IMAGE_ENRICHMENT_QUEUE
    },
    {
      name = local.EMBEDDINGS_QUEUE
    }
  ]
  subnet_id = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags      = local.tags
}

module "StorageAccountMedia" {
  source = "./../_modules/StorageAccount"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  cors_rule = {
    allowed_headers    = ["*"]
    allowed_methods    = ["GET", "PUT", "OPTIONS", "POST", "PATCH", "HEAD"]
    allowed_origins    = ["*"]
    exposed_headers    = ["*"]
    max_age_in_seconds = 86400
  }
  delete_retention_policy_days = 7
  name                         = "infoasststoremediageprk"
  account_tier                 = "Standard"
  account_replication_type     = "LRS"
  private_dns_zone_ids         = [azurerm_private_dns_zone.example.id]
  subnet_id                    = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags                         = local.tags
}

