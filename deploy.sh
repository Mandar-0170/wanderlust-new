#!/bin/bash
# ============================================
# Wanderlust — VM Deploy Script
# ============================================
# Builds and runs all containers on a Docker-enabled VM.
# Auto-detects the VM's public IP — no manual editing needed.
#
# Usage:
#   bash deploy.sh          (GCP VM — uses metadata server)
#   bash deploy.sh <IP>     (any VM — pass IP manually)
# ============================================

set -e

# ─────────────────────────────────────────────
# 1. Detect Public IP
# ─────────────────────────────────────────────
if [ -n "$1" ]; then
  PUBLIC_IP="$1"
  echo "==> Using provided IP: $PUBLIC_IP"
else
  echo "==> Auto-detecting public IP (GCP metadata)..."
  PUBLIC_IP=$(curl -s --max-time 5 -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip 2>/dev/null)

  if [ -z "$PUBLIC_IP" ]; then
    echo "==> GCP metadata unavailable, trying ifconfig.me..."
    PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
  fi

  if [ -z "$PUBLIC_IP" ]; then
    echo "ERROR: Could not detect public IP."
    echo "Usage: bash deploy.sh <YOUR_VM_PUBLIC_IP>"
    exit 1
  fi

  echo "==> Detected IP: $PUBLIC_IP"
fi

# ─────────────────────────────────────────────
# 2. Update .env with the detected IP
# ─────────────────────────────────────────────
if [ ! -f .env ]; then
  echo "ERROR: .env file not found in current directory."
  echo "Make sure you run this script from the project root."
  exit 1
fi

echo "==> Updating .env with IP: $PUBLIC_IP"
sed -i "s|FRONTEND_URL=.*|FRONTEND_URL=http://$PUBLIC_IP|" .env
sed -i "s|BACKEND_URL=.*|BACKEND_URL=http://$PUBLIC_IP:8080|" .env
sed -i "s|VITE_API_PATH=.*|VITE_API_PATH=http://$PUBLIC_IP:8080|" .env

echo "==> .env updated:"
grep -E "FRONTEND_URL|BACKEND_URL|VITE_API_PATH" .env

# ─────────────────────────────────────────────
# 3. Stop and remove old containers (if any)
# ─────────────────────────────────────────────
echo ""
echo "==> Cleaning up old containers..."
docker rm -f mongodb redis backend frontend 2>/dev/null || true

# ─────────────────────────────────────────────
# 4. Create Docker network
# ─────────────────────────────────────────────
echo "==> Creating network: wanderlust-net"
docker network create wanderlust-net 2>/dev/null || true

# ─────────────────────────────────────────────
# 5. Start MongoDB
# ─────────────────────────────────────────────
echo ""
echo "==> Starting MongoDB..."
docker run -d \
  --name mongodb \
  --network wanderlust-net \
  -p 27017:27017 \
  -v mongodb_data:/data/db \
  --restart unless-stopped \
  mongo:7

echo "==> Waiting for MongoDB to be ready..."
sleep 5

# ─────────────────────────────────────────────
# 6. Start Redis
# ─────────────────────────────────────────────
echo "==> Starting Redis..."
docker run -d \
  --name redis \
  --network wanderlust-net \
  -p 6379:6379 \
  --restart unless-stopped \
  redis:7-alpine

echo "==> Waiting for Redis to be ready..."
sleep 3

# ─────────────────────────────────────────────
# 7. Build and Start Backend
# ─────────────────────────────────────────────
echo ""
echo "==> Building backend image..."
docker build -t wanderlust-backend ./backend

echo "==> Starting backend..."
docker run -d \
  --name backend \
  --network wanderlust-net \
  -p 8080:8080 \
  --env-file .env \
  --restart unless-stopped \
  wanderlust-backend

# ─────────────────────────────────────────────
# 8. Build and Start Frontend
# ─────────────────────────────────────────────
echo ""
echo "==> Building frontend image (VITE_API_PATH=http://$PUBLIC_IP:8080)..."
docker build -t wanderlust-frontend \
  --build-arg VITE_API_PATH="http://$PUBLIC_IP:8080" \
  ./frontend

echo "==> Starting frontend..."
docker run -d \
  --name frontend \
  --network wanderlust-net \
  -p 80:80 \
  --restart unless-stopped \
  wanderlust-frontend

# ─────────────────────────────────────────────
# 9. Summary
# ─────────────────────────────────────────────
echo ""
echo "============================================"
echo "  Wanderlust is running!"
echo "============================================"
echo "  Frontend:  http://$PUBLIC_IP"
echo "  Backend:   http://$PUBLIC_IP:8080"
echo "  MongoDB:   $PUBLIC_IP:27017"
echo "  Redis:     $PUBLIC_IP:6379"
echo "============================================"
echo ""
echo "  Useful commands:"
echo "    docker ps                    # check status"
echo "    docker logs -f backend       # backend logs"
echo "    docker logs -f frontend      # frontend logs"
echo "    docker rm -f mongodb redis backend frontend   # stop all"
echo "============================================"
