import re

def main():
    with open('g:/PC8/top4.p8', 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Extract __lua__ section
    lua_match = re.search(r'__lua__(.*?)(?:__gfx__|__gff__|__map__|__sfx__|__mus__|__label__|$)', content, re.DOTALL)
    if not lua_match:
        print("No __lua__ section found")
        return
        
    lua_code = lua_match.group(1)
    
    # Strip string literals and comments
    code_clean = re.sub(r'"[^"\\]*(?:\\.[^"\\]*)*"', '""', lua_code)
    code_clean = re.sub(r"'[^'\\]*(?:\\.[^'\\]*)*'", "''", code_clean)
    code_clean = re.sub(r'--.*$', '', code_clean, flags=re.MULTILINE)
    
    all_identifiers = set(re.findall(r'\b[^\d\W]\w*\b', code_clean, re.UNICODE))
    
    local_vars = set()
    for match in re.finditer(r'\blocal\s+([a-zA-Z0-9_\s,]+)(?:=|\n|$)', code_clean):
        vars_str = match.group(1)
        for v in vars_str.split(','):
            v = v.strip()
            if v:
                local_vars.add(v)
                
    for match in re.finditer(r'\blocal\s+function\s+([^\s(]+)', code_clean):
        local_vars.add(match.group(1).strip())
        
    keywords = {
        "and", "break", "do", "else", "elseif", "end", "false", "for", "function",
        "if", "in", "local", "nil", "not", "or", "repeat", "return", "then",
        "true", "until", "while", "goto"
    }
    
    globals_used = all_identifiers - local_vars - keywords
    
    print("=== Globals used in top4.p8 ===")
    print("Total unique globals detected:", len(globals_used))
    
    pico8_apis = {
        "menuitem", "stat", "extcmd", "serial", "printh", "cartdata", "sub",
        "cocreate", "coresume", "costatus", "yield", "palt", "pal", "fillp",
        "clip", "camera", "color", "tline", "map", "mget", "mset", "fget",
        "fset", "sget", "sset", "pget", "pset", "peek", "poke", "peek2", "poke2",
        "peek4", "poke4", "memcpy", "memset", "reload", "cstore", "rnd", "srand",
        "flr", "ceil", "sgn", "abs", "min", "max", "mid", "cos", "sin", "atan2",
        "sqrt", "split", "add", "del", "all", "count", "foreach", "pairs", "ipairs",
        "type", "tostring", "tonumber", "assert", "next", "select", "print", "spr",
        "rectfill", "rect", "circfill", "circ", "line", "cls", "btn", "btnp", "sfx", "music",
        "sspr", "palt", "time", "t", "reboot", "stop"
    }
    
    detected_apis = globals_used & pico8_apis
    detected_custom = globals_used - pico8_apis
    
    print("\n[Detected PICO-8 APIs]")
    for api in sorted(list(detected_apis)):
        print(f"  {api}")
        
    print("\n[Detected Custom Globals (sorted, encoded to ASCII safe)]")
    for cg in sorted(list(detected_custom)):
        is_unicode = any(ord(c) > 127 for c in cg)
        unicode_repr = ""
        if is_unicode:
            unicode_repr = " (" + ", ".join(f"U+{ord(c):04X}" for c in cg) + ")"
        cg_safe = cg.encode('ascii', 'backslashreplace').decode('ascii')
        print(f"  {cg_safe}{unicode_repr}")

if __name__ == '__main__':
    main()
