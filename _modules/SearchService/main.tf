resource "azurerm_search_service" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  authentication_failure_mode   = var.authentication_failure_mode
  semantic_search_sku           = var.semantic_search_sku
  public_network_access_enabled = var.public_network_access_enabled

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

module "PrivateEndpoint" {
  source = "../PrivateEndpoint"

  location                       = var.location
  name                           = var.name
  private_connection_resource_id = azurerm_search_service.this.id
  private_dns_zone_ids           = var.private_dns_zone_ids
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  subresource_names              = ["searchService"]
}
