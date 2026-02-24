# Bastion VM
resource "google_compute_instance" "bastion" {
  name         = "vm-${var.client_name}-${var.environment}-bastion"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet

    # Public IP for SSH access
    access_config {}
  }

  tags = ["bastion"]

  metadata = {
    enable-oslogin = "TRUE"
  }
}

# Allow SSH to bastion from specified CIDRs
resource "google_compute_firewall" "bastion_ssh" {
  name    = "fw-${var.client_name}-${var.environment}-ssh"
  project = var.project_id
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidrs
  target_tags   = ["bastion"]
}
