import struct

with open("cutebunnies-0.pc8c", "rb") as f:
    data = f.read()

# Header: magic(4) + name(32) + rom_size(4) = 40
rom_size = struct.unpack("<I", data[36:40])[0]
print(f"ROM size: {rom_size}")

# SFX offset in ROM = 0x3200 = 12800
# In pc8c, SFX starts at 40 + 12800 = 12840
sfx_start = 40 + 12800

# Dump first 3 SFX entries (68 bytes each)
for i in range(3):
    offset = sfx_start + i * 68
    sfx_data = data[offset : offset + 68]
    filters, speed, loop_start, loop_end = struct.unpack("<BBBB", sfx_data[64:68])
    print(f"SFX {i}: filters={filters}, speed={speed}, loop_start={loop_start}, loop_end={loop_end}")
    # print notes summary
    notes = sfx_data[:64]
    notes_str = " ".join(f"{notes[j] | (notes[j+1] << 8):04X}" for j in range(0, 8, 2))
    print(f"  First 4 notes: {notes_str}")
