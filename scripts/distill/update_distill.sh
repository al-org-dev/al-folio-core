#!/usr/bin/env bash
set -euo pipefail

# Rebuild vendored Distill runtime assets from a pinned npm source.
# Usage:
#   scripts/distill/update_distill.sh [distill-template-version]
#
# Example:
#   scripts/distill/update_distill.sh 1.1.0

VERSION="${1:-1.1.0}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

pushd "${TMP_DIR}" >/dev/null
npm init -y >/dev/null 2>&1
npm install --silent "distill-template@${VERSION}"
popd >/dev/null

DISTILL_DIST="${TMP_DIR}/node_modules/distill-template/dist"
OUT_DIR="${ROOT}/vendor/distillpub"
mkdir -p "${OUT_DIR}"

cp "${DISTILL_DIST}/template.js" "${OUT_DIR}/template.v2.js"
cp "${DISTILL_DIST}/transforms.js" "${OUT_DIR}/transforms.v2.js"

# Enforce self-contained runtime (no remote template loader).
perl -0pi -e "s#https://distill\\.pub/template\\.v2\\.js#/assets/js/distillpub/template.v2.js#g" "${OUT_DIR}/transforms.v2.js"

echo "Updated Distill assets in ${OUT_DIR} from distill-template@${VERSION}"
