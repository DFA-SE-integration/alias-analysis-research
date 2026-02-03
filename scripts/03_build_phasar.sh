#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PHASAR_SRC="$ROOT/phasar"
BUILD="$PHASAR_SRC/build"

LLVM_VER=14
LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"
LLVM_CMAKE="/usr/lib/llvm-${LLVM_VER}/lib/cmake/llvm"

export PATH="$LLVM_BIN:$PATH"

# Для воспроизводимости: всегда чистая конфигурация
rm -rf "$BUILD"

cd "$PHASAR_SRC"

# Явно укажем clang-scan-deps, чтобы не зависеть от PATH
SCAN_DEPS="$LLVM_BIN/clang-scan-deps"
test -x "$SCAN_DEPS" || { echo "ERROR: $SCAN_DEPS not found. Install clang-tools-${LLVM_VER} / llvm-${LLVM_VER}-tools"; exit 1; }

cmake -S "$PHASAR_SRC" -B "$BUILD" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang-${LLVM_VER} \
  -DCMAKE_CXX_COMPILER=clang++-${LLVM_VER} \
  -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="$SCAN_DEPS" \
  -DLLVM_DIR="$LLVM_CMAKE" \
  -DPHASAR_BUILD_UNITTESTS=OFF \
  -DPHASAR_BUILD_IR=OFF

ninja -C "$BUILD" -j"$(nproc)" phasar-cli

test -x "$BUILD/tools/phasar-cli/phasar-cli"
"$BUILD/tools/phasar-cli/phasar-cli" --version
echo "OK: phasar-cli built at $BUILD/tools/phasar-cli/phasar-cli"

