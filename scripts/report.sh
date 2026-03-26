#!/usr/bin/env bash
set -euo pipefail

source "scripts/globals.sh"

python3 "$ROOT/scripts/report.py" $RESULTS_TSUITE
python3 "$ROOT/scripts/scalability_report.py" "$RESULTS_SCALABILITY"

# Script to count TP/TN/FP/FN from tool alias validation (MUSTALIAS/NOALIAS checks)
# TP = MUSTALIAS confirmed, TN = NOALIAS confirmed, FP = NOALIAS failed, FN = MUSTALIAS failed

# ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# BASE_RES_DIR="$ROOT/results/$1"

# # Count TP, TN, FP, FN in a log file (from "SUCCESS : MUSTALIAS", "FAILURE : NOALIAS", etc.)
# # Output: "TP TN FP FN" (space-separated)
# count_tp_tn_fp_fn() {
#     local log_file="$1"
#     local tp=0 tn=0 fp=0 fn=0
#     [[ ! -f "$log_file" ]] && echo "0 0 0 0" && return
#     tp=$(grep -E "SUCCESS.*MUSTALIAS|MUSTALIAS.*SUCCESS" "$log_file" 2>/dev/null | wc -l | tr -d ' ')
#     tn=$(grep -E "SUCCESS.*NOALIAS|NOALIAS.*SUCCESS" "$log_file" 2>/dev/null | wc -l | tr -d ' ')
#     fp=$(grep -E "FAILURE.*NOALIAS|NOALIAS.*FAILURE" "$log_file" 2>/dev/null | wc -l | tr -d ' ')
#     fn=$(grep -E "FAILURE.*MUSTALIAS|MUSTALIAS.*FAILURE" "$log_file" 2>/dev/null | wc -l | tr -d ' ')
#     echo "$tp $tn $fp $fn"
# }

# # Format TP, TN, FP, FN as percentages of total (TP+TN+FP+FN). Output: "TP=X%, TN=Y%, FP=Z%, FN=W%"
# format_tp_tn_fp_fn_pct() {
#     local tp="$1" tn="$2" fp="$3" fn="$4"
#     local total=$(( tp + tn + fp + fn ))
#     if [[ $total -eq 0 ]]; then
#         echo "TP=0%, TN=0%, FP=0%, FN=0%"
#         return
#     fi
#     awk "BEGIN {printf \"TP=%.0f%%, TN=%.0f%%, FP=%.0f%%, FN=%.0f%%\", 100*$tp/$total, 100*$tn/$total, 100*$fp/$total, 100*$fn/$total}"
# }

# # Function to extract execution time from log file
# # Returns time in seconds, or 0 if not found
# extract_time() {
#     local log_file="$1"
#     local time=""
    
#     # For SVF: extract TotalTime from "Andersen Pointer Analysis Stats" section
#     if grep -q "Andersen Pointer Analysis Stats" "$log_file" 2>/dev/null; then
#         time=$(grep -A 20 "Andersen Pointer Analysis Stats" "$log_file" 2>/dev/null | grep "^TotalTime" | head -1 | awk '{print $2}')
#         if [[ -n "$time" ]] && [[ "$time" != "0" ]]; then
#             echo "$time"
#             return 0
#         fi
#     fi
    
#     # For SVF: try to find TotalTime in other sections (take first non-zero value)
#     time=$(grep "^TotalTime" "$log_file" 2>/dev/null | awk '{print $2}' | grep -v "^0$" | head -1)
#     if [[ -n "$time" ]]; then
#         echo "$time"
#         return 0
#     fi
    
#     # For Phasar: extract Elapsed time (format: Elapsed: 00:00:00:000779)
#     if grep -q "^Elapsed:" "$log_file" 2>/dev/null; then
#         local elapsed_line=$(grep "^Elapsed:" "$log_file" 2>/dev/null | head -1)
#         # Extract microseconds (last part after last colon)
#         local microseconds=$(echo "$elapsed_line" | awk -F: '{print $NF}')
#         if [[ -n "$microseconds" ]]; then
#             # Convert microseconds to seconds
#             time=$(awk "BEGIN {printf \"%.6f\", $microseconds / 1000000}")
#             if [[ -n "$time" ]] && [[ "$time" != "0" ]]; then
#                 echo "$time"
#                 return 0
#             fi
#         fi
#     fi
    
