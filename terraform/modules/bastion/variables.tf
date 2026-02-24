variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone for the bastion VM (e.g. us-central1-a)"
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

variable "network" {
  description = "VPC network ID to place the bastion in"
  type        = string
}

variable "subnet" {
  description = "Subnet name to place the bastion in"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the bastion VM"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDRs allowed to SSH into the bastion"
  type        = list(string)
}
