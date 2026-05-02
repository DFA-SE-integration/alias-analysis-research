#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

if [ ! -d "$CLANGIR_LLVM_BUILD_DIR" ]; then
  echo "clangir LLVM build dir not found at $CLANGIR_LLVM_BUILD_DIR" >&2
  exit 1
fi
if [ -e "$CLANGIR_LLVM_BUILD_LINK" ] && [ ! -L "$CLANGIR_LLVM_BUILD_LINK" ]; then
  echo "$CLANGIR_LLVM_BUILD_LINK exists and is not a symlink; remove it manually first" >&2
  exit 1
fi
ln -sfn "$CLANGIR_LLVM_BUILD_DIR" "$CLANGIR_LLVM_BUILD_LINK"

export SRC="$SDSA_LLVM20_ROOT"
export CLI="$SDSA_LLVM20_CLI"
export CLI_TGT="seadsa"
export LLVM_VER="20"
export BUILD_DIR="$SDSA_LLVM20_ROOT/build"
export LLVM_BIN_OVERRIDE="$CLANGIR_LLVM_BUILD_LINK/bin"
export LLVM_CMAKE_OVERRIDE="$CLANGIR_LLVM_BUILD_LINK/lib/cmake/llvm"
export CC_OVERRIDE="$CLANGIR_LLVM_BUILD_LINK/bin/clang"
export CXX_OVERRIDE="$CLANGIR_LLVM_BUILD_LINK/bin/clang++"
export CMAKE_EXTRA_ARGS=(-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON)
source "$ROOT/scripts/cmake_build.sh"
