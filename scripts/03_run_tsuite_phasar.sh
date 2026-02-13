#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

export BC_DIR="$TSUIT_BC_16"

export RES_DIR="$RESULTS_TSUITE_PHASAR_ANDERS"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$PHASAR_CLI" -m "$bc_file" -D ifds-solvertest --entry-points=__ALL__ \
    --alias-analysis=cflanders --emit-pta-as-json --emit-stats &> "$log_file"
}
source "scripts/run_tool.sh"

export RES_DIR="$RESULTS_TSUITE_PHASAR_STEENS"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$PHASAR_CLI" -m "$bc_file" -D ifds-solvertest --entry-points=__ALL__ \
    --alias-analysis=cflsteens --emit-pta-as-json --emit-stats &> "$log_file"
}
source "scripts/run_tool.sh"
