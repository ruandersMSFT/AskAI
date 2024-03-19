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
