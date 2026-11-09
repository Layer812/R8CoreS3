#pragma once
// CoreS3 / M5Stack Faces Bottom3 + Gamepad3
// Official driver integration; no Gamepad3 firmware/EEPROM writes.
// M5-Bus 0x08, internal SDA GPIO12 / SCL GPIO11, IRQ GPIO10.
#include <Arduino.h>
#include <M5Unified.h>
#include <M5Faces.h>
#include <atomic>

namespace ronto_faces3 {
struct Device {
    std::atomic<bool> present{false};
    M5Faces_Gamepad3 official;
    bool bus_ready = false;
    bool initialized = false;
    uint8_t raw = 0xFF;
    uint8_t model_id = 0;
    uint8_t fw_version = 0;
    uint8_t consecutive_probe_failures = 0;
    uint32_t last_probe_ms = 0;

    // The official sample enables M5.In_I2C using the board's own pins.
    bool ensureBus() {
        if (!bus_ready) {
            bus_ready = M5.In_I2C.isEnabled();
            if (!bus_ready) {
                const int sda = M5.getPin(m5::pin_name_t::in_i2c_sda);
                const int scl = M5.getPin(m5::pin_name_t::in_i2c_scl);
                if (sda >= 0 && scl >= 0)
                    bus_ready = M5.In_I2C.begin(I2C_NUM_1, sda, scl);
            }
        }
        return bus_ready;
    }

    bool probe() {
        model_id = 0;
        if (!ensureBus()) return false;
        const bool ok = M5.In_I2C.readRegister(0x08, 0xD0, &model_id, 1, 100000);
        if (ok && model_id == 0x03) {
            uint8_t version = 0;
            if (M5.In_I2C.readRegister(0x08, 0xFE, &version, 1, 100000))
                fw_version = version;
            return true;
        }
        return false;
    }

    bool connect() {
        if (!probe()) return false;
        // Library checks model ID in begin(), then implements V03/V04 key-state polling.
        if (official.begin(&M5.In_I2C) != M5FACES_OK) return false;
        initialized = true;
        raw = 0xFF;
        official.setInterruptPin(10, false); // Poll IRQ, no busy loop.
        present.store(true);
        official.update();
        raw = official.getState().raw;
        Serial.printf("RONTO8 Faces3: model=0x%02X fw=0x%02X IRQ=%d\n",
                      model_id, fw_version, digitalRead(10));
        return true;
    }

    void begin() {
        pinMode(10, INPUT_PULLUP);
        for (int attempt = 0; attempt < 4; ++attempt) {
            if (connect()) break;
            delay(20);
        }
        last_probe_ms = millis();
        Serial.printf("RONTO8 Faces3 initial status=%s, bus=%d, model=0x%02X, irq=%d\n",
                      present.load() ? "READY" : "NO PAD", bus_ready, model_id,
                      digitalRead(10));
    }

    void update() {
        const uint32_t now = millis();
        if (!present.load()) {
            if ((uint32_t)(now - last_probe_ms) >= 400u) {
                last_probe_ms = now;
                connect();
            }
            return;
        }

        // Use the official Gamepad3 state reader. The driver avoids the
        // v03/v04 stale-0x00 issue and only publishes valid changed samples.
        if (initialized && digitalRead(10) == LOW) {
            for (int i = 0; i < 3 && digitalRead(10) == LOW; ++i) {
                official.update();
                raw = official.getState().raw;
            }
        }

        // Valid model ID proves that the pad is present. Isolated failed reads
        // must never cause a size/input mode change.
        if ((uint32_t)(now - last_probe_ms) >= 3000u) {
            last_probe_ms = now;
            if (probe()) {
                consecutive_probe_failures = 0;
            } else if (++consecutive_probe_failures >= 4) {
                present.store(false);
                initialized = false;
                raw = 0xFF;
                consecutive_probe_failures = 0;
            }
        }
    }

    uint16_t buttons() const {
        if (!present.load()) return 0;
        const uint8_t down = (uint8_t)~raw;
        uint16_t out = 0;
        if (down & 0x04u) out |= (1u << 0); // LEFT
        if (down & 0x08u) out |= (1u << 1); // RIGHT
        if (down & 0x01u) out |= (1u << 2); // UP
        if (down & 0x02u) out |= (1u << 3); // DOWN
        if (down & 0x10u) out |= (1u << 4); // A -> O
        if (down & 0x20u) out |= (1u << 5); // B -> X
        if (down & 0x80u) out |= (1u << 6); // START -> pause / confirm
        if (down & 0x40u) {
            if (down & 0x01u) { out &= ~(1u << 2); out |= (1u << 8); }
            if (down & 0x02u) { out &= ~(1u << 3); out |= (1u << 7); }
        }
        return out;
    }
};
} // namespace ronto_faces3
