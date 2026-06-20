import re
import os
import subprocess

def is_word_boundary_start(code, pos):
    if pos == 0:
        return True
    char = code[pos - 1]
    if char.isalpha() or char == '_':
        return False
    return True

def is_word_boundary_end(code, pos, length):
    if pos + length == len(code):
        return True
    char = code[pos + length]
    if char.isalnum() or char == '_':
        return False
    return True

def replace_if_do_with_then(code):
    chunks = []
    last_pos = 0
    pos = 0
    n = len(code)
    
    state = 'NONE'
    
    while pos < n:
        # Skip strings
        if code[pos] in ('"', "'"):
            quote = code[pos]
            pos += 1
            while pos < n and code[pos] != quote:
                if code[pos] == '\\':
                    pos += 2
                else:
                    pos += 1
            pos += 1 # skip closing quote
            continue
            
        # Skip comments
        if pos + 1 < n and code[pos:pos+2] == '--':
            pos += 2
            while pos < n and code[pos] != '\n':
                pos += 1
            continue
            
        # Check '?' print shortcut and replace with 'print(args)' wrapped in parens with guaranteed spaces
        if code[pos] == '?':
            chunks.append(code[last_pos:pos])
            eol = code.find('\n', pos)
            if eol == -1:
                eol = n
            args = code[pos+1:eol].strip()
            chunks.append(f" print({args}) ")
            pos = eol
            last_pos = pos
            continue
            
        # Check keywords with proper word boundaries
        found_kw = False
        for kw, length, target_state in [('if', 2, 'IF'), ('elseif', 6, 'IF'), ('for', 3, 'LOOP'), ('while', 5, 'LOOP')]:
            if pos + length <= n and code[pos:pos+length] == kw:
                if is_word_boundary_start(code, pos) and is_word_boundary_end(code, pos, length):
                    state = target_state
                    chunks.append(code[last_pos:pos + length])
                    pos += length
                    last_pos = pos
                    found_kw = True
                    break
        if found_kw:
            continue
            
        # Check 'do'
        if pos + 2 <= n and code[pos:pos+2] == 'do':
            if is_word_boundary_start(code, pos) and is_word_boundary_end(code, pos, 2):
                if state == 'IF':
                    chunks.append(code[last_pos:pos])
                    chunks.append('then')
                    pos += 2
                    last_pos = pos
                    state = 'NONE'
                elif state == 'LOOP':
                    chunks.append(code[last_pos:pos + 2])
                    pos += 2
                    last_pos = pos
                    state = 'NONE'
                else:
                    chunks.append(code[last_pos:pos + 2])
                    pos += 2
                    last_pos = pos
                continue
                
        # Check 'then'
        if pos + 4 <= n and code[pos:pos+4] == 'then':
            if is_word_boundary_start(code, pos) and is_word_boundary_end(code, pos, 4):
                if state == 'IF':
                    state = 'NONE'
                chunks.append(code[last_pos:pos + 4])
                pos += 4
                last_pos = pos
                continue
                
        pos += 1
                
    chunks.append(code[last_pos:])
    return "".join(chunks)

def fix_digit_critical_keywords(code):
    # Match strings, comments, or number literals followed by 'function' or 'local'
    pattern = re.compile(
        r'("(?:\\.|[^"])*"|\'(?:\\.|[^\'])*\'|--[^\n]*)'
        r'|'
        r'(\b0[xX][0-9a-fA-F]+|\b0[bB][01]+|\b\d+\.\d*(?:[eE][+-]?\d+)?|\b\.\d+(?:[eE][+-]?\d+)?|\b\d+(?:[eE][+-]?\d+)?)(?=(?:function|local)\b)'
    )
    
    def replace_func(match):
        if match.group(1):
            return match.group(1)
        elif match.group(2):
            return match.group(2) + " "
        return match.group(0)

    return pattern.sub(replace_func, code)

def convert_pico8_to_standard_lua(lua_text):
    lines = lua_text.splitlines()
    converted_lines = []
    
    for line in lines:
        if line.strip().startswith("--") or not line.strip():
            converted_lines.append(line)
            continue

        # 1. Expand self-assignment operators safely on formatted code
        line = re.sub(r"([a-zA-Z0-9_\.\[\]'\"]+)\s*\+=\s*(.+)", r"\1 = \1 + (\2)", line)
        line = re.sub(r"([a-zA-Z0-9_\.\[\]'\"]+)\s*-=\s*(.+)", r"\1 = \1 - (\2)", line)
        line = re.sub(r"([a-zA-Z0-9_\.\[\]'\"]+)\s*\*=\s*(.+)", r"\1 = \1 * (\2)", line)
        line = re.sub(r"([a-zA-Z0-9_\.\[\]'\"]+)\s*/=\s*(.+)", r"\1 = \1 / (\2)", line)
        line = re.sub(r"([a-zA-Z0-9_\.\[\]'\"]+)\s*%=\s*(.+)", r"\1 = \1 % (\2)", line)

        # 2. One-line if statement: if (cond) stmt ➔ if (cond) then stmt end
        if "if" in line and "then" not in line:
            match = re.match(r"^(\s*if\s*\(.+?\))\s*(.+)$", line)
            if match:
                cond_part, action_part = match.group(1), match.group(2)
                if not action_part.strip().endswith("end") and not action_part.strip().endswith("then"):
                    line = f"{cond_part} then {action_part} end"

        # 3. != to ~=
        line = line.replace("!=", "~=")

        # 4. for var in all(tbl) do -> for _i_var=1,#tbl do local var=tbl[_i_var]
        line = re.sub(
            r"\bfor\s+([a-zA-Z0-9_]+)\s+in\s+all\(([a-zA-Z0-9_\.\[\]'\"]+)\)\s+do",
            r"for _i_\1=1,#\2 do local \1=\2[_i_\1]",
            line
        )

        converted_lines.append(line)
        
    return "\n".join(converted_lines)

