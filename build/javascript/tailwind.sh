#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

cd $(dirname "${BASH_SOURCE[0]}")
export NODE_ENV=production
npm install --silent --no-progress --no-audit --no-optional --no-fund 
node_modules/.bin/tailwind build -c tailwind.config.js -o tailwind.css &>/dev/null
node_modules/.bin/postcss tailwind.css -o tailwind.min.css 2>/dev/null
