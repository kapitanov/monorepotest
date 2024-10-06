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

printf "\033[96mTesting module $MODULE_DIR\033[0m\n" >&2

SAFE_MODULE_NAME=$(echo "${MODULE_DIR#"$ROOT_DIR/"}" | sed 's/[^a-zA-Z0-9]/-/g')

ROOT_MODULE=$(go list -f '{{.Module.Path}}')
TESTABLE_MODULES=$(go list -test ./... | grep '\[' | cut -f1 -d' ' | sed "s|$ROOT_MODULE|.|")

TMP_OUT_DIR="$ARTIFACTS_DIR/tmp/$SAFE_MODULE_NAME"
mkdir -p "$ARTIFACTS_DIR/tests"
mkdir -p "$ARTIFACTS_DIR/coverage"
mkdir -p "$TMP_OUT_DIR"

JUNIT_FILE="$ARTIFACTS_DIR/tests/$SAFE_MODULE_NAME.xml"
COVERAGE_XML_FILE="$ARTIFACTS_DIR/coverage/$SAFE_MODULE_NAME.xml"
COVERAGE_PCT_FILE="$ARTIFACTS_DIR/coverage/$SAFE_MODULE_NAME.pct"

echo "gotestsum --format-hide-empty-pkg --junitfile $JUNIT_FILE -- \\" >&2
echo "  -coverprofile=$TMP_OUT_DIR/coverage.out.tmp \"$TESTABLE_MODULES\"" >&2
gotestsum --format-hide-empty-pkg --junitfile $JUNIT_FILE -- -coverprofile=$TMP_OUT_DIR/coverage.out.tmp "$TESTABLE_MODULES"

echo "gocover-cobertura < $TMP_OUT_DIR/coverage.out.tmp > $COVERAGE_XML_FILE" >&2
gocover-cobertura <$TMP_OUT_DIR/coverage.out.tmp >$COVERAGE_XML_FILE

echo "go tool cover -func=$TMP_OUT_DIR/coverage.out.tmp -o $TMP_OUT_DIR/coverage.txt.tmp" >&2
go tool cover -func=$TMP_OUT_DIR/coverage.out.tmp -o $TMP_OUT_DIR/coverage.txt.tmp
echo "cat $TMP_OUT_DIR/coverage.txt.tmp | grep 'total:' | awk '{printf \"%s\n\", \$3}' > $COVERAGE_PCT_FILE" >&2
cat $TMP_OUT_DIR/coverage.txt.tmp | grep 'total:' | awk '{printf "%s\n", $3}' >$COVERAGE_PCT_FILE
echo "Test coverage: $(cat $COVERAGE_PCT_FILE)" >&2
