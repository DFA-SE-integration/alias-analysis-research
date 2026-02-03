#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
seadsa_SRC="$ROOT/sea-dsa"
BUILD="$seadsa_SRC/build"

# Flush before build
rm -rf "$BUILD"

LLVM_VER=14
LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"

export PATH="$LLVM_BIN:$PATH"

cd "$seadsa_SRC"
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=run -DLLVM_DIR=/usr/lib/llvm-14/share/llvm/cmake  ..
cmake --build . --target install
