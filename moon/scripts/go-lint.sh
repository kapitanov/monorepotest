#!/usr/bin/env bash
set -eo pipefail

#####################################################################################################################################################
#
# Usage:
#
# go-test.sh [<path-to-module-directory>]
#
# Examples:
#
#  cd libs/contracts && ../../scripts/go-test.sh
#  ./scripts/go-test.sh libs/contracts
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

printf "\033[96mLinting module $MODULE_DIR\033[0m\n" >&2

SAFE_MODULE_NAME=$(echo "${MODULE_DIR#"$ROOT_DIR/"}" | sed 's/[^a-zA-Z0-9]/-/g')

mkdir -p "$ARTIFACTS_DIR/lint"

LINTER_REPORT_FILE="$ARTIFACTS_DIR/lint/$SAFE_MODULE_NAME.json"

echo "golangci-lint run -v -c $ROOT_DIR/.golangci.yml --out-format code-climate --timeout 10m" >&2
golangci-lint run -v -c $ROOT_DIR/.golangci.yml --out-format code-climate --timeout 10m | tee "$LINTER_REPORT_FILE"
