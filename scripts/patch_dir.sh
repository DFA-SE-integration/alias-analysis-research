#!/usr/bin/env bash
set -euo pipefail

# Must be defined:
# SRC_DIR - project source dir
if [ ! -n "${SRC_DIR:-}" ]; then
  echo "SRC_DIR not defined!" >&2
  return 1 2>/dev/null || exit 1
fi
# PATCH_DIR - project patch dir
if [ ! -n "${PATCH_DIR:-}" ]; then
  echo "PATCH_DIR not defined!" >&2
  return 1 2>/dev/null || exit 1
fi

shopt -s nullglob
patches=("$PATCH_DIR"/*.patch)
if [[ ${#patches[@]} -eq 0 ]]; then
  return 0 2>/dev/null || exit 0
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
      # Check if files from patch already exist (partially applied)
      # Extract file paths from patch header (lines with +++ that are not /dev/null)
      patch_files=$(grep '^\+\+\+' "$p" | grep -v '/dev/null' | sed 's/^\+\+\+ [^/]*\///' | head -5)
      if [[ -n "$patch_files" ]]; then
        # Check if any of these files exist
        found=false
        for f in $patch_files; do
          if [[ -f "$f" ]]; then
            found=true
            break
          fi
        done
        if [[ "$found" == "true" ]]; then
          echo "WARNING: Patch appears partially applied (files exist), skipping: $name" >&2
          continue
        fi
      fi
      echo "ERROR: Failed to apply patch: $p" >&2
      echo "Patch check output:" >&2
      git apply --check -p0 --whitespace=fix "$p" 2>&1 | head -10 >&2
      return 1 2>/dev/null || exit 1
    fi
  fi
done
return 0 2>/dev/null || exit 0
