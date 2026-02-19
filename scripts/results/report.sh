#!/usr/bin/env bash
set -euo pipefail

# Script to count SUCCESS and FAILURE results from tool analysis
# Scans all subdirectories in results/$1 and counts statistics for each

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BASE_RES_DIR="$ROOT/results/$1"

# Function to extract execution time from log file
# Returns time in seconds, or 0 if not found
extract_time() {
    local log_file="$1"
    local time=""
    
    # For SVF: extract TotalTime from "Andersen Pointer Analysis Stats" section
    if grep -q "Andersen Pointer Analysis Stats" "$log_file" 2>/dev/null; then
        time=$(grep -A 20 "Andersen Pointer Analysis Stats" "$log_file" 2>/dev/null | grep "^TotalTime" | head -1 | awk '{print $2}')
        if [[ -n "$time" ]] && [[ "$time" != "0" ]]; then
            echo "$time"
            return 0
        fi
    fi
    
    # For SVF: try to find TotalTime in other sections (take first non-zero value)
    time=$(grep "^TotalTime" "$log_file" 2>/dev/null | awk '{print $2}' | grep -v "^0$" | head -1)
    if [[ -n "$time" ]]; then
        echo "$time"
        return 0
    fi
    
    # For Phasar: extract Elapsed time (format: Elapsed: 00:00:00:000779)
    if grep -q "^Elapsed:" "$log_file" 2>/dev/null; then
        local elapsed_line=$(grep "^Elapsed:" "$log_file" 2>/dev/null | head -1)
        # Extract microseconds (last part after last colon)
        local microseconds=$(echo "$elapsed_line" | awk -F: '{print $NF}')
        if [[ -n "$microseconds" ]]; then
            # Convert microseconds to seconds
            time=$(awk "BEGIN {printf \"%.6f\", $microseconds / 1000000}")
            if [[ -n "$time" ]] && [[ "$time" != "0" ]]; then
                echo "$time"
                return 0
            fi
        fi
    fi
    
    # For Sea-DSA: extract ExecutionTime (format: ExecutionTime: 0.123456)
    if grep -q "^ExecutionTime:" "$log_file" 2>/dev/null; then
        time=$(grep "^ExecutionTime:" "$log_file" 2>/dev/null | head -1 | awk '{print $2}')
        if [[ -n "$time" ]] && [[ "$time" != "0" ]] && [[ "$time" != "0.0" ]]; then
            echo "$time"
            return 0
        fi
    fi
    
    # For Phasar/Sea-DSA: try to find time in various formats
    # Look for patterns like "Time: X", "time: X", "Total time: X", etc.
    time=$(grep -iE "(total.*time|execution.*time|analysis.*time)" "$log_file" 2>/dev/null | grep -oE "[0-9]+\.[0-9]+" | head -1)
    if [[ -n "$time" ]]; then
        echo "$time"
        return 0
    fi
    
    # If no time found, return 0
    echo "0"
}

if [[ ! -d "$BASE_RES_DIR" ]]; then
    echo "ERROR: Results directory not found at $BASE_RES_DIR"
    exit 1
fi

