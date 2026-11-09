#pragma once
// RONTO8 CoreS3 Faces Bottom3 + Gamepad3 (A004-V3), R6
// Internal I2C SDA=GPIO12 SCL=GPIO11, IRQ=GPIO10, default address 0x08.
// No panel firmware update or persistent peripheral writes.
#include <Arduino.h>
#include <M5Unified.h>
#include <M5Faces.h>
#include <atomic>

namespace ronto_faces3 {
struct Device {
    enum class Status : uint8_t {
        Ready, Legacy, BusUnavailable, NoPanel, UnknownModel
    };
    std::atomic<bool> present{false};
    M5Faces_Gamepad3 official;
    Status status = Status::NoPanel;
    bool bus_ready = false;
    bool official_mode = false;
    uint8_t address = 0x08;
    uint8_t model_id = 0;
    uint8_t fw_version = 0;
    uint8_t raw = 0xFF;
    uint8_t probe_failures = 0;
    uint8_t scan_addr = 0x09;
    uint32_t last_probe_ms = 0;
    uint32_t last_scan_ms = 0;

    static constexpr uint32_t freq = 100000;
    static constexpr int irq_pin = 10;

    bool ensureBus() {
        if (bus_ready) return true;
        bus_ready = M5.In_I2C.isEnabled();
        if (!bus_ready) {
            // CoreS3 documented M-Bus internal I2C, independent of stale pin maps.
            bus_ready = M5.In_I2C.begin(I2C_NUM_1, 12, 11);
        }
        return bus_ready;
    }

    bool registerRead(uint8_t addr, uint8_t reg, uint8_t& value) {
        return ensureBus() && M5.In_I2C.readRegister(addr, reg, &value, 1, freq);
    }

    bool ack(uint8_t addr) {
        if (!ensureBus()) return false;
        const bool ok = M5.In_I2C.start(addr, false, freq);
        M5.In_I2C.stop();
        return ok;
    }

    bool directRead(uint8_t addr, uint8_t& value) {
        if (!ensureBus() || !M5.In_I2C.start(addr, true, freq)) return false;
        uint8_t sample = 0xFF;
        const bool read_ok = M5.In_I2C.read(&sample, 1, true);
        const bool stop_ok = M5.In_I2C.stop();
        if (!read_ok || !stop_ok || sample == 0x00) return false;
        value = sample;
        return true;
    }

    bool connectAt(uint8_t addr, bool allow_legacy) {
        uint8_t model = 0;
        if (registerRead(addr, 0xD0, model) && model == 0x03) {
            if (official.begin(&M5.In_I2C, addr, freq) == M5FACES_OK) {
                // Do not configure IRQ gating on the official driver.
                // Its demonstrated CoreS3 integration uses update() on every tick.
                // Setting setInterruptPin(...,false) in R4/R5 prevented all reads
                // on installations where the IRQ voltage was not sampled LOW.
                address = addr;
                model_id = model;
                fw_version = 0;
                registerRead(addr, 0xFE, fw_version);
                raw = 0xFF;
                official_mode = true;
                present.store(true);
                status = Status::Ready;
                // The official Gamepad3 driver handles v03/v04 idle 0x00 bytes.
                // Input polling must work without an IRQ signal.
                if (official.update()) raw = official.getState().raw;
                Serial.printf("RONTO8 Faces R6: official gamepad addr=%02X fw=%02X\n", addr, fw_version);
                return true;
            }
        }
        // Some legacy panel firmware exposes only the direct key-state protocol.
        // Only accept this at 0x08, after an ACK and a successful direct READ;
        // other onboard I2C peripherals must not masquerade as a gamepad.
        if (allow_legacy && addr == 0x08 && ack(addr)) {
            uint8_t sample = 0xFF;
            if (directRead(addr, sample)) {
                raw = sample;
                address = addr;
                official_mode = false;
                present.store(true);
                status = Status::Legacy;
                Serial.println("RONTO8 Faces R6: legacy key read at 0x08");
                return true;
            }
        }
        return false;
    }

    void classifyFailure() {
        if (!ensureBus()) {
            status = Status::BusUnavailable;
            return;
        }
        uint8_t model = 0;
        if (registerRead(0x08, 0xD0, model)) {
            model_id = model;
            status = (model == 0x03) ? Status::NoPanel : Status::UnknownModel;
        } else {
            model_id = 0;
            status = ack(0x08) ? Status::UnknownModel : Status::NoPanel;
        }
    }

    void begin() {
        pinMode(irq_pin, INPUT_PULLUP);
        ensureBus();
        for (int attempt=0; attempt<3 && !present.load(); ++attempt) {
            if (!connectAt(0x08, true)) delay(15);
        }
        if (!present.load()) classifyFailure();
        last_probe_ms = millis();
        last_scan_ms = last_probe_ms;
        Serial.printf("RONTO8 Faces R6: bus=%d SDA=%d SCL=%d 0x08ACK=%d ID=%02X IRQ=%d state=%s\n",
                      bus_ready, 12, 11, ack(0x08), model_id, digitalRead(irq_pin), label());
    }

