# Terraform remote state backend (GCS bucket)
#
# Workflow:
#   1. First apply with this commented out (creates the bucket via storage module)
#   2. Uncomment the block below
#   3. Run `terraform init` to migrate state to the bucket

# terraform {
#   backend "gcs" {
#     bucket = "wanderlust-dev-tfstate"
#     prefix = "terraform/state"
#   }
# }
