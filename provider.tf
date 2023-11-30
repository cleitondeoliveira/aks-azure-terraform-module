terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.31.0"
    }
  }
}

provider "azuread" {
  client_id     = var.ARM_CLIENT_ID
  client_secret = var.ARM_CLIENT_SECRET
  tenant_id     = var.ARM_TENANT_ID
}

provider "azurerm" {
  alias           = "network"
  subscription_id = var.private_link_dns_zone.subscription_id
  features {}
}