#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

mkdir -p "$RESULTS_SCALABILITY"

# run_mode TOOL MODE BC_FILE
# Runs the tool with a timeout, writes stdout+stderr to log,
# appends SCALABILITY_STATUS and SCALABILITY_WALL_MS at the end.
run_mode() {
    local tool="$1" mode="$2" bc="$3"
    shift 3
    local cmd=("$@")

    local log_dir="$RESULTS_SCALABILITY/$tool"
    mkdir -p "$log_dir"
    local log_file="$log_dir/$mode.log"

    echo "  Running $tool+$mode..."

    local start_ms
    start_ms=$(date +%s%3N)

    local exit_code=0
    timeout "$SCALABILITY_TIMEOUT" "${cmd[@]}" &> "$log_file" || exit_code=$?

    local end_ms
    end_ms=$(date +%s%3N)
    local wall_ms=$(( end_ms - start_ms ))

    local status
    if   [ $exit_code -eq 0 ];   then status="OK"
    elif [ $exit_code -eq 124 ]; then status="TIMEOUT"
    elif [ $exit_code -eq 137 ]; then status="OOM"
    else                              status="ERROR($exit_code)"
    fi

    echo "SCALABILITY_STATUS: $status"    >> "$log_file"
    echo "SCALABILITY_WALL_MS: $wall_ms" >> "$log_file"

    echo "    -> $status in ${wall_ms}ms"
}

# ---------- SVF (llvm-14) ----------
echo "=== SVF ==="
run_mode SVF ander   "$SCALABILITY_BC_14"  "$WPA_CLI" -ander  -stat=true "$SCALABILITY_BC_14"
run_mode SVF fspta   "$SCALABILITY_BC_14"  "$WPA_CLI" -fspta  -stat=true "$SCALABILITY_BC_14"
run_mode SVF vfspta  "$SCALABILITY_BC_14"  "$WPA_CLI" -vfspta -stat=true "$SCALABILITY_BC_14"
run_mode SVF cxt     "$SCALABILITY_BC_14"  "$DVF_CLI" -cxt    -stat=true "$SCALABILITY_BC_14"

# ---------- Sea-DSA (llvm-14) ----------
echo "=== Sea-DSA-llvm14 ==="
run_mode Sea-DSA-llvm14 bu      "$SCALABILITY_BC_14"  "$SDSA_LLVM14_CLI" --sea-dsa-stats --sea-dsa=bu      "$SCALABILITY_BC_14"
run_mode Sea-DSA-llvm14 ci      "$SCALABILITY_BC_14"  "$SDSA_LLVM14_CLI" --sea-dsa-stats --sea-dsa=ci      "$SCALABILITY_BC_14"
run_mode Sea-DSA-llvm14 flat    "$SCALABILITY_BC_14"  "$SDSA_LLVM14_CLI" --sea-dsa-stats --sea-dsa=flat    "$SCALABILITY_BC_14"
run_mode Sea-DSA-llvm14 cs      "$SCALABILITY_BC_14"  "$SDSA_LLVM14_CLI" --sea-dsa-stats --sea-dsa=cs      "$SCALABILITY_BC_14"
run_mode Sea-DSA-llvm14 butd-cs "$SCALABILITY_BC_14"  "$SDSA_LLVM14_CLI" --sea-dsa-stats --sea-dsa=butd-cs "$SCALABILITY_BC_14"

# ---------- Phasar (llvm-16) ----------
echo "=== Phasar ==="
run_mode Phasar cflanders "$SCALABILITY_BC_16"  \
    "$PHASAR_CLI" -m "$SCALABILITY_BC_16" -D ifds-solvertest --entry-points=__ALL__ \
    --alias-analysis=cflanders --emit-pta-as-json --emit-stats
run_mode Phasar cflsteens "$SCALABILITY_BC_16"  \
    "$PHASAR_CLI" -m "$SCALABILITY_BC_16" -D ifds-solvertest --entry-points=__ALL__ \
    --alias-analysis=cflsteens --emit-pta-as-json --emit-stats

echo "OK: scalability results under $RESULTS_SCALABILITY"

# ---------- Sea-DSA (llvm-20) ----------
echo "=== Sea-DSA-llvm20 ==="
run_mode Sea-DSA-llvm20 bu      "$SCALABILITY_BC_20"  "$SDSA_LLVM20_CLI" --sea-dsa-stats --sea-dsa=bu      "$SCALABILITY_BC_14"
run_mode Sea-DSA-llvm20 ci      "$SCALABILITY_BC_20"  "$SDSA_LLVM20_CLI" --sea-dsa-stats --sea-dsa=ci      "$SCALABILITY_BC_14"
run_mode Sea-DSA-llvm20 flat    "$SCALABILITY_BC_20"  "$SDSA_LLVM20_CLI" --sea-dsa-stats --sea-dsa=flat    "$SCALABILITY_BC_14"
run_mode Sea-DSA-llvm20 cs      "$SCALABILITY_BC_20"  "$SDSA_LLVM20_CLI" --sea-dsa-stats --sea-dsa=cs      "$SCALABILITY_BC_14"
run_mode Sea-DSA-llvm20 butd-cs "$SCALABILITY_BC_20"  "$SDSA_LLVM20_CLI" --sea-dsa-stats --sea-dsa=butd-cs "$SCALABILITY_BC_20"
