#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

export PHASAR_CLI="$ROOT/phasar/build/tools/phasar-cli/phasar-cli"
export SDSA_CLI="$ROOT/sea-dsa/build/run/bin/seadsa"
export WPA_CLI="$ROOT/SVF/Release-build/bin/wpa"

LLVM_VER=14
export LLVM_BIN="/usr/lib/llvm-${LLVM_VER}/bin"
export PATH="$LLVM_BIN:$PATH"

export LLVM_COMPILER=clang
export LLVM_CC_NAME=clang-${LLVM_VER}
export LLVM_CXX_NAME=clang++-${LLVM_VER}
export LLVM_LINK_NAME=llvm-link-${LLVM_VER}
export LLVM_AR_NAME=llvm-ar-${LLVM_VER}

echo "env.sh loaded"
echo "PHASAR_CLI=$PHASAR_CLI"
echo "LLVM_BIN=$LLVM_BIN"
