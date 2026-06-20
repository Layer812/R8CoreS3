import re
import sys

def analyze(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # Get __lua__ section
    lua_match = re.search(r'__lua__\n(.*?)(\n__gfx__|\n__gff__|\n__map__|\n__sfx__|\n__music__|\n__label__|$)', content, re.DOTALL)
    if not lua_match:
        print("No lua section found.")
        return
    
    lua_code = lua_match.group(1)
    lines = lua_code.splitlines()
    print(f"Total Lua lines: {len(lines)}")
    print(f"Total Lua character count: {len(lua_code)}")

    # Count comments
    comment_lines = 0
    empty_lines = 0
    code_lines = 0
    comment_chars = 0
    
    for line in lines:
        stripped = line.strip()
        if not stripped:
            empty_lines += 1
        elif stripped.startswith("--"):
            comment_lines += 1
            comment_chars += len(line)
        else:
            code_lines += 1
            # Check for inline comment
            inline_idx = stripped.find("--")
            if inline_idx != -1:
                comment_chars += len(stripped) - inline_idx

    print(f"Empty lines: {empty_lines}")
    print(f"Comment lines: {comment_lines}")
    print(f"Code lines: {code_lines}")
    print(f"Approx comment chars: {comment_chars}")

    # Look for large table literals
    print("\n--- Large table literals or potential memory hogs ---")
    current_table = []
    in_table = False
    table_start_line = 0
    for idx, line in enumerate(lines):
        if '=' in line and '{' in line and not in_table:
            in_table = True
            table_start_line = idx + 1
            current_table.append(line)
        elif in_table:
            current_table.append(line)
            if '}' in line:
                in_table = False
                if len(current_table) > 10:
                    print(f"Table at line {table_start_line} to {idx+1} has {len(current_table)} lines. Start: {current_table[0].strip()}")
                current_table = []

if __name__ == "__main__":
    analyze("g:/PC8/pegball-3.p8")
