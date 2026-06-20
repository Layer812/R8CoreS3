import re
from collections import Counter

# PICO-8 / Lua の予約語や標準API
EXCLUDE_WORDS = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function",
    "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true",
    "until", "while", "goto",
    # PICO-8 functions
    "clip", "palt", "pal", "color", "cls", "camera", "circ", "circfill",
    "rect", "rectfill", "line", "spr", "sspr", "pset", "pget", "mset", "mget",
    "map", "draw", "update", "init", "print", "cursor", "color", "cls",
    "sfx", "music", "peek", "poke", "peek2", "poke2", "peek4", "poke4",
    "memcpy", "memset", "reload", "cstore", "rnd", "srand", "flr", "ceil",
    "sgn", "abs", "min", "max", "mid", "cos", "sin", "atan2", "sqrt",
    "add", "del", "all", "foreach", "pairs", "ipairs", "type", "tostring",
    "tonumber", "cocreate", "coresume", "costatus", "yield", "btn", "btnp",
    "cartdata", "dget", "dset", "printh", "stat", "extcmd", "holdframe", "flip",
    # Special callbacks
    "_init", "_update", "_update60", "_draw",
    # Common standard tables
    "math", "string", "table", "coroutine", "debug",
    # Already defined object keys or properties that might be accessed dynamically
    "x", "y", "vx", "vy", "radius", "color", "type", "state", "hue", "name",
    "width", "height", "speed", "filters", "loop_start", "loop_end",
    "sfx0", "sfx1", "sfx2", "sfx3", "start", "loop", "stop", "mode"
}

def analyze_identifiers(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # Lua section only
    lua_match = re.search(r'__lua__\n(.*?)(\n__gfx__|\n__gff__|\n__map__|\n__sfx__|\n__music__|\n__label__|$)', content, re.DOTALL)
    if not lua_match:
        return
    lua_code = lua_match.group(1)

    # Comments removal for identifier collection
    lines = lua_code.splitlines()
    cleaned = []
    for line in lines:
        stripped = line.strip()
        if not stripped.startswith("--"):
            cleaned.append(line)
    lua_code = "\n".join(cleaned)

    # Find all words/identifiers
    words = re.findall(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b', lua_code)
    
    # Filter: length >= 5, not in exclude list
    candidates = [w for w in words if len(w) >= 5 and w not in EXCLUDE_WORDS]
    
    # Count frequency
    counter = Counter(candidates)
    
    print("Top candidates for minification:")
    sorted_candidates = sorted(counter.items(), key=lambda x: (x[1] * len(x[0])), reverse=True)
    
    map_code = "REPLACEMENTS = {\n"
    idx = 1
    for word, count in sorted_candidates[:120]: # Top 120
        # Check if it starts with __ (internal/reserved)
        if word.startswith("__"):
            continue
        print(f"  {word}: length={len(word)}, count={count}, score={len(word)*count}")
        # Generate short name
        short_name = f"v{idx}"
        map_code += f'    "{word}": "{short_name}",\n'
        idx += 1
    map_code += "}\n"
    
    print("\nGenerated mapping code snippet:")
    print(map_code)

if __name__ == "__main__":
    analyze_identifiers("g:/PC8/pegball-3.p8")
