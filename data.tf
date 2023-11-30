data "azurerm_private_dns_zone" "pdns" {
  provider            = azurerm.network
  name                = var.private_link_dns_zone.name
  resource_group_name = var.private_link_dns_zone.resource_group_name
}

data "azurerm_resource_group" "rg" {
  name = "rg-${var.tags["project"]}-${var.tags["env"]}"
}

data "azurerm_nat_gateway" "ng" {
  name                = var.subnet.natgateway_name
  resource_group_name = var.subnet.rg
}

data "azuread_group" "group" {
  display_name     = ""
  security_enabled = true
}