#     # For Sea-DSA: extract ExecutionTime (format: ExecutionTime: 0.123456)
#     if grep -q "^ExecutionTime:" "$log_file" 2>/dev/null; then
#         time=$(grep "^ExecutionTime:" "$log_file" 2>/dev/null | head -1 | awk '{print $2}')
#         if [[ -n "$time" ]] && [[ "$time" != "0" ]] && [[ "$time" != "0.0" ]]; then
#             echo "$time"
#             return 0
#         fi
#     fi
    
#     # For Phasar/Sea-DSA: try to find time in various formats
#     # Look for patterns like "Time: X", "time: X", "Total time: X", etc.
#     time=$(grep -iE "(total.*time|execution.*time|analysis.*time)" "$log_file" 2>/dev/null | grep -oE "[0-9]+\.[0-9]+" | head -1)
#     if [[ -n "$time" ]]; then
#         echo "$time"
#         return 0
#     fi
    
#     # If no time found, return 0
#     echo "0"
# }

# if [[ ! -d "$BASE_RES_DIR" ]]; then
#     echo "ERROR: Results directory not found at $BASE_RES_DIR"
#     exit 1
# fi

# # Process each subdirectory in results/$1
# while IFS= read -r -d '' RESULTS_DIR; do
#     [[ ! -d "$RESULTS_DIR" ]] && continue
    
#     tool_name=$(basename "$RESULTS_DIR")
    
#     # Special handling for Phasar, Sea-DSA, and SVF (two-level structure)
#     # Phasar: Phasar/cflanders/context, Phasar/cflsteens/context
#     # Sea-DSA: Sea-DSA/bu/context, Sea-DSA/butd-cs/context, ...
#     # SVF: SVF/ander/context, SVF/fspta/context, SVF/vfspta/context, SVF/cxt/context
#     if [[ "$tool_name" == "Phasar" ]] || [[ "$tool_name" == "Sea-DSA" ]] || [[ "$tool_name" == "SVF" ]]; then
#         # Process each analysis type (cflanders/cflsteens for Phasar, bu/butd-cs/cs/ci/flat for Sea-DSA)
#         for analysis_dir in "$RESULTS_DIR"/*/; do
#             [[ ! -d "$analysis_dir" ]] && continue
            
#             analysis_name=$(basename "$analysis_dir")
#             analysis_tp=0
#             analysis_tn=0
#             analysis_fp=0
#             analysis_fn=0
#             analysis_total=0
#             analysis_total_time=0
#             analysis_time_count=0
            
#             # Aggregate TP/TN/FP/FN and time over all .log files for this analysis type
#             while IFS= read -r -d '' log_file; do
#                 (( analysis_total++ )) || true
#                 read -r tp tn fp fn <<< "$(count_tp_tn_fp_fn "$log_file")"
#                 analysis_tp=$(( analysis_tp + tp ))
#                 analysis_tn=$(( analysis_tn + tn ))
#                 analysis_fp=$(( analysis_fp + fp ))
#                 analysis_fn=$(( analysis_fn + fn ))
#                 file_time=$(extract_time "$log_file")
#                 if [[ -n "$file_time" ]] && [[ "$file_time" != "0" ]] && [[ "$file_time" != "0.0" ]]; then
#                     analysis_total_time=$(awk "BEGIN {print $analysis_total_time + $file_time}")
#                     (( analysis_time_count++ )) || true
#                 fi
#             done < <(find "$analysis_dir" -type f -name "*.log" -print0 2>/dev/null | sort -z)
            
#             if [[ "$tool_name" == "Sea-DSA" ]]; then
#                 echo "=== Sea-DSA $analysis_name $1 Results Summary ==="
#             elif [[ "$tool_name" == "SVF" ]]; then
#                 echo "=== SVF $analysis_name $1 Results Summary ==="
#             else
#                 echo "=== $analysis_name $1 Results Summary ==="
#             fi
#             echo "Total files processed: $analysis_total"
#             echo "$(format_tp_tn_fp_fn_pct "$analysis_tp" "$analysis_tn" "$analysis_fp" "$analysis_fn")"
#             if [[ $analysis_time_count -gt 0 ]] && [[ "$analysis_total_time" != "0" ]]; then
#                 total_time_formatted=$(awk "BEGIN {printf \"%.3f\", $analysis_total_time}")
#                 echo "Total execution time: ${total_time_formatted}s"
#             else
#                 echo "Total execution time: N/A"
#             fi
            
