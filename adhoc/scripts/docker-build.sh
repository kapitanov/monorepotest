#!/usr/bin/env bash
set -eo pipefail

#####################################################################################################################################################
#
# Usage:
#
# docker-build.sh <service>
#
# Examples:
#
#  ./scripts/docker-build.sh services-date
#
#####################################################################################################################################################

ROOT_DIR=$(echo "${BASH_SOURCE[0]}" | xargs dirname | xargs dirname | xargs realpath)

SERVICE_NAME="$1"
[[ -z "$SERVICE_NAME" ]] && (echo "Missing service name"; exit 1) || true

VERSION=$(cat "$ROOT_DIR/artifacts/version/$SERVICE_NAME")
DOCKER_IMAGE="$([ -n "$DOCKER_REGISTRY" ] && echo "$DOCKER_REGISTRY/" || echo "")$SERVICE_NAME:$(echo "$VERSION" | sed 's/\+/-/g')"

echo "docker build  --file \"$ROOT_DIR/dockerfiles/$SERVICE_NAME/Dockerfile\" --tag \"$DOCKER_IMAGE\" --build-arg \"VERSION=$VERSION\" \"$ROOT_DIR\"" >&2
docker build --file "$ROOT_DIR/dockerfiles/$SERVICE_NAME/Dockerfile" --tag "$DOCKER_IMAGE" --build-arg "VERSION=$VERSION" "$ROOT_DIR"

mkdir -p "$ROOT_DIR/artifacts/images"

echo "docker save -o \"$ROOT_DIR/artifacts/images/$SERVICE_NAME.tar\" \"$DOCKER_IMAGE\"" >&2
docker save -o "$ROOT_DIR/artifacts/images/$SERVICE_NAME.tar" "$DOCKER_IMAGE"

echo "echo \"$DOCKER_IMAGE\" >\"$ROOT_DIR/artifacts/images/$SERVICE_NAME.txt\"" >&2
echo "$DOCKER_IMAGE" >"$ROOT_DIR/artifacts/images/$SERVICE_NAME.txt"
