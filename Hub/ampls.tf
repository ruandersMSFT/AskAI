#https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/privatelinkscopes?pivots=deployment-language-terraform

resource "azurerm_monitor_private_link_scope" "example" {
  name                = "example-ampls"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_monitor_private_link_scoped_service" "loganalytics" {
  name                = "loganalytics-amplsservice"
  resource_group_name = azurerm_monitor_private_link_scope.example.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.example.name
  linked_resource_id  = module.LogAnalyticsWorkspace.id
}

resource "azurerm_monitor_private_link_scoped_service" "applicationinsights" {
  name                = "applicationinsights-amplsservice"
  resource_group_name = azurerm_monitor_private_link_scope.example.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.example.name
  linked_resource_id  = module.subscriptionInsights.id
}
  