#             echo ""
#             echo "=== Breakdown by Category ==="
#             for category_dir in "$analysis_dir"/*/; do
#                 [[ ! -d "$category_dir" ]] && continue
#                 category=$(basename "$category_dir")
#                 cat_tp=0
#                 cat_tn=0
#                 cat_fp=0
#                 cat_fn=0
#                 while IFS= read -r -d '' log_file; do
#                     read -r tp tn fp fn <<< "$(count_tp_tn_fp_fn "$log_file")"
#                     cat_tp=$(( cat_tp + tp ))
#                     cat_tn=$(( cat_tn + tn ))
#                     cat_fp=$(( cat_fp + fp ))
#                     cat_fn=$(( cat_fn + fn ))
#                 done < <(find "$category_dir" -type f -name "*.log" -print0 2>/dev/null)
#                 echo "$category: $(format_tp_tn_fp_fn_pct "$cat_tp" "$cat_tn" "$cat_fp" "$cat_fn")"
#             done
            
#             echo ""
#             echo "---"
#             echo ""
#         done
#     else
#         # Standard handling for other tools (single-level dirs)
#         total_tp=0
#         total_tn=0
#         total_fp=0
#         total_fn=0
#         total_count=0
#         total_time=0
#         time_count=0
        
#         while IFS= read -r -d '' log_file; do
#             (( total_count++ )) || true
#             read -r tp tn fp fn <<< "$(count_tp_tn_fp_fn "$log_file")"
#             total_tp=$(( total_tp + tp ))
#             total_tn=$(( total_tn + tn ))
#             total_fp=$(( total_fp + fp ))
#             total_fn=$(( total_fn + fn ))
#             file_time=$(extract_time "$log_file")
#             if [[ -n "$file_time" ]] && [[ "$file_time" != "0" ]] && [[ "$file_time" != "0.0" ]]; then
#                 total_time=$(awk "BEGIN {print $total_time + $file_time}")
#                 (( time_count++ )) || true
#             fi
#         done < <(find "$RESULTS_DIR" -type f -name "*.log" -print0 2>/dev/null | sort -z)
        
#         echo "=== $tool_name $1 Results Summary ==="
#         echo "Total files processed: $total_count"
#         echo "$(format_tp_tn_fp_fn_pct "$total_tp" "$total_tn" "$total_fp" "$total_fn")"
#         if [[ $time_count -gt 0 ]] && [[ "$total_time" != "0" ]]; then
#             total_time_formatted=$(awk "BEGIN {printf \"%.3f\", $total_time}")
#             echo "Total execution time: ${total_time_formatted}s"
#         else
#             echo "Total execution time: N/A"
#         fi
        
#         echo ""
#         echo "=== Breakdown by Category ==="
#         for category_dir in "$RESULTS_DIR"/*/; do
#             [[ ! -d "$category_dir" ]] && continue
#             category=$(basename "$category_dir")
#             cat_tp=0
#             cat_tn=0
#             cat_fp=0
#             cat_fn=0
#             while IFS= read -r -d '' log_file; do
#                 read -r tp tn fp fn <<< "$(count_tp_tn_fp_fn "$log_file")"
#                 cat_tp=$(( cat_tp + tp ))
#                 cat_tn=$(( cat_tn + tn ))
#                 cat_fp=$(( cat_fp + fp ))
#                 cat_fn=$(( cat_fn + fn ))
#             done < <(find "$category_dir" -type f -name "*.log" -print0 2>/dev/null)
#             echo "$category: $(format_tp_tn_fp_fn_pct "$cat_tp" "$cat_tn" "$cat_fp" "$cat_fn")"
#         done
        
#         echo ""
#         echo "---"
#         echo ""
#     fi
    
# done < <(find "$BASE_RES_DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
