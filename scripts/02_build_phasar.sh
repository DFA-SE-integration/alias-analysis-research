#!/usr/bin/env bash
set -euo pipefail

# Задание иерархии сборки
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PHASAR_SRC="$ROOT/phasar"
BUILD="$PHASAR_SRC/build"
export PHASAR_CLI="$ROOT/phasar/build/tools/phasar-cli/phasar-cli"

# Задание путей к тулчейну
LLVM_VER=16
LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"
LLVM_CMAKE="/usr/lib/llvm-${LLVM_VER}/lib/cmake/llvm"
export PATH="$LLVM_BIN:$PATH"

# Наложение патчей PhASAR, чтобы прогнать тесты Test-Suite
if [[ -d "$ROOT/patches/phasar" ]] && compgen -G "$ROOT/patches/phasar/"*.patch >/dev/null 2>&1; then
  "$ROOT/scripts/apply_phasar_patches.sh" || exit 1
fi

# Если цель уже существует, выходим
if [[ -x "$PHASAR_CLI" ]]; then
  echo "built at $PHASAR_CLI, skipping"
  exit 0
fi

# Для воспроизводимости: чистая конфигурация
rm -rf "$BUILD"

# Явно укажем clang-scan-deps, чтобы не зависеть от PATH
SCAN_DEPS="$LLVM_BIN/clang-scan-deps"
test -x "$SCAN_DEPS" || { echo "ERROR: $SCAN_DEPS not found. Install clang-tools-${LLVM_VER} / llvm-${LLVM_VER}-tools"; exit 1; }

# Вызов cmake
cd "$PHASAR_SRC"
cmake -S "$PHASAR_SRC" -B "$BUILD" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang-${LLVM_VER} \
  -DCMAKE_CXX_COMPILER=clang++-${LLVM_VER} \
  -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="$SCAN_DEPS" \
  -DLLVM_DIR="$LLVM_CMAKE" \
  -DPHASAR_BUILD_UNITTESTS=OFF \
  -DPHASAR_BUILD_IR=OFF

# Сборка
ninja -C "$BUILD" -j"$(nproc)" phasar-cli

# Проверка
test -x "$PHASAR_CLI"
"$PHASAR_CLI" --version
echo "OK: phasar-cli built at $PHASAR_CLI"

