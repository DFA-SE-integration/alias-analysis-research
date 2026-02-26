import sys
import os
import re

def extract_time_from_log(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception:
        return 0.0

    total_sec = 0.0

    # SVF: TotalTime (seconds). Sum all non-zero values.
    for m in re.finditer(r'^TotalTime\s+([0-9.]+)', content, re.MULTILINE):
        val = float(m.group(1))
        if val > 0:
            total_sec += val
    if total_sec > 0:
        return total_sec

    # Phasar / Sea-DSA: Elapsed: HH:MM:SS:microseconds
    m = re.search(r'^Elapsed:\s*(\d+):(\d+):(\d+):(\d+)\s*$', content, re.MULTILINE)
    if m:
        h, m_i, s, us = int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4))
        return (h * 3600 + m_i * 60 + s) + us / 1_000_000

    # Fallback: ExecutionTime or similar
    m = re.search(r'(?:ExecutionTime|total\s*time|execution\s*time)\s*[:=]\s*([0-9.]+)', content, re.IGNORECASE)
    if m:
        return float(m.group(1))

    # assert (True)
    # print(f"{file_path}")
    # assert (False)
    return 0.0

def parse_result(file_path):
    tn_pattern = re.compile(r"SUCCESS.*NOALIAS")
    tp_pattern = re.compile(r"SUCCESS.*MUSTALIAS")
    fn_pattern = re.compile(r"FAILURE.*MUSTALIAS")
    fp_pattern = re.compile(r"FAILURE.*NOALIAS")
    
    counts = [0, 0, 0, 0] # TN, TP, FN, FP
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            counts[0] = len(tn_pattern.findall(content))
            counts[1] = len(tp_pattern.findall(content))
            counts[2] = len(fn_pattern.findall(content))
            counts[3] = len(fp_pattern.findall(content))
    except Exception as e:
        print(f"Ошибка: {e}")
    return counts

def calculate_metrics(tn, tp, fn, fp):
    accuracy = (tp + tn) / (tp + tn + fp + fn) if (tp + tn + fp + fn) > 0 else 0
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0
    f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
    return accuracy, precision, recall, f1

if len(sys.argv) > 1:
    test_res_dir_path = sys.argv[1]
    header = f"{'Tool+Mode':<25} | {'Time(ms)':>8} | {'TP':>4} | {'TN':>4} | {'FP':>4} | {'FN':>4} | {'Acc':>5} | {'Prc':>5} | {'Rec':>5} | {'F1':>5}"
    print(header)
    print("-" * len(header))

    for tool in os.listdir(test_res_dir_path):
        tool_path = os.path.join(test_res_dir_path, tool)
        if not os.path.isdir(tool_path): continue
        
        for mode in os.listdir(tool_path):
            mode_path = os.path.join(tool_path, mode)
            if not os.path.isdir(mode_path): continue
            
            tn_s, tp_s, fn_s, fp_s = 0, 0, 0, 0
            total_time_sec = 0.0

            for root, dirs, files in os.walk(mode_path):
                for res in files:
                    file_path = os.path.join(root, res)
                    tn, tp, fn, fp = parse_result(file_path)
                    tn_s += tn; tp_s += tp; fn_s += fn; fp_s += fp
                    total_time_sec += extract_time_from_log(file_path)

            elapsed_ms = int(total_time_sec * 1000)
            acc, prc, rec, f1 = calculate_metrics(tn_s, tp_s, fn_s, fp_s)
            
            name = f"{tool}+{mode}"
            print(f"{name:<25} | {elapsed_ms:>8} | {tp_s:>4} | {tn_s:>4} | {fp_s:>4} | {fn_s:>4} | {acc:>5.2f} | {prc:>5.2f} | {rec:>5.2f} | {f1:>5.2f}")
else:
    print("Set results path")
