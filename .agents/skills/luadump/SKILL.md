---
name: luadump
description: Enable or disable the Lua script dumping feature in the emulator (p8_emu.c) when requested.
---

# Lua Dump Skill

When the user says "luadumpを有効にしてください" (Please enable luadump) or "luadumpを無効にしてください" (Please disable luadump), follow these instructions:

1. Target File: `src/p8_emu.c`
2. Search for the debug dump sections inside `p8_init_file_with_param()`. They look like this:
   ```c
   #if 0
           // debug 
           char dump_orig_path[256];
   ```
   and
   ```c
   #if 0            
           // debug
             char dump_patch_path[256];
   ```
3. If enabling, change `#if 0` to `#if 1` for both debug blocks.
4. If disabling, change `#if 1` to `#if 0` for both debug blocks.
5. Use the `replace_file_content` tool to apply the changes.
6. Run `git add src/p8_emu.c` and `git commit -m "Enable/Disable Lua dump debug code"` depending on the action.
7. Remind the user to compile and upload the firmware to their M5Cardputer (e.g. `pio run --target upload ; pio device monitor`) to apply the changes.
