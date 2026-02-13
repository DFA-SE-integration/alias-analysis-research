#!/usr/bin/env bash
set -euo pipefail

# Script to count SUCCESS and FAILURE results from tool analysis
# Scans all subdirectories in results/$1 and counts statistics for each

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BASE_RES_DIR="$ROOT/results/$1"

if [[ ! -d "$BASE_RES_DIR" ]]; then
    echo "ERROR: Results directory not found at $BASE_RES_DIR"
    exit 1
fi

# Overall statistics
overall_success=0
overall_failure=0
overall_total=0

# Process each subdirectory in results/$1
while IFS= read -r -d '' RESULTS_DIR; do
    [[ ! -d "$RESULTS_DIR" ]] && continue
    
    tool_name=$(basename "$RESULTS_DIR")
    
    success_count=0
    failure_count=0
    total_count=0
    
    # Process all .log files in this subdirectory
    while IFS= read -r -d '' log_file; do
        (( total_count++ )) || true
        
        # Check if file is empty
        if [[ ! -s "$log_file" ]]; then
            (( failure_count++ )) || true
            continue
        fi
        
        # Check for failure indicators
        if grep -qE "(Aborted|Assertion.*failed|core dumped|FAILURE :)" "$log_file" 2>/dev/null; then
            (( failure_count++ )) || true
        else
            (( success_count++ )) || true
        fi
    done < <(find "$RESULTS_DIR" -type f -name "*.log" -print0 2>/dev/null | sort -z)
    
    # Update overall statistics
    (( overall_success += success_count )) || true
    (( overall_failure += failure_count )) || true
    (( overall_total += total_count )) || true
    
    # Print summary for this tool
    echo "=== $tool_name Test-Suite Results Summary ==="
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
            elif grep -qE "(Aborted|Assertion.*failed|core dumped|FAILURE :)" "$log_file" 2>/dev/null; then
                (( cat_failure++ )) || true
            else
                (( cat_success++ )) || true
            fi
        done < <(find "$category_dir" -type f -name "*.log" -print0 2>/dev/null)
        
        if [[ $cat_total -gt 0 ]]; then
            echo "$category: SUCCESS=$cat_success, FAILURE=$cat_failure, Total=$cat_total"
        fi
    done
    
    echo ""
    echo "---"
    echo ""
    
done < <(find "$BASE_RES_DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)

# Print overall summary
echo "=== Overall Summary for $1 ==="
echo "Total files processed: $overall_total"
echo "SUCCESS: $overall_success"
echo "FAILURE: $overall_failure"

if [[ $overall_total -gt 0 ]]; then
    overall_rate=$(( overall_success * 100 / overall_total ))
    echo "Success rate: ${overall_rate}%"
fi
