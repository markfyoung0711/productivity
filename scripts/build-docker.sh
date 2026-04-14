#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE_NAME="${1:-productivity-dev}"

echo "Building Docker image '${IMAGE_NAME}' ..."
docker build -f "${REPO_ROOT}/.devcontainer/Dockerfile" -t "${IMAGE_NAME}" "${REPO_ROOT}"
echo "Done. Run with: docker run -it --rm -v \$(pwd):/workspace ${IMAGE_NAME} bash"
