#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

VERSION="1.0.8"
URL="https://sourceware.org/pub/bzip2/bzip2-${VERSION}.tar.gz"
SRC_DIR="$SCALABILITY_SRC/bzip2-${VERSION}"

# Source files that form the library + main binary (excludes bzip2recover)
SRCS=(blocksort huffman crctable randtable compress decompress bzlib bzip2)

mkdir -p "$SCALABILITY_SRC"

if [ ! -d "$SRC_DIR" ]; then
    echo "Downloading bzip2-${VERSION}..."
    if command -v curl &>/dev/null; then
        curl -fL "$URL" | tar -xz -C "$SCALABILITY_SRC"
    else
        wget -qO- "$URL" | tar -xz -C "$SCALABILITY_SRC"
    fi
fi

echo "bzip2 source: $SRC_DIR ($(wc -l < <(cat "$SRC_DIR"/*.c 2>/dev/null | wc -l)) lines)"

# ---------- llvm-14 ----------
OUT_14="$(dirname "$SCALABILITY_BC_14")"
mkdir -p "$OUT_14"

echo "Compiling with clang-14..."
OBJ14=()
for s in "${SRCS[@]}"; do
    clang-14 -emit-llvm -O0 -g -c "$SRC_DIR/${s}.c" -o "$OUT_14/${s}.bc"
    OBJ14+=("$OUT_14/${s}.bc")
done
llvm-link-14 "${OBJ14[@]}" -o "$SCALABILITY_BC_14"
echo "OK: $SCALABILITY_BC_14"

# ---------- llvm-16 ----------
OUT_16="$(dirname "$SCALABILITY_BC_16")"
mkdir -p "$OUT_16"

echo "Compiling with clang-16..."
OBJ16=()
for s in "${SRCS[@]}"; do
    clang-16 -emit-llvm -O0 -g -c "$SRC_DIR/${s}.c" -o "$OUT_16/${s}.bc"
    OBJ16+=("$OUT_16/${s}.bc")
done
llvm-link-16 "${OBJ16[@]}" -o "$SCALABILITY_BC_16"
echo "OK: $SCALABILITY_BC_16"

# ---------- llvm-20 ----------
export LLVM_BIN_OVERRIDE="$CLANGIR_LLVM_BUILD_LINK/bin"
export CLANG_BIN="$CLANGIR_LLVM_BUILD_LINK/bin/clang"

OUT_20="$(dirname "$SCALABILITY_BC_20")"
mkdir -p "$OUT_20"

echo "Compiling with clang-20..."
OBJ20=()
for s in "${SRCS[@]}"; do
    $CLANG_BIN -emit-llvm -O0 -g -c "$SRC_DIR/${s}.c" -o "$OUT_20/${s}.bc"
    OBJ20+=("$OUT_20/${s}.bc")
done
$LLVM_BIN_OVERRIDE/llvm-link "${OBJ20[@]}" -o "$SCALABILITY_BC_20"
echo "OK: $SCALABILITY_BC_20"