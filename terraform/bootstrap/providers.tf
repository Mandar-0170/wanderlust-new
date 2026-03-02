terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Bootstrap uses LOCAL state — this is intentional.
  # This module creates the GCS bucket that all other modules use for remote state.
  # You cannot use a remote backend for the thing that creates the remote backend.
}

provider "google" {
  project = var.project_id
  region  = var.region
}
