#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

export BC_DIR="$TSUIT_BC_14"
export RES_DIR="$RESULTS_TSUITE_SVF"

run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  
  # Map directory names to SVF analysis types
  # Logic:
  # - If directory contains "path" -> use vfspta (path-sensitive)
  # - If directory contains "context" -> use dvf -cxt (context-sensitive)
  # - If directory contains "flow" (but not path/context) -> use fspta (flow-sensitive)
  # - Otherwise -> use ander (flow-insensitive)
  
  case "$test_dir" in
    # New directory name patterns
    *path*)
      # Path-sensitive: use versioned flow-sensitive analysis
      "$WPA_CLI" -vfspta -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
    *context*)
      # Context-sensitive: use DVF with context-sensitive analysis
      "$DVF_CLI" -cxt -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
    *flow*)
      # Flow-sensitive: use flow-sensitive pointer analysis
      "$WPA_CLI" -fspta -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
    *)
      # Default: flow-insensitive Andersen analysis
      "$WPA_CLI" -ander -print-aliases -stat=true "$bc_file" &> "$log_file"
      ;;
  esac
}

source "scripts/run_tool.sh"
