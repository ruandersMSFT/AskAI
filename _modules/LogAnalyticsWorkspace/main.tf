terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days

  tags = var.tags
}

# https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/workbooktemplates?pivots=deployment-language-terraform
resource "azapi_resource" "workbooktemplates" {
  type      = "Microsoft.Insights/workbooktemplates@2020-11-20"
  name      = "todonowrussell"
  location  = var.location
  parent_id = azurerm_log_analytics_workspace.this.id
  tags      = var.tags
  body = jsonencode({
    properties = {
      galleries = [
        {
          category : "Deployed Template"
          name : var.name
          order : 1
          resourceType : "Azure Monitor"
          type : "workbook"
        }
      ]
      priority = 1
      templateData = {
        version : "Notebook/1.0"
        items : [
          {
            type : 1
            content : {
              json : "\r\n\r\nApplication Logs (Last 6 Hours)"
            }
            name : "text - 3"
          },
          {
            type : 3
            content : {
              version : "KqlItem/1.0"
              query : "AppServiceConsoleLogs | project TimeGenerated, ResultDescription, _ResourceId | where TimeGenerated > ago(6h) | order by TimeGenerated desc"
              size : 0
              timeContext : {
                durationMs : 86400000
              }
              queryType : 0
              resourceType : "microsoft.operationalinsights/workspaces"
              crossComponentResources : [
                azurerm_log_analytics_workspace.this.id
              ]
            }
            name : "App Logs"
          },
          {
            type : 1
            content : {
              json : "Function Logs (Last 6 Hours)"
            }
            name : "text - 4"
          },
          {
            type : 3
            content : {
              version : "KqlItem/1.0"
              query : "AppTraces | project TimeGenerated, Message, Properties | where TimeGenerated > ago(6h) | order by TimeGenerated desc"
              size : 0
              timeContext : {
                durationMs : 86400000
              }
              queryType : 0
              resourceType : "microsoft.operationalinsights/workspaces"
              crossComponentResources : [
                azurerm_log_analytics_workspace.this.id
              ]
            }
            name : "query - 1"
          },
          {
            type : 1
            content : {
              json : "App Service Deployment Logs (Last 6 Hours)"
            }
            name : "text - 5"
          },
          {
            type : 3
            content : {
              version : "KqlItem/1.0"
              query : "AppServicePlatformLogs | project TimeGenerated, Level, Message, _ResourceId | where TimeGenerated > ago(6h) | order by TimeGenerated desc"
              size : 0
              timeContext : {
                durationMs : 86400000
              }
              queryType : 0
              resourceType : "microsoft.operationalinsights/workspaces"
              crossComponentResources : [
                azurerm_log_analytics_workspace.this.id
              ]
            }
            name : "query - 2"
          }
        ]
        fallbackResourceIds : [
          "Azure Monitor"
        ]
      }
    }

  })
}
