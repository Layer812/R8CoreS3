import re
import subprocess
import os

def fix_do_then(lua_code):
    # Replace 'if ... do' with 'if ... then'
    # Pattern 1: if (cond) do -> if (cond) then
    # Using a loop to handle nested/complex conditions safely
    # We look for 'if' followed by characters, ending with 'do', but we must ensure
    # it's not a 'while' or 'for'.
    # In minified code, 'if cond do' often appears.
    # Let's replace 'do' with 'then' when it immediately follows an if-condition.
    # An if-condition in Lua usually ends with a comparison, variable, or closing parenthesis.
    # For top4_min.lua, let's target specific invalid 'do' occurrences after 'if' or 'or'.
    
    # We can match 'if <cond> do' where <cond> doesn't contain 'then', 'do', 'while', 'for'.
    # A safe way is to find 'if' and the next 'do' before any 'end' or 'then'.
    # Let's write a parser-like regex or simple replacements.
    
    # Let's inspect the specific locations:
    # "if n==\"screen_to_ram\"or n==\"sprite_to_ram\"do" -> "then"
    # "if(n==\"sprite_to_ram\")e=0" (ends with then? no, this is PICO-8 syntax!)
    # Actually, shrinko8 compiled PICO-8 syntax like:
    # "if(cond)action" -> wait, in standard Lua this must be "if cond then action end"
    # If shrinko8 outputted standard Lua, why does it have "if(cond)n[d]=e"?
    # Ah! PICO-8's shorthand "if (cond) action" was NOT fully expanded by shrinko8 because of some issues,
    # or shrinko8 thought it's compiling for PICO-8.
    
    # Let's check if we can convert 'if' statements with 'do' to 'then'.
    # We replace 'do' with 'then' when it's part of an 'if' statement.
    # E.g., 'if ... do' -> 'if ... then'
    
    # We can use a regex that finds 'if' followed by anything up to 'do', 
    # making sure it doesn't cross 'then' or other control words.
    # We also do it for 'elseif ... do' -> 'elseif ... then'
    
    fixed = lua_code
    
    # Replace 'do' with 'then' in 'if/elseif ... do'
    # We search for 'if' or 'elseif' and find the matching 'do'
    # Since it's minified, it might be on the same line.
    # Let's do a few passes of regex replacement.
    fixed = re.sub(r'\b(if|elseif)\b(.*?)\bdo\b', lambda m: m.group(1) + m.group(2) + "then" if "then" not in m.group(2) and "for" not in m.group(2) and "while" not in m.group(2) else m.group(0), fixed)
    
    # Also PICO-8 short if: 'if (cond) action' is not standard Lua!
    # Lua 5.2 will fail on 'if (cond) action' (without then ... end).
    # Did shrinko8 emit 'if (cond) action'?
    # Let's look at top4_min.lua line 7:
    # "if(n=="sprite_to_ram")e=0"
    # Yes! It emitted 'if(cond) action'! This is definitely NOT standard Lua!
    # Why did shrinko8 emit PICO-8 shorthand in a .lua output?
    # Because shrinko8's --minify option minifies PICO-8 syntax, and even if output is .lua, 
    # it might still keep PICO-8 shorthands if it doesn't know it's standard Lua, 
    # or we need to pass '--std-lua' to shrinko8!
    # Wait! In the help output of shrinko8, there was no --std-lua, but maybe there is --std?
    # Let's check if we can pass a format or scripting option to convert to standard Lua.
    # Actually, we can just run shrinko8 to output a standard .p8 cart, and then use our pc8c.py logic to convert it!
    # Let's do that! That is much safer than regexing minified Lua.
    
    return fixed

def main():
    # Instead of wrapping .lua, let's run shrinko8 to generate a minified .p8 first
    # Command: python tools/shrinko8/shrinko8.py top4.p8 top4_min.p8 --minify
    # We read top4_min.p8, extract the LUA code, and run convert_pico8_to_standard_lua on it.
    
    # Let's import the conversion function from pc8c.py
    import sys
    sys.path.append('g:/PC8')
    from pc8c import convert_pico8_to_standard_lua
    
    # 1. Run shrinko8 with rename map export
    print("1. Minifying top4.p8 with shrinko8...")
    rename_map_path = "g:/PC8/scratch/rename_map_top4.txt"
    subprocess.run([
        "python", "g:/PC8/tools/shrinko8/shrinko8.py",
        "g:/PC8/top4.p8.bak", "g:/PC8/top4_min.p8",
        "--minify",
        "--no-minify-reorder",
        "--rename-map", rename_map_path
    ], check=True)
    
    with open('g:/PC8/top4_min.p8', 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        
    lua_match = re.search(r'__lua__(.*?)(?:__gfx__|__gff__|__map__|__sfx__|__mus__|__label__|$)', content, re.DOTALL)
    if not lua_match:
        print("No __lua__ section in top4_min.p8")
        return
        
    pico8_lua = lua_match.group(1)
    
    # Transpile PICO-8 shorthand Lua to standard Lua 5.2
    print("2. Transpiling PICO-8 shorthand in minified cart to standard Lua...")
    standard_lua = convert_pico8_to_standard_lua(pico8_lua)
    
    # Hybrid Localization: Only localize the top N most frequent globals.
    # This prevents the coroutine stack from blowing up while keeping the global table _G 
    # under 128 elements, avoiding the 10KB hash table resize OOM.
    if os.path.exists(rename_map_path):
        print("3. Analyzing global variable usage frequencies for localization...")
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
            name_counts = []
            for name in global_names:
                count = len(re.findall(r'\b' + re.escape(name) + r'\b', standard_lua))
                name_counts.append((name, count))
            
            name_counts.sort(key=lambda x: x[1], reverse=True)
            
            # Localize top 110 globals (or fewer if total globals is less)
            top_n = min(110, len(name_counts))
            local_globals = [name for name, _ in name_counts[:top_n]]
            
            local_decl = "local " + ",".join(local_globals) + "\n"
            standard_lua = local_decl + standard_lua
            print(f"   Successfully localized top {top_n} variables out of {len(global_names)} total globals.")
            
    # Rebuild top4_min_std.p8 with standard Lua
    header = "pico-8 cartridge\nversion 8\n__lua__\n"
    
    # Extract ROM sections
    sections = []
    for sec_name in ["__gfx__", "__map__", "__gff__", "__music__", "__mus__", "__sfx__", "__label__"]:
        idx = content.find(sec_name)
        if idx != -1:
            next_idx = content.find("__", idx + len(sec_name))
            if next_idx != -1:
                sections.append(content[idx:next_idx])
            else:
                sections.append(content[idx:])
                
    with open('g:/PC8/top4_min_std.p8', 'w', encoding='utf-8') as f:
        f.write(header)
        f.write(standard_lua)
        f.write("\n\n")
        f.write("\n".join(sections))
        
    print("Generated top4_min_std.p8!")
    
    # Compile top4_min_std.p8 to top4.pc8c (overwrite the final target!)
    import shutil
    shutil.copyfile('g:/PC8/top4_min_std.p8', 'g:/PC8/top4.p8')
    
    print("4. Compiling to top4.pc8c...")
    res = subprocess.run(
        ["tools\\pc8_compile.exe", "game", "top4.p8", "top4.pc8c"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    if os.path.exists('g:/PC8/top4.p8'):
        os.remove('g:/PC8/top4.p8')
        
    print("STDOUT:", res.stdout.decode('utf-8', errors='ignore'))
    print("STDERR:", res.stderr.decode('utf-8', errors='ignore'))

if __name__ == '__main__':
    main()
