import sys
import re
import subprocess

def fix_digit_critical_keywords(code):
    # Pattern to match numbers only when followed immediately by 'function' or 'local'
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

with open('g:/PC8/scratch/temp_min.p8', 'r', encoding='utf-8') as f:
    raw_min_content = f.read()

min_lua_match = re.search(r'(__lua__\n)(.*?)(\n__(?:gfx|gff|map|sfx|music|label)__|$)', raw_min_content, re.DOTALL)
min_lua_code = min_lua_match.group(2)

# Reconstruct case
sys.path.append('g:/PC8/scratch')
from build_minified_game import replace_if_do_with_then

lua_fixed = replace_if_do_with_then(min_lua_code)
lua_fixed = fix_digit_critical_keywords(lua_fixed)

# Try compiling
content = raw_min_content[:min_lua_match.start(2)] + lua_fixed + raw_min_content[min_lua_match.end(2):]
content = content.replace('\ufe0f', '')

with open('g:/PC8/scratch/temp_restricted.p8', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("Compiling with restricted boundary fix...")
res = subprocess.run([
    'g:/PC8/tools/pc8_compile.exe', 'game',
    'g:/PC8/scratch/temp_restricted.p8', 'g:/PC8/scratch/temp_restricted.pc8c'
], capture_output=True, text=True, errors='ignore')

print("Compile success:", res.returncode == 0)
print("Return code:", res.returncode)
print("Stderr:")
print(res.stderr.strip())
