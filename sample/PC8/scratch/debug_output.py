import sys

with open("g:/PC8/pegball-3m.p8", "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

lua_part = content.split("__lua__\n")[1].split("__gfx__")[0]
lines = lua_part.splitlines()

# Print last 30 lines
start_idx = max(0, len(lines) - 30)
for i in range(start_idx, len(lines)):
    line = lines[i]
    ascii_line = line.encode("ascii", "ignore").decode("ascii")
    print(f"L{i+1}: {ascii_line}")
