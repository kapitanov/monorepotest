#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(echo "${BASH_SOURCE[0]}" | xargs dirname | xargs realpath)"
"$SCRIPT_DIR/.adhoc/adhoc.sh" $*
