### Variables
# Global
variable "project_id" {
  description = "GCP Project id"
  type        = string
}
# APIs
variable "enabled_apis" {
  description = "List of enabled GCP APIs."
  type        = list(string)
}
# Container Registry
variable "gcr_location" {
  description = "Location for Container Registry."
  type        = string
}

### Provider
provider "google" {
  project = var.project_id
}

### Resources / Modules
# Enable all needed service API's
resource "google_project_service" "project" {
  for_each                   = toset(var.enabled_apis)
  service                    = each.key
  disable_dependent_services = true
}

# Create container registry
# ATTENTION: Destroying this resource does NOT destroy the backing bucket. Will keep this behaviour for now as it protects against accidental deletion of the registry and all its contents. For more information see the official documentation.
resource "google_container_registry" "registry" {
  project  = var.project_id
  location = var.gcr_location
}
