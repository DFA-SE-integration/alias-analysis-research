#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <module.bc> <out_dir>"
  exit 1
fi

BC="$(realpath "$1")"
OUT="$(realpath "$2")"
mkdir -p "$OUT"

if [[ -z "${PHASAR_CLI:-}" || ! -x "${PHASAR_CLI}" ]]; then
  echo "ERROR: PHASAR_CLI must be set and point to an executable phasar-cli. Source scripts/env.sh after building phasar."
  exit 1
fi

run_one () {
  local name="$1"
  local aa="$2"
  local json="$OUT/pta.${name}.json"

  "$PHASAR_CLI" \
    -m "$BC" \
    -D ifds-solvertest \
    --entry-points=__ALL__ \
    --alias-analysis="$aa" \
    --emit-pta-as-json \
    --emit-stats &> "$json"

  echo "OK: phasar $name -> $json"
}

run_one anders cflanders
run_one steens cflsteens
