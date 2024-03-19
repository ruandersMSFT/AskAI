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
