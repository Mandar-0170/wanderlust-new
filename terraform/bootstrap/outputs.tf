
output "state_bucket_name" {
  description = "GCS bucket name for Terraform remote state — use in backend.tf"
  value       = google_storage_bucket.tfstate.name
}

output "github_actions_sa_email" {
  description = "Service account email for GitHub Actions — use in GitHub Actions workflow"
  value       = google_service_account.github_actions.email
}

output "workload_identity_provider" {
  description = "Full resource name of the WIF provider — use in google-github-actions/auth"
  value       = google_iam_workload_identity_pool_provider.github.name
}
