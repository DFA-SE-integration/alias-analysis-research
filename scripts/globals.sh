#!/usr/bin/env bash
set -euo pipefail

# Project
export ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Phasar
export PHASAR_ROOT="$ROOT/phasar"
export PHASAR_CLI="$PHASAR_ROOT/build/tools/phasar-cli/phasar-cli"

# Sea-Dsa
export SDSA_ROOT="$ROOT/sea-dsa"
export SDSA_CLI="$SDSA_ROOT/build/bin/seadsa"

# SVF
export SVF_ROOT="$ROOT/SVF"
export WPA_CLI="$ROOT/SVF/build/bin/wpa"
export DVF_CLI="$ROOT/SVF/build/bin/dvf"
# SVF: z3
Z3_BIN="$ROOT/z3-4.15.4-x64-glibc-2.39/bin"
export PATH=$Z3_BIN:$PATH

# Tests
export TEST_ROOT="$ROOT/tests"

# PointerBench
export PTRBENCH_ROOT="$TEST_ROOT/PointerBench"
export PTRBENCH_SRC="$PTRBENCH_ROOT/src"
export PTRBENCH_BC_14="$ROOT/tests/PointerBench/build/bc/llvm-14"
export PTRBENCH_BC_16="$ROOT/tests/PointerBench/build/bc/llvm-16"

# Test-Suite
export TSUITE_ROOT="$TEST_ROOT/Test-Suite"
export TSUITE_SRC="$TEST_ROOT/Test-Suite/src"
export TSUIT_BC_14="$ROOT/tests/Test-Suite/build/bc/llvm-14"
export TSUIT_BC_16="$ROOT/tests/Test-Suite/build/bc/llvm-16"

# TODO
# complex_tests
# mem_leak
# double_free
export TSUIT_BC_SUP_DIRS="
  basic_c_tests
  fs_tests
  cs_tests
  path_tests
  non_annotated_tests
"

