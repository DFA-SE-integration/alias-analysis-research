#!/usr/bin/env bash
set -euo pipefail

# Script to count SUCCESS and FAILURE results from tool analysis
# Scans results/Test-Suite/$1 directory

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RESULTS_DIR="$ROOT/results/$1/$2"

if [[ ! -d "$RESULTS_DIR" ]]; then
    echo "ERROR: Results directory not found at $RESULTS_DIR"
    exit 1
fi

success_count=0
failure_count=0
total_count=0

# Process all .log files in the results directory
while IFS= read -r -d '' log_file; do
    (( total_count++ )) || true
    
    # Check if file is empty
    if [[ ! -s "$log_file" ]]; then
        (( failure_count++ )) || true
        continue
    fi
    
    # Check for failure indicators
    if grep -q "Aborted\|Assertion.*failed\|core dumped\|\t FAILURE :" "$log_file" 2>/dev/null; then
        (( failure_count++ )) || true
    else
        (( success_count++ )) || true
    fi
done < <(find "$RESULTS_DIR" -type f -name "*.log" -print0 2>/dev/null | sort -z)

# Print summary
echo "=== $2 Test-Suite Results Summary ==="
echo "Total files processed: $total_count"
echo "SUCCESS: $success_count"
echo "FAILURE: $failure_count"

if [[ $total_count -gt 0 ]]; then
    success_rate=$(( success_count * 100 / total_count ))
    echo "Success rate: ${success_rate}%"
fi

# Print breakdown by category
echo ""
echo "=== Breakdown by Category ==="
for category_dir in "$RESULTS_DIR"/*/; do
    [[ ! -d "$category_dir" ]] && continue
    
    category=$(basename "$category_dir")
    cat_success=0
    cat_failure=0
    cat_total=0
    
    while IFS= read -r -d '' log_file; do
        (( cat_total++ )) || true
        
        if [[ ! -s "$log_file" ]]; then
            (( cat_failure++ )) || true
        elif grep -q "Aborted\|Assertion.*failed\|core dumped\|\t FAILURE :" "$log_file" 2>/dev/null; then
            (( cat_failure++ )) || true
        else
            (( cat_success++ )) || true
        fi
    done < <(find "$category_dir" -type f -name "*.log" -print0 2>/dev/null)
    
    if [[ $cat_total -gt 0 ]]; then
        echo "$category: SUCCESS=$cat_success, FAILURE=$cat_failure, Total=$cat_total"
    fi
done
