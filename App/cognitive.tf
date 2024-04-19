module "cognitive_account_openai" {
  source = "./../_modules/CognitiveAccount"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  custom_subdomain_name = local.openai_name
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
  name                 = local.openai_name
  private_dns_zone_ids = [local.private_dns_zone_id_cognitiveservices]
  sku_name             = "S0"
  subnet_id            = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags                 = local.tags
}

module "cognitive_account_form_recognizer" {
  source = "./../_modules/CognitiveAccount"

  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  custom_subdomain_name = local.form_recognizer_name
  kind                  = "FormRecognizer"
  name                  = local.form_recognizer_name
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
  name                 = local.enrichment_name
  private_dns_zone_ids = [local.private_dns_zone_id_cognitiveservices]
  sku_name             = "S0"
  subnet_id            = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags                 = local.tags
}
