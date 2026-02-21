# GCS bucket for Terraform remote state
resource "google_storage_bucket" "tfstate" {
  name     = "wanderlust-${var.environment}-tfstate"
  project  = var.project_id
  location = var.region

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true

  force_destroy = false
}
