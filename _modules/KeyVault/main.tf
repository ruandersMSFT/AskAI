resource "azurerm_key_vault" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = var.soft_delete_retention_days
  public_network_access_enabled   = var.public_network_access_enabled
  purge_protection_enabled        = var.purge_protection_enabled

  sku_name = var.sku_name
  tags     = var.tags
}

module "PrivateEndpoint" {
  source = "../PrivateEndpoint"

  location                       = var.location
  name                           = var.name
  private_connection_resource_id = azurerm_key_vault.this.id
  private_dns_zone_ids           = var.private_dns_zone_ids
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  subresource_names              = ["vault"]
}
