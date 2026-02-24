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
  client_name   = var.client_name
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
  client_name = var.client_name

  depends_on = [module.apis]
}

# Bastion VM for SSH access to private resources
module "bastion" {
  source            = "./modules/bastion"
  project_id        = var.project_id
  region            = var.region
  zone              = var.zone
  environment       = var.environment
  client_name       = var.client_name
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
  client_name = var.client_name

  depends_on = [module.apis]
}

# Docker repository for container images
module "artifact_registry" {
  source      = "./modules/artifact-registry"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  client_name = var.client_name

  depends_on = [module.apis]
}

# GKE cluster and node pool
module "gke" {
  source                = "./modules/gke"
  project_id            = var.project_id
  region                = var.region
  zone                  = var.zone
  environment           = var.environment
  client_name           = var.client_name
  vpc_name              = module.networking.vpc_name
  subnet_name           = module.networking.subnet_name
  pods_range_name       = module.networking.pods_range_name
  services_range_name   = module.networking.services_range_name
  service_account_email = module.iam.gke_service_account_email
  node_count            = var.gke_node_count
  machine_type          = var.gke_machine_type
  disk_size_gb          = var.gke_disk_size_gb

  depends_on = [module.networking, module.iam]
}
