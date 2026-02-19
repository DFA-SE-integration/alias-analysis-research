#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

export BC_DIR="$PTRBENCH_BC_14"
export BC_SUB_DIRS="$PTRBENCH_BC_SUP_DIRS"
export RES_DIR="$RESULTS_PTRBENCH_SVF"

run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  case "$test_dir" in
    *path*)
      "$WPA_CLI" -vfspta -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
    *context*)
      "$DVF_CLI" -cxt -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
    *flow*)
      "$WPA_CLI" -fspta -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
    *)
      "$WPA_CLI" -ander -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
  esac
}

source "scripts/run_tool.sh"
