variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "environment" {
  description = "Environment label (e.g. dev, staging, prod)"
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR for the GKE - subnet where nodes live"
  type        = string
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE - pods ip's assigned to pods"
  type        = string
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services - virtual IPs for Kubernetes Services"
  type        = string
}
