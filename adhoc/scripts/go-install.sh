#!/usr/bin/env bash
set -eo pipefail

#####################################################################################################################################################
#
# Usage:
#
#   go-install.sh <install-url-with-version>
#
# Examples:
#
#   go-install.sh gotest.tools/gotestsum@v1.12.0
#
#####################################################################################################################################################
INSTALL_URL="$1"

[ -z "$INSTALL_URL" ] && (echo "Missing <install-url>" >&2 && exit 1) || true

TOOL_NAME=$(echo "$INSTALL_URL" | cut -d '@' -f 1 | rev | cut -d '/' -f 1 | rev)
TOOL_VERSION=$(echo "$INSTALL_URL" | cut -d '@' -f 2)

function do_install() {
    printf "go install $INSTALL_URL\n" >&2
    go install "$INSTALL_URL"
}

LOCATION=$(which "$TOOL_NAME")
if [ -z "$LOCATION" ]; then
    printf "\033[93m$TOOL_NAME: not installed\033[0m\n" >&2
    do_install
    exit
fi

INSTALLED_VERSION=$(go version -m $LOCATION | grep -E '\s+mod\s+' | grep -oE 'v[0-9\.]+')
if [ "$INSTALLED_VERSION" != "$TOOL_VERSION" ]; then
    printf "\033[93m$TOOL_NAME: want $TOOL_VERSION but got $INSTALLED_VERSION\033[0m\n" >&2
    do_install
    exit
fi
