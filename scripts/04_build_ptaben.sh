#!/usr/bin/env bash
set -euo pipefail

# Generate bitcode for PTABen (SVF-tools/Test-Suite). Idempotent: skips if test_cases_bc already populated.
# Use FORCE=1 to regenerate.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PTABEN="$ROOT/test-projects/PTABen"
SRC_PATH="$PTABEN/src"
BC_PATH="$PTABEN/test_cases_bc"

test_dirs="
  basic_c_tests
  basic_cpp_tests
  complex_tests
  cpp_types
  cs_tests
  fs_tests
  mem_leak
  double_free
  mta
  non_annotated_tests
  path_tests
  objtype_tests
  ae_overflow_tests
  ae_assert_tests
  ae_nullptr_deref_tests
  ae_recursion_tests
  ae_wto_assert
"

if [[ ! -d "$PTABEN/.git" ]]; then
  echo "ERROR: PTABen not found at $PTABEN. Run 'make checkout' first."
  exit 1
fi

# Skip if test_cases_bc already has bitcode (unless FORCE=1)
if [[ "${FORCE:-0}" != "1" ]] && [[ -d "$BC_PATH" ]]; then
  count=$(find "$BC_PATH" -maxdepth 2 -name "*.bc" 2>/dev/null | wc -l)
  if [[ "${count:-0}" -gt 0 ]]; then
    echo "OK: PTABen test_cases_bc already has $count .bc file(s), skipping. Use FORCE=1 to regenerate."
    exit 0
  fi
fi

# Load LLVM from env.sh (LLVM 14)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"
export PATH="$LLVM_BIN:$PATH"

mkdir -p "$BC_PATH"

for td in $test_dirs; do
  full_td="$SRC_PATH/$td"
  [[ ! -d "$full_td" ]] && continue

  bc_td="$BC_PATH/$td"
  mkdir -p "$bc_td"

  for c_f in "$full_td"/*; do
    [[ -f "$c_f" ]] || continue
    ext="${c_f##*.}"
    if [[ "$ext" != "c" && "$ext" != "cpp" ]]; then
      continue
    fi

    bc_f="$bc_td/$(basename "$c_f").bc"
    if [[ "${FORCE:-0}" != "1" ]] && [[ -f "$bc_f" ]] && [[ "$bc_f" -nt "$c_f" ]]; then
      continue
    fi

    if [[ "$ext" == "c" ]]; then
      compiler="clang"
    else
      compiler="clang++"
    fi

    echo "PTABen: Compiling $c_f -> $bc_f"

    base_flags=(-Wno-everything -fno-discard-value-names -I"$PTABEN" -c -emit-llvm -o "$bc_f" "$c_f")
    if [[ "$td" == "mem_leak" ]]; then
      $compiler -g "${base_flags[@]}"
    elif [[ "$td" == "ae_assert_tests" || "$td" == "ae_overflow_tests" || "$td" == "ae_recursion_tests" || "$td" == "ae_wto_assert" ]]; then
      $compiler -g -Xclang -DINCLUDEMAIN -Wno-implicit-function-declaration "${base_flags[@]}"
    else
      $compiler "${base_flags[@]}"
    fi

    opt -mem2reg "$bc_f" -o "${bc_f}.tmp" && mv "${bc_f}.tmp" "$bc_f"
  done
done

echo "OK: PTABen bitcode generated under $BC_PATH"
