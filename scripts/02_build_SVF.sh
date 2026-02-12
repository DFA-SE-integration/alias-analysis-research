#!/usr/bin/env bash
set -euo pipefail

# Задание иерархии сборки
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SVF_SRC="$ROOT/SVF"
BUILD="$SVF_SRC/build"
export WPA_CLI="$ROOT/SVF/build/bin/wpa"

# Задание путей к тулчейну
LLVM_VER=14
LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"
LLVM_LIB="/usr/lib/llvm-${LLVM_VER}/lib"
LLVM_CMAKE="/usr/lib/llvm-${LLVM_VER}/lib/cmake/llvm"
export PATH="$LLVM_BIN:$PATH"

# Если цель уже существует, выходим
if [[ -x "$WPA_CLI" ]]; then
  echo "already built at $WPA_CLI, skipping"
  exit 0
fi

# Для воспроизводимости: чистая конфигурация
rm -rf "$BUILD"

# Явно укажем clang-scan-deps, чтобы не зависеть от PATH
SCAN_DEPS="$LLVM_BIN/clang-scan-deps"
test -x "$SCAN_DEPS" || { echo "ERROR: $SCAN_DEPS not found. Install clang-tools-${LLVM_VER} / llvm-${LLVM_VER}-tools"; exit 1; }

# Зависимый тулчейн
SVF_SANITIZER=""
BUILD_DYN_LIB='ON'
Z3_BIN="$ROOT/z3-4.15.4-x64-glibc-2.39/bin"
echo "SVF: took Z3 from $Z3_BIN"
export PATH=$Z3_BIN:$PATH

# Вызов cmake
cd "$SVF_SRC"
cmake -S "$SVF_SRC" -B "${BUILD}" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_C_COMPILER=clang-${LLVM_VER} \
    -DCMAKE_CXX_COMPILER=clang++-${LLVM_VER} \
    -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="$SCAN_DEPS" \
    -DLLVM_DIR="$LLVM_CMAKE" \
    -DBUILD_SHARED_LIBS=${BUILD_DYN_LIB}    \
    -DSVF_ENABLE_ASSERTIONS:BOOL=true   \
    -DSVF_SANITIZE="${SVF_SANITIZER}"   \
    -S "${SVF_SRC}" -B "${BUILD}"

# Сборка
ninja -C "$BUILD" -j"$(nproc)"

# Проверка
test -x "$WPA_CLI"
echo "OK: svf-cli built at $WPA_CLI"
