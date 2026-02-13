#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

export PHASAR_CLI="$ROOT/phasar/build/tools/phasar-cli/phasar-cli"
export SDSA_CLI="$ROOT/sea-dsa/build/bin/seadsa"
export WPA_CLI="$ROOT/SVF/build/bin/wpa"
export DVF_CLI="$ROOT/SVF/build/bin/dvf"

export TSUIT_BC_14="$ROOT/tests/Test-Suite/build/bc/llvm-14"
export TSUIT_BC_16="$ROOT/tests/Test-Suite/build/bc/llvm-16"

# TODO
# complex_tests
# mem_leak
# double_free
export TSUIT_BC_DIRS="
  basic_c_tests
  fs_tests
  cs_tests
  path_tests
  non_annotated_tests
"

echo "env.sh loaded"
echo "PHASAR_CLI=$PHASAR_CLI"
echo "SDSA_CLI=$SDSA_CLI"
echo "WPA_CLI=$WPA_CLI"
