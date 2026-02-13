#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

# Наложение патчей PhASAR, чтобы прогнать тесты Test-Suite
if [[ -d "$ROOT/patches/phasar" ]] && compgen -G "$ROOT/patches/phasar/"*.patch >/dev/null 2>&1; then
  "$ROOT/scripts/apply_phasar_patches.sh" || exit 1
fi

export SRC="$PHASAR_ROOT"
export CLI="$PHASAR_CLI"
export CLI_TGT="phasar-cli"
export LLVM_VER="16"
source "scripts/cmake_build.sh"
