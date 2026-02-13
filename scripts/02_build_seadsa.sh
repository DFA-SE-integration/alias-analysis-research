#!/usr/bin/env bash
set -euo pipefail

# Задание иерархии сборки
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SEADSA_SRC="$ROOT/sea-dsa"
BUILD="$SEADSA_SRC/build"
export SDSA_CLI="$BUILD/bin/seadsa"

# Задание путей к тулчейну
LLVM_VER=14
LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"
LLVM_CMAKE="/usr/lib/llvm-${LLVM_VER}/lib/cmake/llvm"
export PATH="$LLVM_BIN:$PATH"

# Наложение патчей Sea-DSA (если есть patches/seadsa/*.patch)
if [[ -d "$ROOT/patches/seadsa" ]] && compgen -G "$ROOT/patches/seadsa/"*.patch >/dev/null 2>&1; then
  "$ROOT/scripts/apply_seadsa_patches.sh" || exit 1
fi

# Если цель уже существует, выходим
if [[ -x "$SDSA_CLI" ]]; then
  echo "already built at $SDSA_CLI, skipping"
  exit 0
fi

# Для воспроизводимости: чистая конфигурация
rm -rf "$BUILD"

# Явно укажем clang-scan-deps, чтобы не зависеть от PATH
SCAN_DEPS="$LLVM_BIN/clang-scan-deps"
test -x "$SCAN_DEPS" || { echo "ERROR: $SCAN_DEPS not found. Install clang-tools-${LLVM_VER} / llvm-${LLVM_VER}-tools"; exit 1; }

# Вызов cmake
cd "$SEADSA_SRC"
cmake -S "$SEADSA_SRC" -B "$BUILD" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang-${LLVM_VER} \
  -DCMAKE_CXX_COMPILER=clang++-${LLVM_VER} \
  -DCMAKE_CXX_COMPILER_CLANG_SCAN_DEPS="$SCAN_DEPS" \
  -DLLVM_DIR="$LLVM_CMAKE"

# Сборка
ninja -C "$BUILD" -j"$(nproc)" install

# Проверка
test -x "$SDSA_CLI"
"$SDSA_CLI" --version
echo "OK: seadsa-cli built at $SDSA_CLI"
