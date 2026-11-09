#pragma once
// RONTO8 CoreS3 - Faces Bottom3 (A168) + Gamepad3 (A004-V3)
// GPIO12=SDA, GPIO11=SCL, GPIO10=IRQ; 0x08 address, 0x03 model.
// Read-only device protocol: never writes configuration or firmware.
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
    uint8_t failures = 0;
    uint32_t last_probe = 0;
    bool probe() {
        uint8_t id = 0;
        return bus_ready && M5.In_I2C.readRegister(ADDR, 0xd0, &id, 1, FREQ) && id == 0x03;
    }
    // The key-state read is a direct READ, NOT a register-pointer query.
    bool readKeys() {
        if (!M5.In_I2C.start(ADDR, true, FREQ)) return false;
        uint8_t next = 0xff;
        bool read_ok = M5.In_I2C.read(&next, 1, true);
        bool stop_ok = M5.In_I2C.stop();
        if (!read_ok || !stop_ok) return false;
        raw = next;
        return true;
    }
    void begin() {
        // Shared M5Unified I2C controller, no competing Wire initialization.
        bus_ready = M5.In_I2C.isEnabled() || M5.In_I2C.begin(I2C_NUM_1, SDA_PIN, SCL_PIN);
        pinMode(IRQ_PIN, INPUT_PULLUP);
        present.store(probe());
        raw = 0xff;
        if (present.load() && digitalRead(IRQ_PIN) == LOW) readKeys();
        last_probe = millis();
    }
    void update() {
        const uint32_t now = millis();
        if ((uint32_t)(now - last_probe) >= 1200u) {
            last_probe = now;
            if (!bus_ready) bus_ready = M5.In_I2C.isEnabled() || M5.In_I2C.begin(I2C_NUM_1, SDA_PIN, SCL_PIN);
            if (probe()) {
                failures = 0;
                if (!present.exchange(true)) {
                    raw = 0xff;
                    if (digitalRead(IRQ_PIN) == LOW) readKeys();
                }
            } else if (present.load() && ++failures >= 2) {
                present.store(false);
                raw = 0xff;
                failures = 0;
            }
        }
        if (present.load() && digitalRead(IRQ_PIN) == LOW) {
            if (!readKeys() && ++failures >= 3) {
                present.store(false);
                raw = 0xff;
                failures = 0;
            }
        }
    }
    uint16_t buttons() const {
        if (!present.load()) return 0;
        const uint8_t down = (uint8_t)~raw; // Physical buttons are active-low.
        uint16_t keys = 0;
        if (down & 0x04u) keys |= (1u << 0); // LEFT
        if (down & 0x08u) keys |= (1u << 1); // RIGHT
        if (down & 0x01u) keys |= (1u << 2); // UP
        if (down & 0x02u) keys |= (1u << 3); // DOWN
        if (down & 0x10u) keys |= (1u << 4); // A -> O
        if (down & 0x20u) keys |= (1u << 5); // B -> X
        if (down & 0x80u) keys |= (1u << 6); // START -> pause / confirm
        // SELECT+UP/DOWN: volume adjustment on the original volume bits.
        if (down & 0x40u) {
            if (down & 0x01u) { keys &= ~(1u << 2); keys |= (1u << 8); }
            if (down & 0x02u) { keys &= ~(1u << 3); keys |= (1u << 7); }
        }
        return keys;
    }
};
} // namespace ronto_faces3
