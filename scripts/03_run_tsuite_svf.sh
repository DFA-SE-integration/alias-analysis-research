#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

export BC_DIR="$TSUIT_BC_14"
export RES_DIR="$RESULTS_TSUITE_SVF"

run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  
  case "$test_dir" in
    basic_c_tests)
      "$WPA_CLI" -ander -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
    fs_tests)
      "$WPA_CLI" -fspta -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
    cs_tests)
      "$DVF_CLI" -cxt -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
    path_tests)
      # Path-sensitive tests: use versioned flow-sensitive (-vfspta) for better precision.
      # -fspta is flow-sensitive but merges at merge points and often fails NOALIAS.
      "$WPA_CLI" -vfspta -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
    *)
      echo "$test_dir not supported! Support alias info" >&2
      return 1
      ;;
  esac
}

source "scripts/run_tool.sh"
