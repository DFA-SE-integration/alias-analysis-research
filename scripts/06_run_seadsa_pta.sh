#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <module.bc> <out_dir>"
  exit 1
fi

BC="$(realpath "$1")"
OUT="$(realpath "$2")"
mkdir -p "$OUT"

if [[ -z "${SDSA_CLI:-}" || ! -x "${SDSA_CLI}" ]]; then
  echo "ERROR: SDSA_CLI must be set and point to an executable seadsa. Source scripts/env.sh after building sea-dsa."
  exit 1
fi

run_one () {
  local aa="$1"
  local log="$OUT/pta.${aa}.log"

  "$SDSA_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa="$aa" "$BC" &> "$log"

  echo "OK: seadsa $aa -> $log"
}

run_one cs
run_one butd-cs
run_one bu
run_one ci
run_one flat
