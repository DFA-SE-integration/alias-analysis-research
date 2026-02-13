#!/usr/bin/env bash
set -euo pipefail

source "scripts/env.sh"

count=0
succ_count=0

RES_BASE="$ROOT/results/Test-Suite/Phasar"
mkdir -p "$RES_BASE"

for td in $TSUIT_BC_DIRS; do
  results_dir="$RES_BASE/$td"
  mkdir -p "$results_dir"
  
  # Skip if directory doesn't exist
  bc_dir="$TSUIT_BC_16/$td"
  [[ ! -d "$bc_dir" ]] && continue
  
  # Process each .bc file in the directory
  for f in "$bc_dir"/*.bc; do
    # Skip if glob didn't match any files
    [[ ! -f "$f" ]] && continue
    
    # Get basename without extension for output file
    basename_f=$(basename "$f")
    stem="${basename_f%.bc}"
    output_file="$results_dir/$stem.log"

    # Run command with stderr suppressed to avoid "Aborted" messages
    # but capture command output to file
    if { "$PHASAR_CLI" -m "$f" -D ifds-solvertest --entry-points=__ALL__ --alias-analysis=cflanders --emit-pta-as-json --emit-stats &> "$output_file"; } 2>/dev/null; then
        (( succ_count++ )) || true
    fi

    # if { "$PHASAR_CLI" -m "$f" -D ifds-solvertest --entry-points=__ALL__ --alias-analysis=cflsteens --emit-pta-as-json --emit-stats &> "$output_file"; } 2>/dev/null; then
        # (( succ_count++ )) || true
    # fi

    (( count++ )) || true
  done
done

echo "OK: Successfully processed $succ_count/$count .bc file(s). Results under $ROOT/results/"
