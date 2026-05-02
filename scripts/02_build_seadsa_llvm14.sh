#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

export SRC="$SDSA_LLVM14_ROOT"
export CLI="$SDSA_LLVM14_CLI"
export CLI_TGT="install"
export LLVM_VER="14"
source "$ROOT/scripts/cmake_build.sh"
