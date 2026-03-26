variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "project_number" {
  description = "The GCP project NUMBER (not ID). Find it in the GCP Console dashboard or via: gcloud projects describe <PROJECT_ID> --format='value(projectNumber)'"
  type        = string
}

variable "region" {
  description = "The GCP region for the state bucket"
  type        = string
}

variable "environment" {
  description = "Environment label (e.g. dev, staging, prod)"
  type        = string
}

variable "client_name" {
  description = "Client name used in the resource naming convention"
  type        = string
}

variable "github_org" {
  description = "GitHub organization or username that owns the repo (e.g. 'my-org' or 'my-username')"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (e.g. 'wanderlust')"
  type        = string
}
