#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

# Наложение патчей Sea-DSA (если есть patches/seadsa/*.patch)
if [[ -d "$ROOT/patches/seadsa" ]] && compgen -G "$ROOT/patches/seadsa/"*.patch >/dev/null 2>&1; then
  "$ROOT/scripts/apply_seadsa_patches.sh" || exit 1
fi

export SRC="$SDSA_ROOT"
export CLI="$SDSA_CLI"
export CLI_TGT="install"
export LLVM_VER="14"
source "scripts/cmake_build.sh"
