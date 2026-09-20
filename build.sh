#!/bin/bash
set -e

# Configuration (Replace with your actual Docker Hub username)
DOCKER_USER="namodharani"
REPO_NAME="react-project"
TAG=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")

echo "🏗️ Building Docker Image..."
docker build -t $DOCKER_USER/$REPO_NAME:$TAG -t $DOCKER_USER/$REPO_NAME:latest .

echo "✅ Build Complete. Local Image Tags: $TAG, latest"
