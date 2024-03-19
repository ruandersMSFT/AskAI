resource "azurerm_cosmosdb_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = var.kind

  enable_automatic_failover = var.enable_automatic_failover
  public_network_access_enabled = var.public_network_access_enabled

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

  tags = var.tags
}

module "PrivateEndpoint" {
  source = "../PrivateEndpoint"

  location                       = var.location
  name                           = var.name
  private_connection_resource_id = azurerm_cosmosdb_account.this.id
  private_dns_zone_ids           = var.private_dns_zone_ids
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  subresource_names              = ["SQL"]
}
