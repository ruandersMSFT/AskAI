locals {
  azure_client_id = "3aff5d4e-1f13-4a7d-947e-612aae549f5d" # Russell's Tenant
  management_url = "https://management.core.windows.net/"

  tags = {
    "FISMA_Id"      = ""
    "TerraformRepo" = "SomePath"
  }
}