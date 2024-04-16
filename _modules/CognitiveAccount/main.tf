resource "azurerm_cognitive_account" "this" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  kind                  = var.kind
  custom_subdomain_name = var.custom_subdomain_name
  public_network_access_enabled = var.public_network_access_enabled

  sku_name = var.sku_name

  tags = var.tags
}

resource "azurerm_cognitive_deployment" "this" {
  for_each = {for i, v in var.deployments:  i => v}

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.this.id

  model {
    format  = each.value.model.format
    name    = each.value.model.name
    version = each.value.model.version
  }

  rai_policy_name = each.value.rai_policy_name
  
  scale {
    type = each.value.scale.type
    capacity = each.value.scale.capacity
  }
}

module "PrivateEndpoint" {
  source = "../PrivateEndpoint"

  location                       = var.location
  name                           = var.name
  private_connection_resource_id = azurerm_cognitive_account.this.id
  private_dns_zone_ids           = var.private_dns_zone_ids
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  subresource_names              = ["account"]
}
