# Any data sources you want to fetch from outside the module

data "azurerm_resource_group" "rg" {
  name = var.resource_group
}
