module "AppServiceEnvironment" {
  source = "./_modules/AppServiceEnvironment"

  name = local.app_service_environment_name
  resource_group_name = azurerm_resource_group.example.name
  subnet_id = "${azurerm_virtual_network.example.id}/subnets/subnet1"
  tags = local.tags

}
