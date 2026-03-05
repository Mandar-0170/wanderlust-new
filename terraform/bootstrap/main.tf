
locals {
  sa_account_id = "sa-${var.client_name}-${var.environment}-ghactions"
  pool_id       = "pool-${var.client_name}-${var.environment}-github"
  provider_id   = "provider-${var.client_name}-${var.environment}-github"
  bucket_name   = "bucket-${var.client_name}-${var.environment}-tfstate"

  # IAM roles granted to the GitHub Actions SA
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

# Enabling APIS

resource "google_project_service" "bootstrap_apis" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "storage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}


# 2. GCS bucket for storing Terraform state


resource "google_storage_bucket" "tfstate" {
  name     = local.bucket_name
  project  = var.project_id
  location = var.region

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
  force_destroy               = false 

  depends_on = [google_project_service.bootstrap_apis]
}

# 3. SA for GitHub Actions

resource "google_service_account" "github_actions" {
  account_id   = local.sa_account_id
  display_name = "GitHub Actions CI/CD (${var.environment})"
  project      = var.project_id

  depends_on = [google_project_service.bootstrap_apis]
}

resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset(local.github_actions_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# 4. WORKLOAD IDENTITY FEDERATION (Keyless auth for GitHub Actions)

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = local.pool_id
  display_name              = "GitHub Actions Pool (${var.environment})"
  description               = "Workload Identity Pool for GitHub Actions CI/CD"

  depends_on = [google_project_service.bootstrap_apis]
}

# Provider — configures GitHub's OIDC as the identity source
resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = local.provider_id
  display_name                       = "GitHub OIDC Provider"

  # Accept OIDC tokens from GitHub
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com" #Github's officail OIDC Token Issueer
  }

  # Contents of OIDC token are mapped with Google Attributes so that it understands the token.
  attribute_mapping = {
    "google.subject"       = "assertion.sub" # Unique identity string
    "attribute.actor"      = "assertion.actor" # Github username
    "attribute.repository" = "assertion.repository" # Repositry name
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
