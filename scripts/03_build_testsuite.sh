#!/usr/bin/env bash
set -euo pipefail

# Задание иерархии сборки
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TSUITE="$ROOT/tests/Test-Suite"
TSUITE_SRC="$TSUITE/src"
BUILD="$TSUITE/build"

# TODO
# complex_tests
# mem_leak
# double_free
test_dirs="
  basic_c_tests
  fs_tests
  cs_tests
  path_tests
  non_annotated_tests
"

# Задание путей к тулчейну
LLVM_VER=16
LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"
LLVM_CMAKE="/usr/lib/llvm-${LLVM_VER}/lib/cmake/llvm"
# export PATH="$LLVM_BIN:$PATH"
TSUITE_BC="$BUILD/bc/llvm-${LLVM_VER}"

mkdir -p "$TSUITE_BC"
count=$(find "$TSUITE_BC" -name "*.bc" 2>/dev/null | wc -l)
if [ "$count" -gt 0 ]; then
  echo "$TSUITE_BC already has $count .bc file(s), skipping."
  exit 0
fi

for td in $test_dirs; do
  # Take source test dir 
  src_td="$TSUITE_SRC/$td"

  # Take it binary code test dir
  bc_td="$TSUITE_BC/$td"
  mkdir -p "$bc_td"

  # Foreach source file 
  for src_f in "$src_td"/*; do
    # Take respective bin file
    bc_f="$bc_td/$(basename "$src_f").bc"
    echo "Compiling $src_f -> $bc_f"

    base_flags=(-Wno-everything -fno-discard-value-names -I"$TSUITE" -c -emit-llvm -o "$bc_f" "$src_f")
    $LLVM_BIN/clang -g "${base_flags[@]}"
  done
done

echo "OK: PTABen bitcode generated under $TSUITE_BC"

# Задание путей к тулчейну
LLVM_VER=16
LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"
LLVM_CMAKE="/usr/lib/llvm-${LLVM_VER}/lib/cmake/llvm"
# export PATH="$LLVM_BIN:$PATH"
TSUITE_BC="$BUILD/bc/llvm-${LLVM_VER}"

mkdir -p "$TSUITE_BC"
count=$(find "$TSUITE_BC" -name "*.bc" 2>/dev/null | wc -l)
if [ "$count" -gt 0 ]; then
  echo "$TSUITE_BC already has $count .bc file(s), skipping."
  exit 0
fi

for td in $test_dirs; do
  # Take source test dir 
  src_td="$TSUITE_SRC/$td"

  # Take it binary code test dir
  bc_td="$TSUITE_BC/$td"
  mkdir -p "$bc_td"

  # Foreach source file 
  for src_f in "$src_td"/*; do
    # Take respective bin file
    bc_f="$bc_td/$(basename "$src_f").bc"
    echo "Compiling $src_f -> $bc_f"

    base_flags=(-Wno-everything -fno-discard-value-names -I"$TSUITE" -c -emit-llvm -o "$bc_f" "$src_f")
    $LLVM_BIN/clang -g "${base_flags[@]}"
  done
done

echo "OK: PTABen bitcode generated under $TSUITE_BC"
