#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <module.bc> <out_dir>"
  exit 1
fi

BC="$(realpath "$1")"
OUT="$(realpath "$2")"
mkdir -p "$OUT"

if [[ -z "${WPA_CLI:-}" || ! -x "${WPA_CLI}" ]]; then
  echo "ERROR: WPA_CLI must be set and point to an executable wpa. Source scripts/env.sh after building SVF."
  exit 1
fi

run_one () {
  local aa="$1"
  local json="$OUT/pta.${aa}.json"

  "$WPA_CLI" -print-all-pts -stat -$aa "$BC" &> "$json"

  echo "OK: svf $aa -> $json"
}

run_one nander
run_one sander
run_one ander
run_one sfrander
run_one fspta
run_one vfspta
run_one type
