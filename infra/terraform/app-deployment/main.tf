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


data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.main.name
}

# -------------------------
# Azure App service plab
# -------------------------

resource "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name


  # For Linux/web apps set kind = "Linux" and reserved = true
  # We'll create a Windows app (default). To use Linux, uncomment reserved & kind and adjust runtime accordingly.
  # kind     = "Linux"
  sku_name = "B1"
  os_type  = "Linux"
}

resource "azurerm_linux_web_app" "web" {
  name                = var.app_name
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.asp.id

  identity {
    type = "SystemAssigned"   # optional here (not used for auth in Option A)
  }

  site_config {
    application_stack {
      docker_image_name = "${var.image_repository}:latest"
      docker_registry_url      = "https://${data.azurerm_container_registry.acr.login_server}"
      docker_registry_username = var.acr_admin_username
      docker_registry_password = var.acr_admin_password
    }
        # Remove always_on OR set false
    always_on = true
  }

  app_settings = {
    WEBSITES_PORT = "8000"   # If Flask listens on :8000
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    CONTAINER_LOGGING_ENABLED = "true"
  }
}

resource "azurerm_role_assignment" "acr_pull1" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.web.identity[0].principal_id
  
}