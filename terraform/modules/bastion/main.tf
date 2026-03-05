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

  # Attach service account so the VM can authenticate to GKE
  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = ["bastion"]

  metadata = {
    enable-oslogin = "TRUE"
  }

  # Install gcloud CLI, kubectl, and GKE auth plugin on first boot
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e
    export DEBIAN_FRONTEND=noninteractive

    # Install dependencies
    apt-get update
    apt-get install -y apt-transport-https ca-certificates gnupg curl

    # Add Google Cloud SDK repo
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
      > /etc/apt/sources.list.d/google-cloud-sdk.list

    # Install gcloud, kubectl, and GKE auth plugin
    apt-get update
    apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin kubectl
  EOT
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
