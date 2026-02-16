#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

export SRC="$SVF_ROOT"
export CLI="$WPA_CLI"
export CLI_TGT=""
export LLVM_VER="14"
CMAKE_EXTRA_ARGS=(-DBUILD_SHARED_LIBS=ON -DSVF_ENABLE_ASSERTIONS:BOOL=true -DSVF_SANITIZE="")
export CMAKE_EXTRA_ARGS
source "$ROOT/scripts/cmake_build.sh"
