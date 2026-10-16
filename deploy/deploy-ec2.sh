#!/usr/bin/env bash
set -Eeuo pipefail

BUILD_NUMBER="${1:?Jenkins build number is required}"
APP_DIR="/home/ubuntu/todo-assistant"
BACKEND_IMAGE="piyushkeshri22/todo-backend:${BUILD_NUMBER}"
FRONTEND_IMAGE="piyushkeshri22/todo-frontend:${BUILD_NUMBER}"

cd "$APP_DIR"

if [[ ! -f .env ]]; then
  echo "ERROR: $APP_DIR/.env is missing."
  exit 1
fi

# Pull both images before replacing running containers.
sudo docker pull "$BACKEND_IMAGE"
sudo docker pull "$FRONTEND_IMAGE"

# Ensure the shared application network exists.
sudo docker network inspect todo-network >/dev/null 2>&1 ||
  sudo docker network create todo-network

# Replace the old containers.
sudo docker rm -f todo-frontend todo-backend 2>/dev/null || true

# Start backend with its protected environment file.
sudo docker run -d \
  --name todo-backend \
  --restart unless-stopped \
  --network todo-network \
  --env-file "$APP_DIR/.env" \
  -p 127.0.0.1:8081:8080 \
  "$BACKEND_IMAGE"

# Wait for Spring Boot health to become successful.
healthy=false
for attempt in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:8081/actuator/health; then
    echo
    healthy=true
    break
  fi
  sleep 5
done

if [[ "$healthy" != true ]]; then
  echo "ERROR: Backend health check failed."
  sudo docker logs --tail 100 todo-backend
  exit 1
fi

# Start Nginx frontend and route /api requests to todo-backend.
sudo docker run -d \
  --name todo-frontend \
  --restart unless-stopped \
  --network todo-network \
  -p 80:8080 \
  "$FRONTEND_IMAGE"

# Verify the frontend responds over HTTP.
for attempt in $(seq 1 12); do
  if curl -fsS -o /dev/null http://127.0.0.1/; then
    echo "Frontend HTTP check passed."
    echo "Deployment of build ${BUILD_NUMBER} succeeded."
    exit 0
  fi
  sleep 5
done

echo "ERROR: Frontend HTTP check failed."
sudo docker logs --tail 100 todo-frontend
exit 1
