#pragma once
// RONTO8 CoreS3 - Faces Bottom3 (A168) + Gamepad3 (A004-V3)
// Official Gamepad3 v03 protocol:
//   CoreS3 I2C GPIO12 SDA, GPIO11 SCL, GPIO10 IRQ active LOW
//   0x08 slave, 0xD0 == 0x03 model register; direct single-byte key reads
//   Active-low buttons, IRQ stays low until state read.
// No writes to Gamepad3 configuration, address or MCU firmware.
#include <Arduino.h>
#include <M5Unified.h>
#include <atomic>

namespace ronto_faces3 {
struct Device {
    static constexpr uint8_t ADDR = 0x08;
    static constexpr int SDA_PIN = 12, SCL_PIN = 11, IRQ_PIN = 10;
    static constexpr uint32_t FREQ = 100000;
    std::atomic<bool> present{false};
    bool bus_ready = false;
    uint8_t raw = 0xff;
    uint8_t consecutive_probe_failures = 0;
    uint32_t last_probe_ms = 0;

    void ensureBus() {
        if (!bus_ready)
            bus_ready = M5.In_I2C.isEnabled() ||
                        M5.In_I2C.begin(I2C_NUM_1, SDA_PIN, SCL_PIN);
    }
    bool probe() {
        ensureBus();
        uint8_t id = 0;
        return bus_ready &&
            M5.In_I2C.readRegister(ADDR, 0xd0, &id, 1, FREQ) && id == 0x03;
    }
    bool readKeys() {
        // A direct single-byte READ; DO NOT write register 0x00 beforehand.
        if (!M5.In_I2C.start(ADDR, true, FREQ)) return false;
        uint8_t sample = 0xff;
        const bool read_ok = M5.In_I2C.read(&sample, 1, true);
        const bool stop_ok = M5.In_I2C.stop();
        if (!read_ok || !stop_ok || sample == 0x00) return false;
        raw = sample; // Only replace state on a complete valid transaction.
        return true;
    }
    void begin() {
        pinMode(IRQ_PIN, INPUT_PULLUP);
        ensureBus();
        // Power-up/probe transients should not force touch mode forever.
        bool detected = false;
        for (int attempt = 0; attempt < 3 && !detected; ++attempt) {
            detected = probe();
            if (!detected) delay(12);
        }
        present.store(detected);
        raw = 0xff;
        if (detected && digitalRead(IRQ_PIN) == LOW) readKeys();
        last_probe_ms = millis();
        Serial.printf("Faces Gamepad3: %s (IRQ=%d)\n",
                      detected ? "ready" : "not detected", digitalRead(IRQ_PIN));
    }
    void update() {
        const uint32_t now = millis();
        if (!present.load()) {
            if ((uint32_t)(now - last_probe_ms) >= 500u) {
                last_probe_ms = now;
                if (probe()) {
                    raw = 0xff;
                    consecutive_probe_failures = 0;
                    present.store(true);
                    if (digitalRead(IRQ_PIN) == LOW) readKeys();
                }
            }
            return;
        }

        // Read the event every time IRQ is asserted. Read at most 3 queued
        // changes per frame, retaining the last valid complete state.
        if (digitalRead(IRQ_PIN) == LOW) {
            for (int i = 0; i < 3 && digitalRead(IRQ_PIN) == LOW; ++i) {
                if (!readKeys()) break;
            }
        }

        // Infrequent health probe. A single I2C failure MUST NOT detach
        // the controller: this was causing 192x192 mode and missed inputs.
        if ((uint32_t)(now - last_probe_ms) >= 3000u) {
            last_probe_ms = now;
            if (probe()) {
                consecutive_probe_failures = 0;
            } else if (++consecutive_probe_failures >= 4) {
                raw = 0xff;
                present.store(false);
                consecutive_probe_failures = 0;
            }
        }
    }

    uint16_t buttons() const {
        if (!present.load()) return 0;
        const uint8_t down = (uint8_t)~raw; // 0 means pressed
        uint16_t keys = 0;
        if (down & 0x04u) keys |= (1u << 0); // LEFT
        if (down & 0x08u) keys |= (1u << 1); // RIGHT
        if (down & 0x01u) keys |= (1u << 2); // UP
        if (down & 0x02u) keys |= (1u << 3); // DOWN
        if (down & 0x10u) keys |= (1u << 4); // A -> PICO-8 O
        if (down & 0x20u) keys |= (1u << 5); // B -> PICO-8 X
        if (down & 0x80u) keys |= (1u << 6); // START -> pause/confirm
        if (down & 0x40u) { // SELECT + UP/DOWN -> volume
            if (down & 0x01u) { keys &= ~(1u << 2); keys |= (1u << 8); }
            if (down & 0x02u) { keys &= ~(1u << 3); keys |= (1u << 7); }
        }
        return keys;
    }
};
} // namespace ronto_faces3
