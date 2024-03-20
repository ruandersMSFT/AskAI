# Need AZURE-CLIENT-SECRET key vault secret from AAD Client

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "infoasst-myworkspace"
  location = local.location

  tags = local.tags
}

module "LogAnalyticsWorkspace" {
  source = "./_modules/LogAnalyticsWorkspace"

  name                = local.log_analytics_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

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

