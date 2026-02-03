#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SVF_SRC="$ROOT/SVF"
BUILD="$SVF_SRC/build"

# Flush before build
rm -rf "$BUILD"

LLVM_VER=14
LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"

export PATH="$LLVM_BIN:$PATH"

# https://github.com/svf-tools/SVF/wiki/User-Guide#quick-start

cd "$SVF_SRC"

export SVF_HOME=$SVF_SRC
export LLVM_DIR="/usr/lib/llvm-${LLVM_VER}"
export Z3_DIR="$ROOT/z3-4.15.4-x64-glibc-2.39"
echo "SVF: took Z3 from $Z3_DIR"
export LD_LIBRARY_PATH=""
export DYLD_LIBRARY_PATH=""
. ./setup.sh Release

export Z3_BIN="$ROOT/Z3/bin/z3"
export SVF_SANITIZER=""
. ./build.sh Release
