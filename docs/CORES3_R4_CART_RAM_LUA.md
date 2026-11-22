# CoreS3 R4 — safer cartridge loading and faster Lua bytecode dispatch

Based on experimental R3; **does not change the public v1.01 or M5Burner image**.

## What the real CoreS3 log shows

The original `Prof: draw=27ms` was measured around `lua_draw()`, so it is the **cartridge's Lua draw callback**, not the RGB565 expander or SPI transfer. The `flip=15–32ms` measurement wraps `p8_flip()`, including frame pacing via `p8_sleep()`. It cannot be used as a pure DMA latency metric. Likewise, the `debt` metric comes from the existing 30-fps / 60-fps update pacing; it is not evidence that SPI alone is too slow.

An exception such as `/sd/38190.p8.png:94: attempt to index local 'cn' (a nil value)` is a **separate Lua runtime compatibility failure**. Fixing that safely requires the actual Lua source around line 94 and its setup path. R4 does not silently invent a game-specific patch.

## R4 changes

- **Run PICO-8 Lua directly from RAM on ESP32-S3** rather than trying to erase and mmap the nonexistent `romdata` partition. For text `.p8` scripts use the source buffer until compilation; for decompressed `.p8.png` scripts use the existing PSRAM-owned decompression buffer and release it through the existing lifetime.
- **Stop automatic SD script dumps.** The previous `p8_emu.c` created `/sd/<cart>_orig.lua` on every load and, if a `.p8t` patch was found, created a patched copy on SD. R4 only *reads* optional `.p8t` patches, applying them in memory; the parser no longer writes those debug dump files. Existing `_orig.lua` files are not touched or deleted.
- **Target the actual Lua draw bottleneck:** apply `IRAM_ATTR` only to `luaV_execute` (the hot Lua bytecode dispatch function), rather than copying the whole interpreter into IRAM. This can avoid some flash-cache misses but the actual FPS gain needs a hardware run.
- Keep R3's **Core1 Lua / Core0 LCD+audio**, internal-SRAM preferred 64 KiB `m_memory`, native display orientation, Faces Gamepad3, audio and the two screen modes.

This branch makes **no changes to partition CSV, OTA selection, bootloader, NVS, or USB pin configuration**. A test package should use verified ESP32-S3 identity and live partition checks with APP-only writes.

## Expected result

- The `Error: romdata partition not found!` message should no longer appear for `.p8` and `.p8.png` loads.
- The `Saved original script to: /sd/..._orig.lua` message and automatic file creation are removed.
- `_draw()` should be faster **if bytecode dispatch/cache misses were a significant share** of the 27ms callback. No speed multiplier is claimed.
- `cn` nil requires source-level cartridge investigation if it persists.

**Verification status:** Changes are staged for compilation and hardware test, not yet measured on CoreS3. The production M5Burner version stays v1.01.
