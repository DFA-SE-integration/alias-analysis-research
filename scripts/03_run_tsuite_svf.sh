#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

export BC_DIR="$TSUIT_BC_14"
export BC_SUB_DIRS="$TSUIT_BC_SUP_DIRS"

export RES_DIR="$RESULTS_TSUITE_SVF_ANDER"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$WPA_CLI" -ander -print-aliases -stat=true "$bc_file" &> "$log_file"
}
source "scripts/run_tool.sh"

export RES_DIR="$RESULTS_TSUITE_SVF_FSPTA"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$WPA_CLI" -fspta -print-aliases -stat=true "$bc_file" &> "$log_file"
}
source "scripts/run_tool.sh"

export RES_DIR="$RESULTS_TSUITE_SVF_VFSPTA"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$WPA_CLI" -vfspta -print-aliases -stat=true "$bc_file" &> "$log_file"
}
source "scripts/run_tool.sh"

export RES_DIR="$RESULTS_TSUITE_SVF_CXT"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$DVF_CLI" -cxt -print-aliases -stat=true "$bc_file" &> "$log_file"
}
source "scripts/run_tool.sh"
