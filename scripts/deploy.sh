#!/bin/bash
set -e

ENVIRONMENT=$1

echo "=== Deploying to $ENVIRONMENT ==="

# Get current context
kubectl config current-context

# Apply manifests
kubectl apply -f manifests/$ENVIRONMENT/

# Check rollout status
kubectl rollout status deployment/app-deployment -n $ENVIRONMENT

echo "✓ Deployment completed!"
