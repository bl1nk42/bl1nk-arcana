#!/usr/bin/env bash
# Deploy script for staging/production
# Usage: ./scripts/deploy.sh [staging|production]

set -euo pipefail

ENVIRONMENT="${1:-staging}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Deploying to $ENVIRONMENT ==="

case "$ENVIRONMENT" in
    staging)
        echo "Deploying to staging..."
        # Example: rsync to staging server
        # rsync -avz build/ user@staging-server:/var/www/blink-arcana/
        # Example: push docker image
        # docker push registry.example.com/blink-arcana:staging-$BUILDKITE_BUILD_NUMBER
        echo "Staging deploy placeholder"
        ;;
    production)
        echo "Deploying to production..."
        # Example: tag release
        # git tag -a "v$(cat VERSION)" -m "Release v$(cat VERSION)"
        # git push origin "v$(cat VERSION)"
        # Example: push docker image with release tag
        # docker push registry.example.com/blink-arcana:$(cat VERSION)
        echo "Production deploy placeholder"
        ;;
    *)
        echo "Unknown environment: $ENVIRONMENT"
        echo "Usage: $0 [staging|production]"
        exit 1
        ;;
esac

echo "=== Deploy complete ==="
