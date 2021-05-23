#!/usr/bin/env bash
# shellcheck disable=SC2059
set -o errexit
set -o nounset
set -o pipefail

PKGER=$(command -v pkger || command -v ~/go/bin/pkger) || (echo "Please install go get github.com/markbates/pkger/cmd/pkger" ; exit 1)
NPM=$(command -v npm) || (echo "Please install NPM" ; exit 1)

INSTALL_TEMP_DIRECTORY="$(mktemp -d)"
PROJECT_SOURCE_DIR=$(git rev-parse --show-toplevel)

shutdown () {
  rm -rf "$PROJECT_SOURCE_DIR/admin"
  rm -rf "$INSTALL_TEMP_DIRECTORY"
}
trap shutdown INT TERM ABRT EXIT

echo "Cloning owncast admin into $INSTALL_TEMP_DIRECTORY..."
git clone https://github.com/owncast/owncast-admin 2> /dev/null
cd owncast-admin

$NPM install --silent --no-progress --no-audit --no-fund 

test -d .next && rm -rf .next

node_modules/.bin/next build 1>/dev/null
node_modules/.bin/next export -s 1>/dev/null

test -d "${INSTALL_TEMP_DIRECTORY}/owncast-admin/out"
test -d "${PROJECT_SOURCE_DIR}/admin" && rm -rf "${PROJECT_SOURCE_DIR}/admin"
mv "${INSTALL_TEMP_DIRECTORY}/owncast-admin/out" "${PROJECT_SOURCE_DIR}/admin"

cd ${PROJECT_SOURCE_DIR}
$PKGER

shutdown
