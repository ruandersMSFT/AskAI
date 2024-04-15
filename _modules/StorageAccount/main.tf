resource "azurerm_storage_account" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  public_network_access_enabled   = var.public_network_access_enabled

  blob_properties {
    dynamic "cors_rule" {
      for_each = var.cors_rule == null ? [] : ["fake"]
      content {
        allowed_headers = var.cors_rule.allowed_headers
        allowed_methods = var.cors_rule.allowed_methods
        allowed_origins = var.cors_rule.allowed_origins
        exposed_headers = var.cors_rule.exposed_headers
        max_age_in_seconds = var.cors_rule.max_age_in_seconds
      }
    }

    dynamic "delete_retention_policy" {
      for_each = var.delete_retention_policy_days == null ? [] : ["fake"]
      content {
        days = var.delete_retention_policy_days
      }
    }
  }

  tags = var.tags
}

module "PrivateEndpoint" {
  source = "../PrivateEndpoint"

  location                       = var.location
  name                           = var.name
  private_connection_resource_id = azurerm_storage_account.this.id
  private_dns_zone_ids           = var.private_dns_zone_ids
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.subnet_id
  subresource_names              = ["blob", "blob_secondary"]
}
