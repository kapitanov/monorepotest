#!/usr/bin/env bash
set -eo pipefail

#####################################################################################################################################################
#
# Usage:
#
# go-vesrion.sh [<path-to-main-module-directory>]
#
# Examples:
#
#  cd services/date && ../../scripts/go-build.sh
#  ./scripts/go-build.sh services/date
#
#####################################################################################################################################################

MODULE_DIR="$1"
if [ -z "$MODULE_DIR" ]; then
    MODULE_DIR="$(pwd)"
fi

cd "$MODULE_DIR"
echo "MODULE_DIR: $MODULE_DIR" >&2

if [ -f ".semver.yaml" ]; then
    VERSION=$(semver get release)
else
    VERSION="1.0.0"
fi

VERSION_HASH="$(git rev-parse --short HEAD 2>/dev/null || echo "")"
if [ ! -z "$VERSION_HASH" ]; then
    VERSION="$VERSION+$VERSION_HASH"
fi
VERSION=$(echo "$VERSION" | sed 's/^v//g' )
echo "$VERSION"
