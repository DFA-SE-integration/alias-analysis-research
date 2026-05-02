#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

export BC_DIR="${BC_DIR:-$TSUIT_BC_14}"

# cs
export RES_DIR="$RESULTS_TSUITE/Sea-DSA-llvm14/cs"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$SDSA_LLVM14_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa=cs "$bc_file" &> "$log_file";
}
source "scripts/run_tool.sh"

# butd-cs
export RES_DIR="$RESULTS_TSUITE/Sea-DSA-llvm14/butd-cs"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$SDSA_LLVM14_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa=butd-cs "$bc_file" &> "$log_file";
}
source "scripts/run_tool.sh"

# bu
export RES_DIR="$RESULTS_TSUITE/Sea-DSA-llvm14/bu"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$SDSA_LLVM14_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa=bu "$bc_file" &> "$log_file";
}
source "scripts/run_tool.sh"

# ci
export RES_DIR="$RESULTS_TSUITE/Sea-DSA-llvm14/ci"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$SDSA_LLVM14_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa=ci "$bc_file" &> "$log_file";
}
source "scripts/run_tool.sh"

# flat
export RES_DIR="$RESULTS_TSUITE/Sea-DSA-llvm14/flat"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$SDSA_LLVM14_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa=flat "$bc_file" &> "$log_file";
}
source "scripts/run_tool.sh"
