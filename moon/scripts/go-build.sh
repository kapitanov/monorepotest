#!/usr/bin/env bash
set -eo pipefail

#####################################################################################################################################################
#
# Usage:
#
# go-build.sh [<path-to-main-module-directory>]
#
# Examples:
#
#  cd services/date && ../../scripts/go-build.sh
#  ./scripts/go-build.sh services/date
#
#####################################################################################################################################################

ROOT_DIR=$(echo "${BASH_SOURCE[0]}" | xargs dirname | xargs dirname | xargs realpath)
ARTIFACTS_DIR="$ROOT_DIR/artifacts"

MODULE_DIR="$1"
if [ -z "$MODULE_DIR" ]; then
    MODULE_DIR="$(pwd)"
fi

[ ! -f "$MODULE_DIR/go.mod" ] && (echo "$MODULE_DIR is not a module" && exit 1) || true
cd "$MODULE_DIR"

ROOT_MODULE_NAME=$(go list -f '{{.Name}}')
SAFE_MODULE_NAME=$(echo "${MODULE_DIR#"$ROOT_DIR/"}" | sed 's/[^a-zA-Z0-9]/-/g')

if [ "$ROOT_MODULE_NAME" == "main" ]; then
    VERSION=$(cat $ROOT_DIR/artifacts/version/$SAFE_MODULE_NAME)
    mkdir -p $ROOT_DIR/bin
    echo "go build -ldflags \"-X main.Version=$VERSION\" -o $ROOT_DIR/artifacts/bin/$SAFE_MODULE_NAME" >&2
    go build -ldflags "-X main.Version=$VERSION" -o $ROOT_DIR/artifacts/bin/$SAFE_MODULE_NAME
else
    go build
fi
