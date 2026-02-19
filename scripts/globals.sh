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

# Results
export RESULTS_ROOT="$ROOT/results"

# Tests
export RESULTS_TSUITE="$RESULTS_ROOT/Test-Suite"
export RESULTS_PTRBENCH="$RESULTS_ROOT/PointerBench"

# PointerBench result dirs (mirror Test-Suite layout)
export RESULTS_PTRBENCH_PHASAR_ANDERS="$RESULTS_PTRBENCH/Phasar/cflanders"
export RESULTS_PTRBENCH_PHASAR_STEENS="$RESULTS_PTRBENCH/Phasar/cflsteens"
export RESULTS_PTRBENCH_SDSA_CS="$RESULTS_PTRBENCH/Sea-DSA/cs"
export RESULTS_PTRBENCH_SDSA_BUTD_CS="$RESULTS_PTRBENCH/Sea-DSA/butd-cs"
export RESULTS_PTRBENCH_SDSA_BU="$RESULTS_PTRBENCH/Sea-DSA/bu"
export RESULTS_PTRBENCH_SDSA_CI="$RESULTS_PTRBENCH/Sea-DSA/ci"
export RESULTS_PTRBENCH_SDSA_FLAT="$RESULTS_PTRBENCH/Sea-DSA/flat"
export RESULTS_PTRBENCH_SVF="$RESULTS_PTRBENCH/SVF"

# PointerBench C test subdirs (sensitivity categories)
export PTRBENCH_BC_SUP_DIRS="
  context
  context_sens
  field_sens
  flow
  flow_sens
  index_sens
  path+flow
"

# Tools
export RESULTS_TSUITE_PHASAR_ANDERS="$RESULTS_TSUITE/Phasar/cflanders"
export RESULTS_TSUITE_PHASAR_STEENS="$RESULTS_TSUITE/Phasar/cflsteens"
export RESULTS_TSUITE_SDSA_CS="$RESULTS_TSUITE/Sea-DSA/cs"
export RESULTS_TSUITE_SDSA_BUTD_CS="$RESULTS_TSUITE/Sea-DSA/butd-cs"
export RESULTS_TSUITE_SDSA_BU="$RESULTS_TSUITE/Sea-DSA/bu"
export RESULTS_TSUITE_SDSA_CI="$RESULTS_TSUITE/Sea-DSA/ci"
export RESULTS_TSUITE_SDSA_FLAT="$RESULTS_TSUITE/Sea-DSA/flat"
export RESULTS_TSUITE_SVF="$RESULTS_TSUITE/SVF"

export TSUIT_BC_SUP_DIRS="
  context
  context+flow
  context+flow+heap
  context+path
  context+path+flow
  context+path+flow+heap
  context_insens
  context_sens
  field+context
  field+context+flow
  field+context+flow+heap
  field+context+path
  field+context+path+flow
  field+context+path+flow+heap
  field+flow
  field+flow+heap
  field+flow+path
  field+heap
  field+path+flow
  field+path+flow+heap
  field_sens
  flow
  flow+heap
  flow+path
  flow_sens
  funcptr_sens
  index_sens
  path+flow
  path_insens
  path_sens
"
