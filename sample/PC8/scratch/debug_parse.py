import sys

def main():
    filename = 'g:/PC8/top4_min_std.p8'
    with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        
    lua_lines = []
    in_lua = False
    for line in lines:
        line = line.rstrip('\r\n')
        if line == '__lua__':
            in_lua = True
            continue
        if line.startswith('__') and in_lua:
            # check if it is another section
            if re.match(r'^__[a-z]+__$', line):
                in_lua = False
            
        if in_lua:
            lua_lines.append(line)
            
    with open('g:/PC8/scratch/debug_output.txt', 'w', encoding='utf-8') as out:
        for i, l in enumerate(lua_lines):
            out.write(f"{i+1}: {l}\n")

if __name__ == '__main__':
    import re
    main()
