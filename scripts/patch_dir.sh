#!/usr/bin/env bash
set -euo pipefail

# Must be defined:
# SRC_DIR - project source dir
if [ ! -n "${SRC_DIR}" ]; then
  echo "SRC_DIR not defined!" >&2
  exit 1
fi
# PATCH_DIR - project patch dir
if [ ! -n "${PATCH_DIR}" ]; then
  echo "PATCH_DIR not defined!" >&2
  exit 1
fi

shopt -s nullglob
patches=("$PATCH_DIR"/*.patch)
if [[ ${#patches[@]} -eq 0 ]]; then
  exit 0
fi

# Sort by name so 001-... is applied before 002-...
IFS=$'\n' sorted=($(sort <<<"${patches[*]}")); unset IFS

cd "$SRC_DIR"
for p in "${sorted[@]}"; do
  name="$(basename "$p")"
  if git apply --check -p0 --whitespace=fix "$p" 2>/dev/null; then
    git apply -p0 --whitespace=fix "$p"
    echo "Applied patch: $name"
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