def run_pipeline():
    in_p8 = "g:/PC8/pegball-3.p8"
    std_p8 = "g:/PC8/pegball-3_std.p8"
    min_p8 = "g:/PC8/pegball-3m.p8"
    out_pc8c = "g:/PC8/pegball-3m.pc8c"
    
    print(f"1. Reading {in_p8} and transpiling BEFORE minification...")
    with open(in_p8, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
        
    lua_match = re.search(r'(__lua__\n)(.*?)(\n__(?:gfx|gff|map|sfx|music|label)__|$)', content, re.DOTALL)
    if not lua_match:
        print("Error: No lua section found in input.")
        return
        
    lua_code = lua_match.group(2) # Original casing
    
    # Replace PICO-8 glyphs with standard button numbers
    # O (🅾️) = 4, X (❎) = 5
    # Left = 0, Right = 1, Up = 2, Down = 3
    lua_code = lua_code.replace('\u2b05\ufe0f', '0').replace('\u2b05', '0') # Left
    lua_code = lua_code.replace('\u27a1\ufe0f', '1').replace('\u27a1', '1') # Right
    lua_code = lua_code.replace('\u2b06\ufe0f', '2').replace('\u2b06', '2') # Up
    lua_code = lua_code.replace('\u2b07\ufe0f', '3').replace('\u2b07', '3') # Down
    lua_code = lua_code.replace('\U0001f17e\ufe0f', '4').replace('\U0001f17e', '4') # O
    lua_code = lua_code.replace('\u274e', '5') # X


    
    lua_code = lua_code.lower() # Lowercase PICO-8 standard
    lua_std = convert_pico8_to_standard_lua(lua_code)
    
    # Reassemble transpiled cart and force version 8 to prevent shrinko8 from converting then to do
    std_content = content[:lua_match.start(2)] + lua_std + content[lua_match.end(2):]
    std_content = std_content.replace("version 42", "version 8")
    with open(std_p8, "w", encoding="utf-8", newline="\n") as f:
        f.write(std_content)

    print(f"   Saved transpiled intermediate cart to {std_p8}")
    
    print(f"2. Minifying {std_p8} with shrinko8...")
    subprocess.run([
        "python", "g:/PC8/tools/shrinko8/shrinko8.py",
        std_p8, min_p8,
        "--minify",
        "--no-minify-reorder",
        "--rename-map", "g:/PC8/scratch/rename_map.txt"
    ], check=True)

    print(f"   Saved minified cart to {min_p8}")
    
    print("3. Replacing PICO-8 shortcuts (?, if-do) in minified output...")
    with open(min_p8, "r", encoding="utf-8", errors="ignore") as f:
        min_content = f.read()
        
    min_lua_match = re.search(r'(__lua__\n)(.*?)(\n__(?:gfx|gff|map|sfx|music|label)__|$)', min_content, re.DOTALL)
    if not min_lua_match:
        print("Error: No lua section found in minified output.")
        return
        
    min_lua_code = min_lua_match.group(2)
    final_std_lua = min_lua_code
    final_std_lua = fix_digit_critical_keywords(final_std_lua)

    
    # Hybrid Localization: Only localize the top 50 most frequent globals.
    # This prevents the coroutine stack from blowing up (5KB OOM) while keeping the global table _G 
    # under 128 elements, avoiding the 10KB hash table resize OOM.
    rename_map_path = "g:/PC8/scratch/rename_map.txt"
    if os.path.exists(rename_map_path):
        print("   Analyzing global variable usage frequencies...")
        global_names = []
        with open(rename_map_path, "r", encoding="utf-8") as fmap:
            for line in fmap:
                if line.startswith("global "):
                    parts = line.split()
                    if len(parts) >= 2:
                        name = parts[1]
                        if name not in ("_init", "_update", "_update60", "_draw"):
                            global_names.append(name)
        
        if global_names:
            # Count occurrences in final_std_lua
            name_counts = []
            for name in global_names:
                count = len(re.findall(r'\b' + re.escape(name) + r'\b', final_std_lua))
                name_counts.append((name, count))
            
            # Sort by frequency descending
            name_counts.sort(key=lambda x: x[1], reverse=True)
            
            # Localize top 110
            top_n = min(110, len(name_counts))
            local_globals = [name for name, _ in name_counts[:top_n]]
            
            local_decl = "local " + ",".join(local_globals) + "\n"
            final_std_lua = local_decl + final_std_lua
            print(f"   Successfully localized top {top_n} variables out of {len(global_names)} total globals.")
            
    # Reassemble final cart and strip variation selector \ufe0f
    final_content = min_content[:min_lua_match.start(2)] + final_std_lua + min_content[min_lua_match.end(2):]
    final_content = final_content.replace('\ufe0f', '')
    
    with open(min_p8, "w", encoding="utf-8", newline="\n") as f:
        f.write(final_content)
    print("   Successfully finalized Standard Lua conversion.")
    
    print("4. Compiling via pc8_compile.exe...")
    subprocess.run([
        "g:/PC8/tools/pc8_compile.exe", "game",
        min_p8, out_pc8c
    ], check=True)
    print(f"Success! Final minified and transpiled PC8C saved to {out_pc8c}")
    
    # Clean up standard intermediate file
    if os.path.exists(std_p8):
        os.remove(std_p8)



if __name__ == "__main__":
    run_pipeline()
