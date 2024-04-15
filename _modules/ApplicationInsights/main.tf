resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type
  sampling_percentage = var.sampling_percentage
  workspace_id        = var.workspace_id

  tags = var.tags
}
