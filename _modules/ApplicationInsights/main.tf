resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type
  sampling_percentage = var.sampling_percentage
  workspace_id        = var.workspace_id

  tags = var.tags
}

resource "azurerm_monitor_private_link_scoped_service" "this" {
  name                = "${var.name}-amplsservice"
  resource_group_name = azurerm_monitor_private_link_scope.example.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.example.name
  linked_resource_id  = azurerm_application_insights.this.id
}
