# Enable required GCP APIs first
module "apis" {
  source     = "./modules/apis"
  project_id = var.project_id
}

# -- VPC, subnet, firewall (uncomment when subnet ranges are available)
module "networking" {
  source        = "./modules/networking"
  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr

  depends_on = [module.apis]
}

# Service account and IAM roles for GKE nodes
module "iam" {
  source      = "./modules/iam"
  project_id  = var.project_id
  environment = var.environment

  depends_on = [module.apis]
}
