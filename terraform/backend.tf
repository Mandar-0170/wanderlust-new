# Backend config values are in backend.hcl (partial config).
# Usage: terraform init -backend-config=backend.hcl
terraform {
  backend "gcs" {}
}
