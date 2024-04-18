module "cognitive_account_openai" {
  source = "./../_modules/CognitiveAccount"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  custom_subdomain_name = "infoasst-aoai"
  deployments = [
    {
      model = {
        format  = "OpenAI"
        name    = "gpt-35-turbo-16k"
        version = "0613"
      }
      name            = "gpt-35-turbo-16k"
      rai_policy_name = "Microsoft.Default"
      scale = {
        type     = "Standard"
        capacity = 240
      }
    },
    {
      model = {
        format  = "OpenAI"
        name    = "text-embedding-ada-002"
        version = "2"
      }
      name            = "text-embedding-ada-002"
      rai_policy_name = "Microsoft.Default"
      scale = {
        type     = "Standard"
        capacity = 240
      }
    }
  ]
  kind                 = "OpenAI"
  name                 = "infoasst-aoai"
  private_dns_zone_ids = [local.private_dns_zone_id_cognitiveservices]
  sku_name             = "S0"
  subnet_id            = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags                 = local.tags
}

module "cognitive_account_form_recognizer" {
  source = "./../_modules/CognitiveAccount"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  custom_subdomain_name = "infoasst-fr"
  kind                  = "FormRecognizer"
  name                  = "infoasst-fr"
  private_dns_zone_ids  = [local.private_dns_zone_id_cognitiveservices]
  sku_name              = "S0"
  subnet_id             = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags                  = local.tags
}

module "cognitive_account_enrichment" {
  source = "./../_modules/CognitiveAccount"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  kind                 = "CognitiveServices"
  name                 = "infoasst-enrichment-cog"
  private_dns_zone_ids = [local.private_dns_zone_id_cognitiveservices]
  sku_name             = "S0"
  subnet_id            = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags                 = local.tags
}
