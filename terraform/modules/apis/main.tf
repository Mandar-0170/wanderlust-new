# Enables all required GCP APIs for the project

locals {
  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
}

resource "google_project_service" "enabled" {
  for_each = toset(local.apis)

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}
