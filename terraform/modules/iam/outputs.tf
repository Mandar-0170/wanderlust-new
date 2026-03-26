output "gke_service_account_email" {
  value = google_service_account.gke_nodes.email
}

output "bastion_service_account_email" {
  value = google_service_account.bastion.email
}
