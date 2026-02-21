# VPC
resource "google_compute_network" "vpc" {
  name                    = "wanderlust-${var.environment}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
}

# Subnet with secondary ranges for pods and services
resource "google_compute_subnetwork" "subnet" {
  name          = "wanderlust-${var.environment}-subnet"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr
  
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

# Firewall — allow internal traffic between nodes
resource "google_compute_firewall" "internal" {
  name    = "wanderlust-${var.environment}-allow-internal"
  project = var.project_id
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr, var.pods_cidr, var.services_cidr]
}
