#!/usr/bin/env bash
set -euo pipefail

# Run PhASAR, SeaDSA, and/or SVF on all PTABen (Test-Suite) bitcode files.
# PTABEN_TOOL=phasar|seadsa|svf|all (default: all)
# Optional: PTABEN_CATEGORIES="basic_c_tests fs_tests" to limit categories (space-separated; empty = all).
# Optional: PTABEN_LIMIT=N to process at most N .bc files (for quick sanity runs).

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PTABEN_ROOT="$ROOT/test-projects/PTABen"
BC_BASE="$PTABEN_ROOT/test_cases_bc"
RESULTS_BASE="$ROOT/results"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

TOOL="${PTABEN_TOOL:-all}"
CATEGORIES_FILTER="${PTABEN_CATEGORIES:-}"
LIMIT="${PTABEN_LIMIT:-0}"

if [[ ! -d "$BC_BASE" ]]; then
  echo "ERROR: PTABen bitcode not found at $BC_BASE. Run 'make build-ptaben' first."
  exit 1
fi

run_phasar() {
  local bc="$1" out="$2"
  mkdir -p "$out"
  "$PHASAR_CLI" -m "$bc" -D ifds-solvertest --entry-points=__ALL__ --alias-analysis=cflanders --emit-pta-as-json --emit-stats &>"$out/pta.anders.json" || true
  "$PHASAR_CLI" -m "$bc" -D ifds-solvertest --entry-points=__ALL__ --alias-analysis=cflsteens --emit-pta-as-json --emit-stats &>"$out/pta.steens.json" || true
  echo "  phasar -> $out"
}

run_seadsa() {
  local bc="$1" out="$2"
  mkdir -p "$out"
  for aa in cs butd-cs bu ci flat; do
    "$SDSA_CLI" --sea-dsa-aa-eval --sea-dsa-stats --sea-dsa="$aa" "$bc" &>"$out/pta.$aa.log" || true
  done
  echo "  seadsa -> $out"
}

run_svf() {
  local bc="$1" out="$2"
  mkdir -p "$out"
  for aa in nander sander ander sfrander fspta vfspta type; do
    "$WPA_CLI" -print-all-pts -stat -$aa "$bc" &>"$out/pta.$aa.json" || true
  done
  echo "  svf -> $out"
}

case "$TOOL" in
  phasar)
    test -x "${PHASAR_CLI:-}" || { echo "ERROR: PHASAR_CLI not set or not executable. Source env.sh after building phasar."; exit 1; }
    ;;
  seadsa)
    test -x "${SDSA_CLI:-}" || { echo "ERROR: SDSA_CLI not set or not executable. Source env.sh after building sea-dsa."; exit 1; }
    ;;
  svf)
    test -x "${WPA_CLI:-}" || { echo "ERROR: WPA_CLI not set or not executable. Source env.sh after building SVF."; exit 1; }
    ;;
  all)
    RUN_PHASAR=0
    RUN_SEADSA=0
    RUN_SVF=0
    if [[ -x "${PHASAR_CLI:-}" ]]; then RUN_PHASAR=1; else echo "WARNING: PhASAR not built (PHASAR_CLI missing or not executable). Skipping."; fi
    if [[ -x "${SDSA_CLI:-}" ]]; then RUN_SEADSA=1; else echo "WARNING: SeaDSA not built (SDSA_CLI missing or not executable). Skipping."; fi
    if [[ -x "${WPA_CLI:-}" ]]; then RUN_SVF=1; else echo "WARNING: SVF not built (WPA_CLI missing or not executable). Skipping."; fi
    if [[ "$RUN_PHASAR" -eq 0 && "$RUN_SEADSA" -eq 0 && "$RUN_SVF" -eq 0 ]]; then
      echo "ERROR: No tool available. Build at least one of: make phasar, make seadsa, make svf"
      exit 1
    fi
    ;;
  *)
    echo "ERROR: PTABEN_TOOL must be phasar|seadsa|svf|all (got: $TOOL)"
    exit 1
    ;;
esac

count=0
while IFS= read -r -d '' bc; do
  if [[ "$bc" != *.bc ]]; then
    continue
  fi
  if [[ "$bc" == *".pre.bc" || "$bc" == *".pre.svf.bc" || "$bc" == *".svf.bc" ]]; then
    continue
  fi

  rel="${bc#$BC_BASE/}"
  category="${rel%%/*}"
  basename_bc="${rel##*/}"
  stem="${basename_bc%.bc}"

  if [[ -n "$CATEGORIES_FILTER" ]]; then
    if [[ " $CATEGORIES_FILTER " != *" $category "* ]]; then
      continue
    fi
  fi

  if [[ "$LIMIT" -gt 0 && "$count" -ge "$LIMIT" ]]; then
    echo "PTABen: stopping after $LIMIT files (PTABEN_LIMIT=$LIMIT)"
    break
  fi

  echo "PTABen: $rel"
  out_phasar="$RESULTS_BASE/phasar/ptaben/$category/$stem"
  out_seadsa="$RESULTS_BASE/seadsa/ptaben/$category/$stem"
  out_svf="$RESULTS_BASE/svf/ptaben/$category/$stem"

  if [[ "$TOOL" == "phasar" || ("$TOOL" == "all" && "${RUN_PHASAR:-1}" -eq 1) ]]; then
    run_phasar "$bc" "$out_phasar"
  fi
  if [[ "$TOOL" == "seadsa" || ("$TOOL" == "all" && "${RUN_SEADSA:-1}" -eq 1) ]]; then
    run_seadsa "$bc" "$out_seadsa"
  fi
  if [[ "$TOOL" == "svf" || ("$TOOL" == "all" && "${RUN_SVF:-1}" -eq 1) ]]; then
    run_svf "$bc" "$out_svf"
  fi

  (( count++ )) || true
done < <(find "$BC_BASE" -type f -name "*.bc" -print0 2>/dev/null | sort -z)

echo "OK: PTABen PTA finished; processed $count .bc file(s). Results under $RESULTS_BASE/{phasar,seadsa,svf}/ptaben/"
