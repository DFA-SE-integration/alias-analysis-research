#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

export BC_DIR="${BC_DIR:-$TSUIT_BC_20}"

# cs
export RES_DIR="$RESULTS_TSUITE/Sea-DSA-llvm20/cs"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$SDSA_LLVM20_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa=cs "$bc_file" &> "$log_file";
}
source "scripts/run_tool.sh"

# butd-cs
export RES_DIR="$RESULTS_TSUITE/Sea-DSA-llvm20/butd-cs"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$SDSA_LLVM20_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa=butd-cs "$bc_file" &> "$log_file";
}
source "scripts/run_tool.sh"

# bu
export RES_DIR="$RESULTS_TSUITE/Sea-DSA-llvm20/bu"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$SDSA_LLVM20_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa=bu "$bc_file" &> "$log_file";
}
source "scripts/run_tool.sh"

# ci
export RES_DIR="$RESULTS_TSUITE/Sea-DSA-llvm20/ci"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$SDSA_LLVM20_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa=ci "$bc_file" &> "$log_file";
}
source "scripts/run_tool.sh"

# flat
export RES_DIR="$RESULTS_TSUITE/Sea-DSA-llvm20/flat"
run_one_file() {
  local bc_file="$1" log_file="$2" test_dir="$3"
  "$SDSA_LLVM20_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa=flat "$bc_file" &> "$log_file";
}
source "scripts/run_tool.sh"
