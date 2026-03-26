import sys
import os
import re

def parse_scalability_log(file_path):
    status = "NO_LOG"
    wall_ms = None
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        m = re.search(r'^SCALABILITY_STATUS:\s*(\S+)', content, re.MULTILINE)
        if m:
            status = m.group(1)
        m = re.search(r'^SCALABILITY_WALL_MS:\s*(\d+)', content, re.MULTILINE)
        if m:
            wall_ms = int(m.group(1))
    except Exception:
        pass
    return status, wall_ms

if len(sys.argv) < 2:
    print("Usage: scalability_report.py <results/scalability dir>")
    sys.exit(1)

base = sys.argv[1]
if not os.path.isdir(base):
    print(f"Scalability results not found at {base}")
    sys.exit(0)

rows = []
for tool in sorted(os.listdir(base)):
    tool_path = os.path.join(base, tool)
    if not os.path.isdir(tool_path):
        continue
    for log_name in sorted(os.listdir(tool_path)):
        if not log_name.endswith('.log'):
            continue
        mode = log_name[:-4]
        log_path = os.path.join(tool_path, log_name)
        status, wall_ms = parse_scalability_log(log_path)
        rows.append((f"{tool}+{mode}", wall_ms, status))

header = f"{'Tool+Mode':<25} | {'Time(ms)':>8} | {'Status'}"
print(header)
print("-" * len(header))

timeout_modes = []
for name, wall_ms, status in rows:
    time_str = str(wall_ms) if wall_ms is not None else "—"
    print(f"{name:<25} | {time_str:>8} | {status}")
    if "TIMEOUT" in status or "OOM" in status:
        timeout_modes.append(name)

print()
if timeout_modes:
    print(f"Режимы, неприменимые для реальных проектов (превысили таймаут/OOM): {', '.join(timeout_modes)}")
else:
    print("Все режимы завершились в пределах таймаута.")