    void update() {
        const uint32_t now = millis();
        if (present.load()) {
            // R6: same input path as M5Stack's working Gamepad3 Arduino demo.
            // update() is called regardless of IRQ GPIO level. The official
            // driver filters blind-poll stale 0x00 and exposes full key state.
            if (official_mode) {
                if (official.update()) {
                    const uint8_t next = official.getState().raw;
                    if (raw != next) {
                        raw = next;
                        Serial.printf("RONTO8 R9 PAD raw=%02X buttons=%04X IRQ=%d\n",
                                      raw, buttons(), digitalRead(irq_pin));
                    }
                } else if (digitalRead(irq_pin) == LOW) {
                    // Firmware v03 event protocol: direct 1-byte I2C read.
                    // Only try this fallback when IRQ really indicates data.
                    uint8_t next = 0xFF;
                    if (directRead(address, next) && raw != next) {
                        raw = next;
                        Serial.printf("RONTO8 R9 PAD direct=%02X buttons=%04X\n",
                                      raw, buttons());
                    }
                }
            } else {
                // Legacy firmware uses direct-read events. Allow a modest
                // 15ms blind polling fallback when the IRQ wire isn't routed.
                static uint32_t last_direct_ms = 0;
                if (digitalRead(irq_pin) == LOW ||
                    (uint32_t)(now-last_direct_ms) >= 15u) {
                    last_direct_ms = now;
                    uint8_t next = 0xFF;
                    if (directRead(address, next) && next != raw) {
                        raw = next;
                        Serial.printf("RONTO8 R6 LEGACY raw=%02X buttons=%04X\n",
                                      raw, buttons());
                    }
                }
            }
            if ((uint32_t)(now-last_probe_ms) >= 5000u) {
                last_probe_ms = now;
                uint8_t model=0;
                const bool okay = official_mode
                    ? (registerRead(address, 0xD0, model) && model == 0x03)
                    : ack(address);
                if (okay) probe_failures=0;
                else if (++probe_failures >= 4) {
                    present.store(false);
                    raw=0xFF;
                    probe_failures=0;
                    classifyFailure();
                }
            }
            return;
        }

        // Prefer the expected address. Slow incremental scan also supports
        // a Gamepad3 with a non-default address, without any configuration writes.
        if ((uint32_t)(now-last_probe_ms) >= 500u) {
            last_probe_ms=now;
            if (connectAt(0x08, true)) return;
            classifyFailure();
        }
        if ((uint32_t)(now-last_scan_ms) >= 250u && ensureBus()) {
            last_scan_ms=now;
            for (int i=0; i<3; ++i) {
                const uint8_t candidate=scan_addr;
                scan_addr = scan_addr >= 0x77 ? 0x09 : (uint8_t)(scan_addr+1);
                uint8_t model=0;
                if (registerRead(candidate, 0xD0, model) && model==0x03 &&
                    connectAt(candidate, false)) return;
            }
        }
    }

    const char* keyLabel() const {
        const uint16_t b=buttons();
        if (b & (1u<<9)) return "R9 SELECT";
        if (b & (1u<<6)) return "R9 START";
        if (b & (1u<<4)) return "R9 A";
        if (b & (1u<<5)) return "R9 B";
        if (b & (1u<<2)) return "R9 UP";
        if (b & (1u<<3)) return "R9 DOWN";
        if (b & (1u<<0)) return "R9 LEFT";
        if (b & (1u<<1)) return "R9 RIGHT";
        if (b & (1u<<8)) return "R9 VOL+";
        if (b & (1u<<7)) return "R9 VOL-";
        return "R9 PAD";
    }

    const char* label() const {
        switch (status) {
        case Status::Ready: return "PAD READY";
        case Status::Legacy: return "PAD LEGACY";
        case Status::BusUnavailable: return "I2C BUS FAIL";
        case Status::NoPanel: return "0x08 NO ACK";
        case Status::UnknownModel: return "0x08 BAD ID";
        }
        return "NO GAMEPAD";
    }

    uint16_t buttons() const {
        if (!present.load()) return 0;
        const uint8_t down=(uint8_t)~raw;
        uint16_t out=0;
        if (down & 0x04u) out|=(1u<<0);
        if (down & 0x08u) out|=(1u<<1);
        if (down & 0x01u) out|=(1u<<2);
        if (down & 0x02u) out|=(1u<<3);
        if (down & 0x10u) out|=(1u<<4);
        if (down & 0x20u) out|=(1u<<5);
        if (down & 0x80u) out|=(1u<<6);
        // SELECT is a dedicated menu key. Do not steal SELECT+UP/DOWN
        // for volume: the menu itself adjusts the saved speaker volume.
        if (down & 0x40u) out|=(1u<<9);
        return out;
    }
};
} // namespace ronto_faces3
