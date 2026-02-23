# Docker repository for Wanderlust container images
resource "google_artifact_registry_repository" "docker" {
  repository_id = "wanderlust-${var.environment}"
  project       = var.project_id
  location      = var.region
  format        = "DOCKER"
  description   = "Docker images for Wanderlust ${var.environment}"
}
