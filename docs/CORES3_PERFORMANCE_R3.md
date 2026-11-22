# CoreS3 performance experiment R3 (based on v1.01)

## Goal and status

Reduce the measured CoreS3-vs-Tab5 speed gap without bringing ESP32-P4 PPA code to ESP32-S3. This is **experimental**: CoreS3 hardware FPS and audio stability must still be measured. The original published v1.01 and M5Burner share code are unchanged.

## Why TCM is not used

ESP32-S3 has dual Xtensa LX7 cores and 512 KiB internal SRAM used as IRAM/DRAM. It has no ESP32-P4-style dedicated ITCM/DTCM. The R3 display-frame preparation routine is placed in IRAM using `IRAM_ATTR`; the 64 KiB PICO-8 RAM is placed in internal DRAM if available.

## Scheduler

| Workload | Before | R3 |
|---|---|---|
| Lua update/game loop + RGB565 frame preparation | Arduino Core 1 | Core 1, unchanged |
| `flipTask` SPI/DMA submission | Core 1, `configMAX_PRIORITIES - 2` | Core 0, priority 4 |
| `audio_task` synthesis/streaming | Core 0, priority 5 | Core 0, priority 5 |

One important caveat: moving LCD DMA submission to Core 0 can reduce Core 1 preemption, but both cores still share internal memory, cache and PSRAM bandwidth. Audio keeps a higher application task priority than LCD. The renderer and display must continue to synchronize using the existing `flipSem` / `doneSem` mechanism.

## Memory

The existing CoreS3 `rh_malloc()` only tries internal RAM for allocations <=32KiB, sending the v0.65-compatible 64KiB `m_memory` allocation directly to external PSRAM. R3 uses a new dedicated allocation helper for `m_memory`: allocate internal 8-bit SRAM only when a contiguous 64KiB block is available *and* at least 96KiB would remain available. Otherwise it falls back to the original allocator. No change is made to Lua heap memory, graphics DMA buffers or storage partitions.

At runtime, the serial log will show either:

```text
[R8CoreS3] PICO-8 RAM: 64 KiB internal SRAM (fast)
[R8CoreS3] CPU1 Lua/render; CPU0 LCD(4)+audio(5)
```

or `PSRAM fallback` with internal heap size if the reserve condition is not met.

## Rendering

The previous R2 change predecodes RGB565 palette pairs and reuses duplicated output rows. R3 additionally uses `IRAM_ATTR` for the hot `p8_render` function. Faces Gamepad3 mode remains 320x240; touch mode stays 192x192. High-color and transform modes still take a correctness-oriented fallback.

## Safety and verification

- No clock overclock, no TCM settings, no change to USB pins, LCD rotation, M5Unified/M5GFX versions, SD or Faces controls.
- No partition, OTA, bootloader, NVS or SD modification from code changes.
- Build and hardware FPS **not verified** by this commit; the new source is intended for a safe APP-only test.
- Compare the same cartridge and settings across R2 vs R3; monitor touch, Gamepad3, audio and menu transitions as well as FPS. In particular, any LCD+audio Core 0 interference would justify lowering LCD priority or reverting that scheduling change.

Source: [`src/m5stack_main.cpp`](../src/m5stack_main.cpp), [`src/p8_emu.c`](../src/p8_emu.c).