# Process each subdirectory in results/$1
while IFS= read -r -d '' RESULTS_DIR; do
    [[ ! -d "$RESULTS_DIR" ]] && continue
    
    tool_name=$(basename "$RESULTS_DIR")
    
    # Special handling for Phasar and Sea-DSA (two-level structure)
    # Phasar: Phasar/cflanders/context, Phasar/cflsteens/context
    # Sea-DSA: Sea-DSA/bu/context, Sea-DSA/butd-cs/context, Sea-DSA/cs/context, Sea-DSA/ci/context, Sea-DSA/flat/context
    if [[ "$tool_name" == "Phasar" ]] || [[ "$tool_name" == "Sea-DSA" ]]; then
        # Process each analysis type (cflanders/cflsteens for Phasar, bu/butd-cs/cs/ci/flat for Sea-DSA)
        for analysis_dir in "$RESULTS_DIR"/*/; do
            [[ ! -d "$analysis_dir" ]] && continue
            
            analysis_name=$(basename "$analysis_dir")
            analysis_success=0
            analysis_failure=0
            analysis_total=0
            analysis_total_time=0
            analysis_time_count=0
            
            # Count all .log files for this analysis type and calculate total time
            while IFS= read -r -d '' log_file; do
                (( analysis_total++ )) || true
                
                if [[ ! -s "$log_file" ]]; then
                    (( analysis_failure++ )) || true
                elif grep -qE "(Aborted|Assertion.*failed|core dumped|FAILURE :)" "$log_file" 2>/dev/null; then
                    (( analysis_failure++ )) || true
                else
                    (( analysis_success++ )) || true
                fi
                
                # Extract time from log file for total time calculation
                file_time=$(extract_time "$log_file")
                if [[ -n "$file_time" ]] && [[ "$file_time" != "0" ]] && [[ "$file_time" != "0.0" ]]; then
                    analysis_total_time=$(awk "BEGIN {print $analysis_total_time + $file_time}")
                    (( analysis_time_count++ )) || true
                fi
            done < <(find "$analysis_dir" -type f -name "*.log" -print0 2>/dev/null | sort -z)
            
            # Print summary for this analysis type
            # For Sea-DSA, prefix with tool name
            if [[ "$tool_name" == "Sea-DSA" ]]; then
                echo "=== Sea-DSA $analysis_name Test-Suite Results Summary ==="
            else
                echo "=== $analysis_name Test-Suite Results Summary ==="
            fi
            echo "Total files processed: $analysis_total"
            echo "SUCCESS: $analysis_success"
            echo "FAILURE: $analysis_failure"
            
            if [[ $analysis_total -gt 0 ]]; then
                analysis_rate=$(( analysis_success * 100 / analysis_total ))
                echo "Success rate: ${analysis_rate}%"
            fi
            
            # Print total execution time
            if [[ $analysis_time_count -gt 0 ]] && [[ "$analysis_total_time" != "0" ]]; then
                total_time_formatted=$(awk "BEGIN {printf \"%.3f\", $analysis_total_time}")
                echo "Total execution time: ${total_time_formatted}s"
            else
                echo "Total execution time: N/A"
            fi
            
            # Print breakdown by category (context, flow, path+flow, etc.)
            echo ""
            echo "=== Breakdown by Category ==="
            for category_dir in "$analysis_dir"/*/; do
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
        done
    else
        # Standard handling for other tools (SVF, etc.)
        success_count=0
        failure_count=0
        total_count=0
        total_time=0
        time_count=0
        
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
            
            # Extract time from log file for total time calculation
            file_time=$(extract_time "$log_file")
            if [[ -n "$file_time" ]] && [[ "$file_time" != "0" ]] && [[ "$file_time" != "0.0" ]]; then
                total_time=$(awk "BEGIN {print $total_time + $file_time}")
                (( time_count++ )) || true
            fi
        done < <(find "$RESULTS_DIR" -type f -name "*.log" -print0 2>/dev/null | sort -z)
        
        # Print summary for this tool
        echo "=== $tool_name Test-Suite Results Summary ==="
        echo "Total files processed: $total_count"
        echo "SUCCESS: $success_count"
        echo "FAILURE: $failure_count"
        
        if [[ $total_count -gt 0 ]]; then
            success_rate=$(( success_count * 100 / total_count ))
            echo "Success rate: ${success_rate}%"
        fi
        
        # Print total execution time
        if [[ $time_count -gt 0 ]] && [[ "$total_time" != "0" ]]; then
            total_time_formatted=$(awk "BEGIN {printf \"%.3f\", $total_time}")
            echo "Total execution time: ${total_time_formatted}s"
        else
            echo "Total execution time: N/A"
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
    fi
    
done < <(find "$BASE_RES_DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
