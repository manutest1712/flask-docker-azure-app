variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "client_id" {
  type        = string
  description = "Azure service principal client ID"
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Azure service principal client secret"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "resource_location" {
  type    = string
  default = "eastus"
}

variable "app_service_plan_name" { default = "asp-flask-linux" }
variable "app_name" { default = "flask-webapp-manu-app" } 

variable "acr_name" { default = "flaskapiregistry2025" }                   # registry name (no .azurecr.io)
variable "image_repository" { default = "flaskapp" }            # repository inside ACR
variable "image_tag" { default = "latest" }   

variable "acr_admin_username" {
  type        = string
  sensitive   = true
  description = "container registry admin user name"
}

variable "acr_admin_password" {
  type        = string
  sensitive   = true
  description = "container registry admin password"
}
