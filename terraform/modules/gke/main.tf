# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "wanderlust-${var.environment}-cluster"
  project  = var.project_id
  location = var.region

  # We manage the node pool separately
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.vpc_name
  subnetwork = var.subnet_name

  # VPC-native mode using secondary ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Private cluster — nodes have no public IPs
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

# Separately managed node pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "wanderlust-${var.environment}-nodes"
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type    = var.machine_type
    disk_size_gb    = var.disk_size_gb
    disk_type       = "pd-standard"
    service_account = var.service_account_email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    # Network tags for firewall rule targeting
    tags = ["gke-node"]
  }
}
