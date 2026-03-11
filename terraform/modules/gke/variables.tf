variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone for the zonal cluster"
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

variable "vpc_name" {
  description = "VPC network name from networking module"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name from networking module"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary range for pods"
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary range for services"
  type        = string
}

variable "service_account_email" {
  description = "Service account email for GKE nodes from IAM module"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
}

variable "machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
}

variable "disk_size_gb" {
  description = "Disk size in GB for each GKE node"
  type        = number
}

variable "master_cidr" {
  description = "CIDR block for the GKE master (private cluster control plane)"
  type        = string
}

variable "disk_type" {
  description = "Disk type for GKE nodes (e.g. pd-standard, pd-ssd)"
  type        = string
}
