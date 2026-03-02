# ──────────────────────────────────────────────────────────────────────────────
# Bootstrap-specific variables ONLY
# ──────────────────────────────────────────────────────────────────────────────
# Common variables (project_id, region, environment, client_name) are shared
# with the main infra. Pass them using -var-file:
#
#   terraform apply -var-file="../terraform.tfvars" -var-file="terraform.tfvars"
#
# ──────────────────────────────────────────────────────────────────────────────

# Get this via: gcloud projects describe <PROJECT_ID> --format='value(projectNumber)'
project_number = ""  # <-- FILL THIS IN

# GitHub details (for Workload Identity Federation)
github_org  = ""  # <-- FILL THIS IN (e.g. "your-username" or "your-org")
github_repo = ""  # <-- FILL THIS IN (e.g. "wanderlust")
