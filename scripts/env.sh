#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

export PHASAR_CLI="$ROOT/phasar/build/tools/phasar-cli/phasar-cli"
export SDSA_CLI="$ROOT/sea-dsa/build/bin/seadsa"
export WPA_CLI="$ROOT/SVF/build/bin/wpa"

echo "env.sh loaded"
echo "PHASAR_CLI=$PHASAR_CLI"
echo "SDSA_CLI=$SDSA_CLI"
echo "WPA_CLI=$WPA_CLI"
