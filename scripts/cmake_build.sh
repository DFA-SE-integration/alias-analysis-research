#!/usr/bin/env bash
set -euo pipefail

# Must be defined:
# SRC - project source dir
if [ ! -n "${SRC}" ]; then
  echo "SRC not defined!" >&2
  exit 1
fi
# CLI - path to building tool cli
if [ ! -n "${CLI}" ]; then
  echo "CLI not defined!" >&2
  exit 1
fi
# CLI_TGT - name of cli build target
# LLVM_VER - toolchain version
if [ ! -n "${LLVM_VER}" ]; then
  echo "LLVM_VER not defined!" >&2
  exit 1
fi

# Если цель уже существует, выходим
if [[ -x "$CLI" ]]; then
  echo "built at $CLI, skipping"
  exit 0
fi

# Задание иерархии сборки
BUILD="${BUILD_DIR:-$SRC/build}"

# Задание путей к тулчейну
LLVM_BIN="${LLVM_BIN_OVERRIDE:-/usr/lib/llvm-${LLVM_VER}/bin}"
LLVM_CMAKE="${LLVM_CMAKE_OVERRIDE:-/usr/lib/llvm-${LLVM_VER}/lib/cmake/llvm}"
CC="${CC_OVERRIDE:-clang-${LLVM_VER}}"
CXX="${CXX_OVERRIDE:-clang++-${LLVM_VER}}"

# Явно укажем clang-scan-deps, чтобы не зависеть от PATH
SCAN_DEPS="$LLVM_BIN/clang-scan-deps"
if [ ! -x "$SCAN_DEPS" ]; then
    echo "ERROR: $SCAN_DEPS not found. Install clang-tools-${LLVM_VER} / llvm-${LLVM_VER}-tools"
    exit 1
fi

# Дополнительные аргументы CMake как массив
CMAKE_EXTRA_ARGS=("${CMAKE_EXTRA_ARGS[@]:-}")

# Вызов cmake
cd "$SRC"
cmake -S "$SRC" -B "$BUILD" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="$CC" \
  -DCMAKE_CXX_COMPILER="$CXX" \
  -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="$SCAN_DEPS" \
  -DLLVM_DIR="$LLVM_CMAKE" \
  "${CMAKE_EXTRA_ARGS[@]}"

# Сборка
ninja -C "$BUILD" -j"$(nproc)" ${CLI_TGT}

# Проверка
test -x "$CLI"
echo "OK: built at $CLI"

