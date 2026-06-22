import re

with open('test_patched_final.lua', 'r', encoding='utf-8') as f:
    lines = f.readlines()

blocks = 0
stack = []
for i, line in enumerate(lines):
    line_strip = line.strip()
    if line_strip.startswith('--'): continue
    
    # Ignore single-line PICO-8 ifs: 'if (cond) stmt'
    if re.match(r'^if\s*\(.*?\)\s+[a-zA-Z0-9_.]+\s*[+\-*/]?=', line_strip) or \
       re.match(r'^if\s*\(.*?\)\s+sfx', line_strip) or \
       re.match(r'^if\s*\(.*?\)\s+return', line_strip) or \
       re.match(r'^if\s*\(.*?\)\s+break', line_strip) or \
       re.match(r'^if\s*\(.*?\)\s+[a-zA-Z0-9_.]+\s*\(.*?\)', line_strip):
        continue

    # Clean strings so we don't count keywords inside strings
    line_clean = re.sub(r'".*?"', '""', line_strip)
    line_clean = re.sub(r"'.*?'", "''", line_clean)

    tokens = re.findall(r'\b(function|if|for|while|repeat|end|until)\b', line_clean)
    
    for t in tokens:
        if t in ('function', 'if', 'for', 'while', 'repeat'):
            blocks += 1
            stack.append((i+1, t, line_strip))
        elif t in ('end', 'until'):
            blocks -= 1
            if stack:
                stack.pop()

print(f'Final block count at end of file: {blocks}')
if blocks != 0:
    print('WARNING: File is NOT perfectly balanced.')
    print('Unclosed blocks:')
    for line_num, t, code in stack:
        print(f'Line {line_num}: {t} | {code.encode("ascii", "ignore").decode("ascii")}')
else:
    print('SUCCESS: File is perfectly balanced.')
