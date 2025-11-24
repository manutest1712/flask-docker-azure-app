terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# -------------------------
# Resource Group
# -------------------------
data "azurerm_resource_group" "main" {
  name     = "Azuredevops"
}

# -------------------------
# Azure Container Registry
# -------------------------
resource "azurerm_container_registry" "acr" {
  name                = "flaskapiregistry2025"   # MUST be globally unique
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.resource_location
  sku                 = "Basic"

  admin_enabled       = true   # enables username/password login (useful for GitHub actions)
}
