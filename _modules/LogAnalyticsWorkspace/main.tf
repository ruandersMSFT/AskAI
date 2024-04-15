resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days

  tags = var.tags
}

resource "azurerm_monitor_private_link_scoped_service" "this" {
  name                = "${var.name}-amplsservice"
  resource_group_name = azurerm_monitor_private_link_scope.example.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.example.name
  linked_resource_id  = azurerm_log_analytics_workspace.this.id
}
