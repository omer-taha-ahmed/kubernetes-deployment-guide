#!/bin/bash
set -e

ENVIRONMENT=$1

echo "=== Rolling back $ENVIRONMENT ==="

kubectl rollout undo deployment/app-deployment -n $ENVIRONMENT

echo "✓ Rollback completed!"
