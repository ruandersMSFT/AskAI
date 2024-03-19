module "cognitive_account_openai" {
  source = "./_modules/CognitiveAccount"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  custom_subdomain_name = "infoasst-aoai-geprk"
  kind                  = "OpenAI"
  name                  = "infoasst-aoai-geprk"
  private_dns_zone_ids            = [azurerm_private_dns_zone.example.id]
  sku_name = "S0"
  subnet_id                       = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags = local.tags
}
