#!/bin/bash
set -e

# Configuration (Replace with your actual Docker Hub username)
export DOCKER_USER="namodharani"
export TAG=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")

echo "🚀 Deploying application using Docker Compose..."
docker compose down --remove-orphans
docker compose up -d

echo "🌐 Deployed! Application is running on port 80."
