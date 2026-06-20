import sys
import mmap
# Memory‑map the p8 file for efficient reading
with open('g:/PC8/data/bios.p8', 'r+b') as f:
    mm = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
    # Print the first line of the original file
    first_line = mm.readline().decode('utf-8').rstrip('\r\n')
    print(f"First line of bios.p8: {first_line}")
    # Decode entire content and split into lines for downstream processing
    mm.seek(0)
    lines = mm.read().decode('utf-8').splitlines(True)

# Extract Lua code
code = []
in_lua = False
for line in lines:
    l = line.strip('\r\n')
    if l == '__lua__':
        in_lua = True
        continue
    elif l in ('__gfx__', '__map__', '__gff__', '__sfx__', '__music__', '__label__') and in_lua:
        in_lua = False
    
    if in_lua:
        code.append(line.rstrip('\r\n'))

minified = '\n'.join(code) + '\n'
print(f"Extracted lua code size: {len(minified)} bytes")

# Extract gfx data (hex lines after __gfx__ until next section or EOF)
gfx_lines = []
in_gfx = False
for line in lines:
    l = line.strip('\r\n')
    if l == '__gfx__':
        in_gfx = True
        continue
    if in_gfx:
        if l in ('__map__', '__gff__', '__sfx__', '__music__', '__label__'):
            break
        if l:
            gfx_lines.append(l)

# PICO-8 sprite memory is 8192 bytes = 1024 sprites * 8 bytes
# Each hex line is 256 chars = 128 bytes, so we need 64 lines
# Take only first 64 lines (8192 bytes)
gfx_hex = ''.join(gfx_lines[:64])
print(f"Extracted gfx hex: {len(gfx_hex)} chars = {len(gfx_hex)//2} bytes")
# Build all 8192 GFX bytes as a list
all_bytes = []
for i in range(0, len(gfx_hex), 2):
    all_bytes.append(int(gfx_hex[i:i+2], 16))
while len(all_bytes) < 8192:
    all_bytes.append(0)

# Write bios.bin
with open('g:/PC8/data/bios.bin', 'wb') as f:
    # Magic bytes: PC8B
    f.write(b'PC8B')
    # Lua code length (uint32_t, little endian)
    lua_bytes = minified.encode('utf-8')
    f.write(len(lua_bytes).to_bytes(4, byteorder='little'))
    # GFX bytes (8192 bytes)
    f.write(bytes(all_bytes))
    # Lua code bytes
    f.write(lua_bytes)

print("Written binary packet to g:/PC8/data/bios.bin")
