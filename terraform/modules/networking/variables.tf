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

variable "client_name" {
  description = "Client name used in the resource naming convention (ResourceName-Client-Environment-Description)"
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

variable "pods_range_name" {
  description = "Name for the secondary IP range for GKE pods"
  type        = string
  default     = "pods"
}

variable "services_range_name" {
  description = "Name for the secondary IP range for GKE services"
  type        = string
  default     = "services"
}
