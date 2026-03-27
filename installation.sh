#!/bin/bash

# ----------------------------------------------------

# GKE Bastion Bootstrap Script

# Installs:

# - kubectl

# - gke-gcloud-auth-plugin

# Configures:

# - kubectl authentication

# - kubeconfig for a GKE cluster

# ----------------------------------------------------

set -e

CLUSTER_NAME="gke-rd-dev-cluster"
ZONE="us-central1-a"
PROJECT_ID="ferrous-linker-489911-f0"

echo "Starting Bastion Setup for GKE..."

echo "Updating system packages..."
sudo apt-get update -y

echo "Installing required dependencies..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

echo "Adding Google Cloud SDK repository..."

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/google-cloud.gpg

echo "deb [signed-by=/etc/apt/keyrings/google-cloud.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

echo "Updating repositories..."
sudo apt-get update -y

echo "Installing GKE authentication plugin..."
sudo apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin

echo "Installing kubectl..."

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "Enabling GKE auth plugin..."

export USE_GKE_GCLOUD_AUTH_PLUGIN=True
echo "export USE_GKE_GCLOUD_AUTH_PLUGIN=True" >> ~/.bashrc

echo "Setting project..."

gcloud config set project $PROJECT_ID

echo "Fetching cluster credentials..."

gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

echo "Validating cluster connectivity..."

kubectl get nodes

echo "Bastion setup completed successfully."

