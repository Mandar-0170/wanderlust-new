# Docker repository for Wanderlust container images
resource "google_artifact_registry_repository" "docker" {
  repository_id = "registry-${var.client_name}-${var.environment}-docker"
  project       = var.project_id
  location      = var.region
  format        = "DOCKER"
  description   = "Registry-${var.client_name}-${var.environment}-Docker"
}
