variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "client_name" {
  description = "Client name used in the resource naming convention (ResourceName-Client-Environment-Description)"
  type        = string
}

variable "region" {
  description = "The GCP region for all regional resources"
  type        = string
}

variable "environment" {
  description = "Environment label (e.g. dev, staging, prod)"
  type        = string
}

# -- Bastion
variable "zone" {
  description = "GCP zone for the bastion VM"
  type        = string
}

variable "bastion_machine_type" {
  description = "Machine type for the bastion VM"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDRs allowed to SSH into the bastion"
  type        = list(string)
}

# -- Networking
variable "subnet_cidr" {
  description = "CIDR range for the GKE subnet (node IPs)"
  type        = string
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods"
  type        = string
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services"
  type        = string
}

# -- GKE
variable "gke_node_count" {
  description = "Number of nodes in the GKE node pool"
  type        = number
}

variable "gke_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
}

variable "gke_disk_size_gb" {
  description = "Disk size in GB for each GKE node"
  type        = number
}
