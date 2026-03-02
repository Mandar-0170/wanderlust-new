# ============================================================================
# BOOTSTRAP MODULE
# ============================================================================
# This module is run ONCE by a human admin to create:
#   1. GCS bucket for Terraform remote state
#   2. Service account for GitHub Actions
#   3. Workload Identity Federation (Pool + Provider) for keyless auth
#   4. IAM roles so GitHub Actions SA can manage all GCP infra
#
# Prerequisites:
#   Enable required APIs before running (bootstrap runs BEFORE the apis module):
#     gcloud services enable iam.googleapis.com iamcredentials.googleapis.com \
#       sts.googleapis.com storage.googleapis.com cloudresourcemanager.googleapis.com \
#       --project=<PROJECT_ID>
#
# Usage:
#   cd terraform/bootstrap
#   terraform init
#   terraform apply -var-file="../terraform.tfvars" -var-file="terraform.tfvars"
# ============================================================================

# All resource names follow the repo convention: ResourceName-Client-Environment-Description
locals {
  sa_account_id = "sa-${var.client_name}-${var.environment}-ghactions"
  pool_id       = "pool-${var.client_name}-${var.environment}-github"
  provider_id   = "provider-${var.client_name}-${var.environment}-github"
  bucket_name   = "bucket-${var.client_name}-${var.environment}-tfstate"

  # IAM roles granted to the GitHub Actions SA
  # These are the permissions GitHub Actions needs to create/manage all infra
  github_actions_roles = [
    "roles/compute.admin",                   # VPC, subnets, firewalls, bastion VM
    "roles/container.admin",                 # GKE clusters and node pools
    "roles/iam.serviceAccountAdmin",         # Create/manage GKE node SA
    "roles/iam.serviceAccountUser",          # Attach SAs to resources
    "roles/resourcemanager.projectIamAdmin", # Bind IAM roles to SAs
    "roles/storage.admin",                   # Manage GCS buckets (state + any others)
    "roles/artifactregistry.admin",          # Manage Artifact Registry repos
    "roles/serviceusage.serviceUsageAdmin",  # Enable/disable GCP APIs
  ]
}

# ──────────────────────────────────────────────────────────────────────────────
# 1. GCS BUCKET FOR TERRAFORM STATE
# ──────────────────────────────────────────────────────────────────────────────

resource "google_storage_bucket" "tfstate" {
  name     = local.bucket_name
  project  = var.project_id
  location = var.region

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
  force_destroy               = false # Protect state from accidental deletion
}

# ──────────────────────────────────────────────────────────────────────────────
# 2. SERVICE ACCOUNT FOR GITHUB ACTIONS
# ──────────────────────────────────────────────────────────────────────────────

resource "google_service_account" "github_actions" {
  account_id   = local.sa_account_id
  display_name = "GitHub Actions CI/CD (${var.environment})"
  project      = var.project_id
}

resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset(local.github_actions_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# ──────────────────────────────────────────────────────────────────────────────
# 3. WORKLOAD IDENTITY FEDERATION (Keyless auth for GitHub Actions)
# ──────────────────────────────────────────────────────────────────────────────

# Pool — a container for external identity providers
resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = local.pool_id
  display_name              = "GitHub Actions Pool (${var.environment})"
  description               = "Workload Identity Pool for GitHub Actions CI/CD"
}

# Provider — configures GitHub's OIDC as the identity source
resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = local.provider_id
  display_name                       = "GitHub OIDC Provider"

  # Accept OIDC tokens from GitHub
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # Map GitHub token claims to Google attributes
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  # SECURITY: Only allow tokens from YOUR specific repo
  attribute_condition = "assertion.repository == \"${var.github_org}/${var.github_repo}\""
}

# Allow the WIF pool to impersonate the GitHub Actions SA
resource "google_service_account_iam_member" "wif_sa_binding" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${local.pool_id}/attribute.repository/${var.github_org}/${var.github_repo}"

  depends_on = [google_iam_workload_identity_pool_provider.github]
}
