# Service account for GKE nodes
resource "google_service_account" "gke_nodes" {
  account_id   = "sa-${var.client_name}-${var.environment}-gke"
  display_name = "sa-${var.client_name}-${var.environment}-gke"
  project      = var.project_id
}

# Least-privilege roles for GKE nodes
locals {
  gke_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader",
  ]
}

resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset(local.gke_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}
