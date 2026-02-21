variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for all regional resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment label (e.g. dev, staging, prod)"
  type        = string
}

# -- Networking (uncomment when subnet ranges are available)
# variable "subnet_cidr" {
#   description = "CIDR range for the GKE subnet (node IPs)"
#   type        = string
# }
#
# variable "pods_cidr" {
#   description = "Secondary CIDR range for GKE pods"
#   type        = string
# }
#
# variable "services_cidr" {
#   description = "Secondary CIDR range for GKE services"
#   type        = string
# }
