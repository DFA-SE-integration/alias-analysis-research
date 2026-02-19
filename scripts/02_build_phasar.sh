#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

export SRC="$PHASAR_ROOT"
export CLI="$PHASAR_CLI"
export CLI_TGT="phasar-cli"
export LLVM_VER="16"
source "$ROOT/scripts/cmake_build.sh"
