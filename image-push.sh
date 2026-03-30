#!/bin/bash

PROJECT_ID="ferrous-linker-489911-f0"
REGION="us-central1"
REPO="registry-rd-dev-docker"

echo "Installing Docker..."

# Install Docker
sudo apt-get update -y
sudo apt-get install -y docker.io

echo "Starting Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Adding user to docker group..."
sudo usermod -aG docker $USER


gcloud projects add-iam-policy-binding ferrous-linker-489911-f0 \
  --member="user:radnampandit21@gmail.com" \
  --role="roles/artifactregistry.writer"

echo "Authenticating Docker with GCP..."
gcloud auth configure-docker $REGION-docker.pkg.dev -q

gcloud artifacts repositories add-iam-policy-binding registry-rd-dev-docker \
  --location=us-central1 \
  --member="serviceAccount:sa-rd-dev-bastion@ferrous-linker-489911-f0.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"

echo "Pushing Prometheus..."
sudo docker pull quay.io/prometheus/prometheus:v3.10.0
sudo docker tag quay.io/prometheus/prometheus:v3.10.0 \
$REGION-docker.pkg.dev/$PROJECT_ID/$REPO/prometheus:v3.10.0
sudo docker push \
$REGION-docker.pkg.dev/$PROJECT_ID/$REPO/prometheus:v3.10.0

echo "Pushing Grafana..."
sudo docker pull grafana/grafana:12.4.0
sudo docker tag grafana/grafana:12.4.0 \
$REGION-docker.pkg.dev/$PROJECT_ID/$REPO/grafana:12.4.0
sudo docker push \
$REGION-docker.pkg.dev/$PROJECT_ID/$REPO/grafana:12.4.0

echo "Done pushing images"

kubectl create namespace monitoring
