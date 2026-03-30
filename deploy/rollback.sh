#!/bin/bash
set -euo pipefail

# Rollback a service to a specific image tag (git SHA).
# Usage: ./rollback.sh <service> <tag>
# Example: ./rollback.sh api abc123def
#          ./rollback.sh frontend abc123def

SERVICE="${1:?Usage: ./rollback.sh <service> <tag>}"
TAG="${2:?Usage: ./rollback.sh <service> <tag>}"

case "$SERVICE" in
  api)      TAG_VAR="API_TAG" ;;
  frontend) TAG_VAR="FE_TAG" ;;
  *)        echo "Unknown service: $SERVICE (use 'api' or 'frontend')" && exit 1 ;;
esac

cd ~/app

echo "Rolling back $SERVICE to tag: $TAG"
export "$TAG_VAR=$TAG"
docker compose pull "$SERVICE" &&
docker compose up -d "$SERVICE"
echo "Done. Verify with: docker compose ps"
