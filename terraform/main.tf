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

# Bastion VM for SSH access to private resources
module "bastion" {
  source            = "./modules/bastion"
  project_id        = var.project_id
  region            = var.region
  zone              = var.zone
  environment       = var.environment
  network           = module.networking.vpc_id
  subnet            = module.networking.subnet_name
  machine_type      = var.bastion_machine_type
  allowed_ssh_cidrs = var.allowed_ssh_cidrs

  depends_on = [module.networking]
}

# GCS bucket for Terraform remote state
module "storage" {
  source      = "./modules/storage"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment

  depends_on = [module.apis]
}
