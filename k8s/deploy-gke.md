# Wanderlust — GKE Deployment Guide

Step-by-step guide to deploy the Wanderlust app on the GKE cluster.

---

## Prerequisites

- `gcloud` CLI installed and authenticated
- `kubectl` installed
- `docker` installed (for building and pushing images)
- GKE cluster is running (`gke-rd-dev-cluster` in `us-central1-a`)

---

## Phase 1 — Connect to GKE Cluster

```bash
# Set project
gcloud config set project playground-488307

# Get cluster credentials (adds to your kubeconfig)
gcloud container clusters get-credentials gke-rd-dev-cluster \
  --zone us-central1-a \
  --project playground-488307

# Verify connection
kubectl get nodes
```

---

## Phase 2 — Build & Push Docker Images

```bash
# Authenticate Docker with Artifact Registry
gcloud auth configure-docker us-central1-docker.pkg.dev

# ── Backend ──
docker build \
  -t us-central1-docker.pkg.dev/playground-488307/registry-rd-dev-docker/wanderlust-backend:v1 \
  ./backend

docker push us-central1-docker.pkg.dev/playground-488307/registry-rd-dev-docker/wanderlust-backend:v1

# ── Frontend ──
# VITE_API_PATH="" makes the browser send API requests to the same origin.
# The Ingress routes /api/* to the backend automatically.
docker build \
  --build-arg VITE_API_PATH="" \
  -t us-central1-docker.pkg.dev/playground-488307/registry-rd-dev-docker/wanderlust-frontend:v1 \
  ./frontend

docker push us-central1-docker.pkg.dev/playground-488307/registry-rd-dev-docker/wanderlust-frontend:v1
```

---

## Phase 3 — Deploy Kubernetes Resources

Apply manifests in dependency order:

```bash
# 1. Namespace (must exist before everything else)
kubectl apply -f k8s/namespace.yaml

# 2. Config and Secrets (must exist before backend pods start)
kubectl apply -f k8s/backend/configmap.yaml
kubectl apply -f k8s/backend/secret.yaml

# 3. Database layer (backend depends on these)
kubectl apply -f k8s/backend/mongodb.yaml
kubectl apply -f k8s/backend/redis.yaml

# Wait for MongoDB and Redis to be ready
kubectl wait --for=condition=ready pod -l component=mongodb -n wanderlust --timeout=120s
kubectl wait --for=condition=ready pod -l component=redis -n wanderlust --timeout=60s

# 4. Backend
kubectl apply -f k8s/backend/deployment.yaml

# 5. Frontend
kubectl apply -f k8s/frontend/deployment.yaml

# 6. Ingress (exposes everything to the internet)
kubectl apply -f k8s/ingress.yaml
```

---

## Phase 4 — Get Ingress IP & Update URLs

```bash
# Wait for Ingress to get an external IP (may take 2–5 minutes)
kubectl get ingress wanderlust-ingress -n wanderlust --watch
```

Once you see an `ADDRESS` (e.g. `34.x.x.x`):

```bash
# Update ConfigMap with the real Ingress IP
kubectl edit configmap wanderlust-config -n wanderlust
# Change:
#   FRONTEND_URL: "http://34.x.x.x"
#   BACKEND_URL:  "http://34.x.x.x"

# Restart backend pods to pick up the new ConfigMap values
kubectl rollout restart deployment backend -n wanderlust
```

> **Google OAuth**: Update the **Authorized redirect URIs** in the
> [Google Cloud Console → APIs & Services → Credentials](https://console.cloud.google.com/apis/credentials)
> to include: `http://<INGRESS_IP>/api/auth/google/callback`

---

## Phase 5 — Verify

```bash
# Check all resources
kubectl get all -n wanderlust

# Check pod logs
kubectl logs -f deployment/backend -n wanderlust
kubectl logs -f deployment/frontend -n wanderlust
```

Then open in browser:
- **App**: `http://<INGRESS_IP>/`
- **Backend root**: `http://<INGRESS_IP>/api/posts/latest`

---

## Useful Commands

```bash
# Scale deployments
kubectl scale deployment backend --replicas=3 -n wanderlust

# Update image (after pushing a new tag)
kubectl set image deployment/backend backend=us-central1-docker.pkg.dev/playground-488307/registry-rd-dev-docker/wanderlust-backend:v2 -n wanderlust

# Delete everything
kubectl delete namespace wanderlust
```
