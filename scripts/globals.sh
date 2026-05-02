#!/usr/bin/env bash
set -euo pipefail

# Project
export ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Phasar
export PHASAR_ROOT="$ROOT/phasar"
export PHASAR_CLI="$PHASAR_ROOT/build/tools/phasar-cli/phasar-cli"

# Sea-Dsa
export SDSA_LLVM14_ROOT="$ROOT/sea-dsa"
export SDSA_LLVM20_ROOT="$ROOT/sea-dsa-llvm20"
export SDSA_LLVM14_CLI="$SDSA_LLVM14_ROOT/build/bin/seadsa"
export SDSA_LLVM20_CLI="$SDSA_LLVM20_ROOT/build/bin/seadsa"

# clangir / LLVM20
export CLANGIR_LLVM_SRC_DIR="$ROOT/clangir-glibc-arm64"
export CLANGIR_ROOT="$(dirname "$CLANGIR_LLVM_SRC_DIR")"
export CLANGIR_LLVM_BUILD_DIR="$CLANGIR_LLVM_SRC_DIR/build"
export CLANGIR_BIN="$CLANGIR_LLVM_BUILD_DIR/bin"
export CLANGIR_LLVM_CMAKE="$CLANGIR_LLVM_BUILD_DIR/lib/cmake/llvm"
export CLANGIR_LLVM_BUILD_LINK="/tmp/llvm-build"

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
export TSUIT_BC_20="$ROOT/tests/Test-Suite/build/bc/llvm-20"

# Scalability
export SCALABILITY_SRC="$ROOT/tests/scalability"
export SCALABILITY_BC_14="$ROOT/tests/scalability/build/llvm-14/bzip2.bc"
export SCALABILITY_BC_16="$ROOT/tests/scalability/build/llvm-16/bzip2.bc"
export SCALABILITY_BC_20="$ROOT/tests/scalability/build/llvm-20/bzip2.bc"
export SCALABILITY_TIMEOUT=120

# Results
export RESULTS_ROOT="$ROOT/results"

# Tests
export RESULTS_TSUITE="$RESULTS_ROOT/Test-Suite"
export RESULTS_SCALABILITY="$RESULTS_ROOT/scalability"
