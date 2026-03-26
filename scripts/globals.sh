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

# Test-Suite
export TSUITE_ROOT="$TEST_ROOT/Test-Suite"
export TSUITE_SRC="$TEST_ROOT/Test-Suite/src"
export TSUIT_BC_14="$ROOT/tests/Test-Suite/build/bc/llvm-14"
export TSUIT_BC_16="$ROOT/tests/Test-Suite/build/bc/llvm-16"

# Results
export RESULTS_ROOT="$ROOT/results"

# Tests
export RESULTS_TSUITE="$RESULTS_ROOT/Test-Suite"
