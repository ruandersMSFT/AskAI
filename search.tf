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
