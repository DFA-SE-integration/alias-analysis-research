#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

LLVM_VER="14"
export LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"
export INC_DIR="$TSUITE_ROOT"
export SRC_DIR="$TSUITE_SRC"
export DEST_DIR="$TSUIT_BC_14"
source "scripts/emit_bc.sh"

LLVM_VER="16"
export LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"
export INC_DIR="$TSUITE_ROOT"
export SRC_DIR="$TSUITE_SRC"
export DEST_DIR="$TSUIT_BC_16"
source "scripts/emit_bc.sh"
