#!/usr/bin/env bash
# Apply all patches from patches/phasar/ to the phasar tree.
# Called from 02_build_phasar.sh before building.
# Exit 0 if no patches or all applied; exit 1 on first apply failure.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PHASAR_DIR="$ROOT/phasar"
PATCHES_DIR="$ROOT/patches/phasar"

if [[ ! -d "$PATCHES_DIR" ]]; then
  exit 0
fi

shopt -s nullglob
patches=("$PATCHES_DIR"/*.patch)
if [[ ${#patches[@]} -eq 0 ]]; then
  exit 0
fi

# Sort by name so 001-... is applied before 002-...
IFS=$'\n' sorted=($(sort <<<"${patches[*]}")); unset IFS

cd "$PHASAR_DIR"
# Patches have paths like tools/phasar-cli/... relative to phasar; use -p0
for p in "${sorted[@]}"; do
  name="$(basename "$p")"
  if git apply --check -p0 --whitespace=fix "$p" 2>/dev/null; then
    git apply -p0 --whitespace=fix "$p"
    echo "Applied phasar patch: $name"
  else
    # Already applied or conflicting
    if git apply --reverse --check -p0 "$p" 2>/dev/null; then
      echo "Patch already applied, skipping: $name"
    else
      echo "ERROR: Failed to apply patch: $p" >&2
      exit 1
    fi
  fi
done
exit 0
