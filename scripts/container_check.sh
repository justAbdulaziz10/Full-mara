#!/usr/bin/env bash
set -euo pipefail
IMAGE="${1:-ghcr.io/owner/repo/mara-backend:latest}"

echo "🔍 Trivy Image scan..."
trivy image --severity HIGH,CRITICAL --exit-code 0 "$IMAGE"

echo "🧭 Dockle CIS checks..."
dockle --exit-code 0 "$IMAGE"

echo "✅ Container checks done."
