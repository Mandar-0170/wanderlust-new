# General 
project_id  = "playground-488307"
region      = "us-central1"
environment = "dev"
client_name = "rd"

# Networking
subnet_cidr   = "10.0.0.0/20"
pods_cidr     = "10.1.0.0/20"
services_cidr = "10.2.0.0/26"

# Bastion
zone                 = "us-central1-a"
bastion_machine_type = "e2-medium"
allowed_ssh_cidrs    = ["0.0.0.0/0"]

# GKE
gke_node_count   = 2
gke_machine_type = "e2-medium"
gke_disk_size_gb = 20
