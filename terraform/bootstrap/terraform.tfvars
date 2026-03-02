# ──────────────────────────────────────────────────────────────────────────────
# Bootstrap-specific variables ONLY
# ──────────────────────────────────────────────────────────────────────────────
# Common variables (project_id, region, environment, client_name) are shared
# with the main infra. Pass them using -var-file:
#
#   terraform apply -var-file="../terraform.tfvars" -var-file="terraform.tfvars"
#
# ──────────────────────────────────────────────────────────────────────────────


project_number = "917443109321"

# GitHub details (for Workload Identity Federation)
github_org  = "Mandar-0170"
github_repo = "wanderlust-new"
