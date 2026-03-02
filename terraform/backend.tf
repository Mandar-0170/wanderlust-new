# Terraform remote state backend (GCS bucket)
#
# Workflow:
#   1. Run the bootstrap module first:  cd bootstrap && terraform init && terraform apply
#   2. Copy the bucket name from:       terraform output state_bucket_name
#   3. Uncomment the block below and paste the bucket name
#   4. Run `terraform init` here to migrate local state to GCS
#   5. Terraform will prompt: "Do you want to copy existing state?" — answer yes

terraform {
  backend "gcs" {
    bucket = "bucket-rd-dev-tfstate"
    prefix = "terraform/state"
  }
}
