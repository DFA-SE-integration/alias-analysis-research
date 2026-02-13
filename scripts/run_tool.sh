#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

count=0
succ_count=0

# Must be defined:
# BC_DIR - bytecode dir
if [ ! -n "${BC_DIR}" ]; then
  echo "BC_DIR not defined!" >&2
  exit 1
fi
# RES_DIR - results dir
if [ ! -n "${RES_DIR}" ]; then
  echo "RES_DIR not defined!" >&2
  exit 1
fi
# run_one_file(bc_file, log_file, test_dir) - function to run tool on one .bc file; must be defined by caller
# test_dir is the subdirectory name (e.g., "basic_c_tests", "fs_tests", etc.)
if ! declare -f run_one_file >/dev/null 2>&1; then
  echo "run_one_file(bc_file, log_file, test_dir) is not defined. Define it before sourcing run_tool.sh." >&2
  exit 1
fi

for dir in $TSUIT_BC_SUP_DIRS; do
    target_dir="$BC_DIR/$dir"
    results_dir="$RES_DIR/$dir"

    # Skip if directory doesn't exist
    [[ ! -d "$target_dir" ]] && continue
    mkdir -p "$results_dir"

    # Process each .bc file in the directory
    for f in "$target_dir"/*.bc; do
      # Skip if glob didn't match any files
      [[ ! -f "$f" ]] && continue
    
      # Get basename without extension for output file
      basename_f=$(basename "$f")
      stem="${basename_f%.bc}"
      output_file="$results_dir/$stem.log"

      if run_one_file "$f" "$output_file" "$dir"; then
        (( succ_count++ )) || true
      fi
      (( count++ )) || true
    done
done

echo "OK: Successfully processed $succ_count/$count .bc file(s). Results under $RES_DIR"
