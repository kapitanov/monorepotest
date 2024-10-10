#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(echo "${BASH_SOURCE[0]}" | xargs dirname | xargs realpath)"
python3 "$SCRIPT_DIR/adhoc.py" $*