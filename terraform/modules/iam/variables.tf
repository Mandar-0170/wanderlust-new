variable "project_id" {
  description = "The GCP project ID"
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
