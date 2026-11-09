#include <Arduino.h>
/*
 * Created by Layer8
 * M5Stack CoreS3 entry point and hardware abstraction layer for RONTO8.
 */
#include <M5Unified.h>
#include <Adafruit_NeoPixel.h>
#include "faces_gamepad3.hpp"

static ronto_faces3::Device g_faces;
static constexpr int kTouchGameSize = 192;
static constexpr int kPhysicalWidth = 320;
static constexpr int kPhysicalHeight = 240;
static constexpr size_t kBufferPixels = kPhysicalWidth * kPhysicalHeight;
static std::atomic<bool> g_frame_physical{false};

// Faces Bottom3 A168: LED switch must be at G25 (CoreS3 GPIO5).
// G15 would connect to CoreS3 GPIO13 (speaker I2S DOUT) and can cause full-white LEDs.
static Adafruit_NeoPixel g_base_leds(10, 5, NEO_GRB + NEO_KHZ800);
static bool g_base_leds_initialized = false;
static void clear_base_leds()
{
    if (g_base_leds_initialized) return;
    g_base_leds.begin();
    g_base_leds.setBrightness(0);
    g_base_leds.clear();
    g_base_leds.show();
    g_base_leds_initialized = true;
}
SemaphoreHandle_t flipSem;
SemaphoreHandle_t doneSem;
uint16_t* line_buffer[2];
int render_idx = 0;

void flipTask(void *pvParameters) {
    while (1) {
        xSemaphoreTake(flipSem, portMAX_DELAY);
        if (render_idx >= 0 && line_buffer[0] != NULL) {
            if (g_frame_physical.load()) M5.Display.pushImageDMA(0, 0, kPhysicalWidth, kPhysicalHeight, line_buffer[render_idx]);
            else M5.Display.pushImageDMA(76, 32, kTouchGameSize, kTouchGameSize, line_buffer[render_idx]);
        }
        render_idx = 1 - render_idx;
        xSemaphoreGive(doneSem);
    }
}



#include <SPI.h>
#include <SD.h>
#include <freertos/FreeRTOS.h>
#include <freertos/task.h>
#include <Preferences.h>
#include <math.h>
#include <atomic>

extern "C" {
#include "p8_emu.h"
#include "p8_parser.h"

// Expose internal functions
extern uint16_t m_colors[32];
extern void render_sounds(int16_t *buffer, int total_samples);
}

extern unsigned m_actual_fps;
static LGFX_Sprite p8_sprite(&M5.Display);

static constexpr int MAX_BROWSER_ENTRIES = 256;
static constexpr int MAX_BROWSER_BUF_SIZE = 4096;

static char*     g_browser_name_buf     = nullptr;
static uint16_t* g_browser_name_offsets = nullptr;
static bool*     g_browser_is_dir       = nullptr;
static int       g_browser_buf_used     = 0;

static String g_browser_path   = "/";
static int    g_browser_count  = 0;
static int    g_browser_cursor = 0;
static int    g_cursor_history[10] = {0};
static int    g_depth = 0;

String   get_browser_name(int index);
void     load_selected_rom();
uint16_t get_touch_state();
void     draw_virtual_gamepad();

static volatile bool g_emulator_ready       = false;
static volatile bool g_emulator_init_failed = false;
static volatile bool g_audio_task_started   = false;

int g_volume = 255;
bool g_held_O = false;
bool g_held_X = false;

// Gamepad3 SELECT: simple readable settings panel, separate from PICO-8
// START/pause. The PICO engine stops stepping while this menu is visible.
static bool g_select_menu_open = false;
static bool g_select_menu_pending = false;
static bool g_select_pressed_prev = false;
static bool g_swallow_until_release = false;
static std::atomic<bool> g_audio_hold{false};
static uint16_t g_menu_prev_btn = 0;
static int g_menu_selected = 0;
static bool g_menu_volume_dirty = false;
static String g_current_rom_path;

static void draw_select_menu();
static void begin_select_menu();
static void update_select_menu();

extern "C" {
    char g_last_error_message[256] = {0};
    bool g_emulator_crashed = false;
    char g_cart_title[32]   = {0};
    char g_cart_author[32]  = {0};
}

// ---------------------------------------------------------------------------
// SD / file browser
// ---------------------------------------------------------------------------

static bool is_rom_file(const String& name)
{
    String lower = name;
    lower.toLowerCase();
    return lower.endsWith(".p8") || lower.endsWith(".png");
}

static void scan_browser_directory(const String& path)
{
    g_browser_count    = 0;
    g_browser_cursor   = 0;
    g_browser_buf_used = 0;

    File dir = SD.open(path.c_str());
    if (!dir || !dir.isDirectory())
        return;

    if (path != "/" && path != "/sd" && path != "/sd/" && g_browser_count < MAX_BROWSER_ENTRIES) {
        strcpy(g_browser_name_buf + g_browser_buf_used, "..");
        g_browser_name_offsets[g_browser_count] = g_browser_buf_used;
        g_browser_is_dir[g_browser_count]       = true;
        g_browser_buf_used += 3;
        g_browser_count++;
    }

    while (true) {
        File entry = dir.openNextFile();
        if (!entry)
            break;

        String name   = entry.name();

        if (name == "System Volume Information") {
            entry.close();
            continue;
        }

        bool   is_dir = entry.isDirectory();
        entry.close();

        if (name == "." || name == "..")
            continue;

        if (is_dir || is_rom_file(name)) {
            if (g_browser_count < MAX_BROWSER_ENTRIES) {
                int len = name.length();
                if (g_browser_buf_used + len + 1 < MAX_BROWSER_BUF_SIZE) {
                    strcpy(g_browser_name_buf + g_browser_buf_used, name.c_str());
                    g_browser_name_offsets[g_browser_count] = g_browser_buf_used;
                    g_browser_is_dir[g_browser_count]       = is_dir;
                    g_browser_buf_used += len + 1;
                    g_browser_count++;
                }
            }
        }
    }

    dir.close();
}

// ---------------------------------------------------------------------------
// RONTO8 arcade visual identity: 1990s-style yellow/black throughout the UI.
// Native 320x240 primitives: no external fonts, bitmaps, heap use, or SD reads.
// ---------------------------------------------------------------------------
static constexpr int kBrowserRows = 6;
static constexpr int kBrowserRowH = 24;

static uint16_t arcade_gold() { return M5.Display.color565(255, 196, 0); }

// Large blocky original R8 wordmark. 5x7 pixels per glyph at adjustable scale.
// Created as geometry rather than bundling artwork or requiring extra assets.
static void arcade_logo(int x, int y, int scale)
{
    static const uint8_t letters[2][7] = {
        { 0x1E, 0x11, 0x11, 0x1E, 0x14, 0x12, 0x11 }, // R
        { 0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E }  // 8
    };
    for (int letter = 0; letter != 2; ++letter) {
        for (int cy = 0; cy != 7; ++cy) {
            for (int cx = 0; cx != 5; ++cx) {
                if (letters[letter][cy] & (0x10 >> cx)) {
                    M5.Display.fillRect(x + (letter * 6 + cx) * scale,
                                        y + cy * scale, scale, scale, TFT_BLACK);
                }
            }
        }
    }
}

static void arcade_title_bar(const char* heading, const char* status)
{
    const uint16_t gold = arcade_gold();
    M5.Display.fillRect(0, 0, 320, 34, gold);
    arcade_logo(8, 5, 3);
    M5.Display.setTextSize(2);
    M5.Display.setTextColor(TFT_BLACK, gold);
    M5.Display.setCursor(58, 9);
    M5.Display.print(heading);
    if (status && *status) {
        M5.Display.setCursor(211, 9);
        M5.Display.print(status);
    }
    M5.Display.fillRect(8, 33, 304, 3, TFT_BLACK);
}

static String arcade_short_name(const String& name, size_t max_chars)
{
    if (name.length() <= max_chars) return name;
    if (max_chars < 5) return name.substring(0, max_chars);
    return name.substring(0, max_chars - 2) + "..";
}

static void arcade_browser_info(int cursor)
{
    const uint16_t gold = arcade_gold();
    M5.Display.fillRect(8, 67, 103, 133, gold);
    M5.Display.drawRect(8, 67, 103, 133, TFT_BLACK);
    M5.Display.fillRect(13, 72, 93, 23, TFT_BLACK);
    M5.Display.setTextSize(2);
    M5.Display.setTextColor(gold, TFT_BLACK);
    M5.Display.setCursor(20, 76);
    M5.Display.print("SELECT");
    M5.Display.setTextColor(TFT_BLACK, gold);
    if (g_browser_count <= 0 || cursor < 0 || cursor >= g_browser_count) {
        M5.Display.setCursor(17, 116);
        M5.Display.print("NO ROMS");
        return;
    }
    // This is file information, NOT a fabricated game screenshot.
    const String name = String(g_browser_name_buf + g_browser_name_offsets[cursor]);
    M5.Display.setTextSize(2);
    // Long names continue across up to three lines, never shrinking the font.
    for (int line = 0; line < 3; ++line) {
        const int index = line * 7;
        if (index >= (int)name.length()) break;
        String chunk = name.substring(index, index + 7);
        if (line == 2 && name.length() > 21)
            chunk = name.substring(14, 19) + "..";
        M5.Display.setCursor(17, 110 + line * 22);
        M5.Display.print(chunk);
    }
    M5.Display.fillRect(14, 174, 91, 2, TFT_BLACK);
    M5.Display.setCursor(18, 181);
    M5.Display.printf("%d/%d", cursor + 1, g_browser_count);
}

static void draw_browser()
{
    const uint16_t gold = arcade_gold();
    const bool faces = g_faces.present.load();
    if (faces) {
        M5.Display.fillScreen(gold);
    } else {
        // Do not erase the side gutters: they hold the touch controller.
        M5.Display.fillRect(74, 27, 192, 194, TFT_BLACK);
    }

    if (faces) {
        // Gamepad3: split file-info / ROM-list design from the approved concept.
        arcade_title_bar("ROM SELECT", "R9 PAD");
        M5.Display.setTextSize(2);
        M5.Display.setTextColor(TFT_BLACK, gold);
        M5.Display.setCursor(10, 43);
        M5.Display.print(arcade_short_name(String("SD:") + g_browser_path, 24));
        M5.Display.fillRect(8, 62, 304, 2, TFT_BLACK);
        arcade_browser_info(g_browser_cursor);

        int start = 0;
        if (g_browser_count > kBrowserRows) {
            start = g_browser_cursor - (kBrowserRows - 1);
            if (start < 0) start = 0;
            const int maxStart = g_browser_count - kBrowserRows;
            if (start > maxStart) start = maxStart;
        }
        for (int row = 0; row < kBrowserRows; ++row) {
            const int idx = start + row;
            const int y = 67 + row * kBrowserRowH;
            if (idx >= g_browser_count) break;

            const bool selected = idx == g_browser_cursor;
            if (selected) M5.Display.fillRect(117, y, 195, 23, TFT_BLACK);
            const uint16_t fg = selected ? gold : TFT_BLACK;
            const uint16_t fill = selected ? TFT_BLACK : gold;
            M5.Display.setTextSize(2);
            M5.Display.setTextColor(fg, fill);
            M5.Display.setCursor(122, y + 3);
            M5.Display.print(selected ? ">" : (g_browser_is_dir[idx] ? "+" : " "));
            M5.Display.setCursor(137, y + 3);
            const String file = String(g_browser_name_buf + g_browser_name_offsets[idx]);
            M5.Display.print(arcade_short_name(file, 14));
        }

        M5.Display.fillRect(0, 213, 320, 27, TFT_BLACK);
        M5.Display.setTextColor(gold, TFT_BLACK);
        M5.Display.setTextSize(2);
        M5.Display.setCursor(7, 220);
        M5.Display.print("A:OPEN B:BACK SEL:MENU");
    } else {
        // Preserve the touch-button gutters (x<74 and x>266).
        M5.Display.fillRect(74, 27, 192, 194, gold);
        M5.Display.fillRect(76, 31, 188, 3, TFT_BLACK);
        M5.Display.setTextColor(TFT_BLACK, gold);
        M5.Display.setTextSize(2);
        M5.Display.setCursor(85, 38);
        M5.Display.print("ROM SELECT");
        M5.Display.setCursor(79, 58);
        M5.Display.print(arcade_short_name(g_browser_path, 15));

        int start = 0;
        if (g_browser_count > kBrowserRows) {
            start = g_browser_cursor - kBrowserRows + 1;
            if (start < 0) start = 0;
            const int maxStart = g_browser_count - kBrowserRows;
            if (start > maxStart) start = maxStart;
        }
        for (int row = 0; row < kBrowserRows; ++row) {
            const int idx = start + row;
            if (idx >= g_browser_count) break;
            const int y = 83 + row * 22;
            const bool selected = idx == g_browser_cursor;
            const uint16_t fg = selected ? gold : TFT_BLACK;
            const uint16_t fill = selected ? TFT_BLACK : gold;
            if (selected) M5.Display.fillRect(76, y - 1, 188, 22, TFT_BLACK);
            M5.Display.setTextColor(fg, fill);
            M5.Display.setTextSize(2);
            M5.Display.setCursor(80, y + 2);
            M5.Display.print(selected ? ">" : " ");
            M5.Display.print(arcade_short_name(String(g_browser_name_buf + g_browser_name_offsets[idx]), 13));
        }
    }
    M5.Display.setTextColor(TFT_WHITE, TFT_BLACK);
}

// ---------------------------------------------------------------------------
// IMU tilt input (D-pad via accelerometer)
// ---------------------------------------------------------------------------

#define IMU_THRESHOLD 0.3f // Tilt threshold (larger = less sensitive)

uint16_t get_imu_input()
{
    uint16_t btn_state = 0;
    float ax = 0, ay = 0, az = 0;
    
    M5.Imu.getAccelData(&ax, &ay, &az);
    
    // X-axis tilt - 右に傾けると ax が負になる
    if (ax < -IMU_THRESHOLD)      btn_state |= (1 << 1); // RIGHT
    else if (ax > IMU_THRESHOLD)  btn_state |= (1 << 0); // LEFT
    
    // Y-axis tilt (up/down)
    if (ay > IMU_THRESHOLD)       btn_state |= (1 << 3); // DOWN
    else if (ay < -IMU_THRESHOLD) btn_state |= (1 << 2); // UP

    return btn_state;
}

// ---------------------------------------------------------------------------
// Touch input
// ---------------------------------------------------------------------------

// CoreS3 display: 320 x 240
//
// Game area  : 192x192 centered at (160, 100)  (scale 1.5x, pivot 160,100)
// Left strip : x=[0,64]  (black border for D-pad)
// Right strip: x=[256,320] (black border for action buttons)
// Bottom strip: y=[200,240] (black border for START)
//
//   D-pad    : centre=(45, 180), deadzone=12
//   START    : rect x=[140,180], y=[210,228]
//   O button : centre=(295, 155), radius=22
//   X button : centre=(250, 195), radius=22
//
// Bit assignments:
//   bit 0=LEFT  bit 1=RIGHT  bit 2=UP  bit 3=DOWN
//   bit 4=O(ACTION1)  bit 5=X(ACTION2)  bit 6=START(PAUSE)

// ---------------------------------------------------------------------------
// 仮想コントローラーの描画（画面端へ移動）
// ---------------------------------------------------------------------------
void draw_virtual_gamepad()
{
    if (g_faces.present.load()) return;
    uint16_t color_dpad = M5.Display.color565(180, 180, 180);
    uint16_t color_btn  = M5.Display.color565(220, 220, 220);

    // --- D-Pad (左端の黒帯エリアに寄せる) ---
    int cx = 35, cy = 180;
    M5.Display.drawRoundRect(cx - 15, cy - 35, 30, 30, 4, color_dpad); // UP
    M5.Display.drawRoundRect(cx - 15, cy + 5,  30, 30, 4, color_dpad); // DOWN
    M5.Display.drawRoundRect(cx - 35, cy - 15, 30, 30, 4, color_dpad); // LEFT
    M5.Display.drawRoundRect(cx + 5,  cy - 15, 30, 30, 4, color_dpad); // RIGHT
    M5.Display.drawCircle(cx, cy, 4, color_dpad); // CENTER

    // --- STARTボタン ---
    // さらに2ドット右、16ドット下
    int sx = 273, sy = 182;
    M5.Display.drawRoundRect(sx, sy, 45, 20, 4, color_dpad); 
    // Keep the touch fallback readable; 5x 'START' at size 1 was tiny.
    M5.Display.setCursor(sx + 10, sy + 3);
    M5.Display.setTextColor(color_dpad);
    M5.Display.setTextSize(2);
    M5.Display.print("ST");

    // --- ボリュームボタン (カーソルの上) ---
    // さらに2px下に移動
    int vx = 35;
    M5.Display.drawTriangle(vx, 56, vx - 10, 72, vx + 10, 72, color_dpad); // UP
    M5.Display.drawTriangle(vx, 102, vx - 10, 86, vx + 10, 86, color_dpad); // DOWN

    // --- アクションボタン (右上エリアに配置) ---
    uint16_t color_btn_O = g_held_O ? M5.Display.color565(50, 50, 50) : M5.Display.color565(180, 180, 180);
    uint16_t color_bg_O  = g_held_O ? M5.Display.color565(180, 180, 180) : TFT_BLACK;

    int ox = 295, oy = 50; // Oボタン
    M5.Display.fillCircle(ox, oy, 20, color_bg_O);
    M5.Display.drawCircle(ox, oy, 20, color_btn_O);
    M5.Display.drawCircle(ox, oy, 18, color_btn_O);
    M5.Display.drawCircle(ox, oy, 10, color_btn_O); // なかの〇をラインで

    uint16_t color_btn_X = g_held_X ? M5.Display.color565(50, 50, 50) : M5.Display.color565(180, 180, 180);
    uint16_t color_bg_X  = g_held_X ? M5.Display.color565(180, 180, 180) : TFT_BLACK;

    int xx = 295, xy = 126; // Xボタン
    M5.Display.fillCircle(xx, xy, 20, color_bg_X);
    M5.Display.drawCircle(xx, xy, 20, color_btn_X);
    M5.Display.drawCircle(xx, xy, 18, color_btn_X);
    // なかの×をラインで
    M5.Display.drawLine(xx - 7, xy - 7, xx + 7, xy + 7, color_btn_X);
    M5.Display.drawLine(xx - 7, xy + 7, xx + 7, xy - 7, color_btn_X);
}

// ---------------------------------------------------------------------------
// タッチ判定の調整（新しいボタン位置に追従）
// ---------------------------------------------------------------------------
uint16_t get_touch_state()
{
    uint16_t btn_state = 0;
    bool touch_O = false;
    bool touch_X = false;
    int min_dist_O = 999999;
    int min_dist_X = 999999;
    auto count = M5.Touch.getCount();

    for (int i = 0; i < count; i++) {
        auto detail = M5.Touch.getDetail(i);
        if (!detail.isPressed()) continue;

        int tx = detail.x;
        int ty = detail.y;

        // --- 左端エリア (D-Pad + Volume) ---
        if (tx < 120) {
            if (ty > 120) {
                int cx = 35, cy = 180; // 描画位置と合わせる
                int dx = tx - cx;
                int dy = ty - cy;
                
                if (dx*dx + dy*dy > 5*5) { // デッドゾーンを極小化して抜けを防止！
                    float angle = atan2f((float)dy, (float)dx) * (180.0f / (float)M_PI);
                    
                    // マリオ対策：上下左右のストライクゾーンを広め、斜めを狭くする
                    if (angle > -35.0f  && angle <  35.0f)   btn_state |= (1 << 1); // RIGHT
                    else if (angle >  145.0f || angle < -145.0f) btn_state |= (1 << 0); // LEFT
                    else if (angle >  55.0f  && angle <  125.0f) btn_state |= (1 << 3); // DOWN
                    else if (angle < -55.0f  && angle > -125.0f) btn_state |= (1 << 2); // UP
                    else {
                        if (angle >= 35.0f && angle <= 55.0f)     { btn_state |= (1 << 1); btn_state |= (1 << 3); }
                        if (angle >= 125.0f && angle <= 145.0f)   { btn_state |= (1 << 0); btn_state |= (1 << 3); }
                        if (angle <= -35.0f && angle >= -55.0f)   { btn_state |= (1 << 1); btn_state |= (1 << 2); }
                        if (angle <= -125.0f && angle >= -145.0f) { btn_state |= (1 << 0); btn_state |= (1 << 2); }
                    }
                }
            } else if (ty > 46 && ty <= 81) {
                btn_state |= (1 << 8); // VOL_UP
            } else if (ty > 81 && ty <= 120) {
                btn_state |= (1 << 7); // VOL_DOWN
            }
        }
        // --- STARTボタン ---
        // 新しい位置: x=271, y=162 -> さらに16ドット下へ
        else if (tx >= 250 && tx <= 320 && ty >= 161 && ty <= 211) {
            btn_state |= (1 << 6);
        }
        // --- アクションボタン (右上エリア) ---
          else if (tx >= 250 && ty < 160) {
            int dxO = tx - 295, dyO = ty - 50;
            int dxX = tx - 295, dyX = ty - 126;
            int dO = dxO*dxO + dyO*dyO;
            int dX = dxX*dxX + dyX*dyX;
            
            if (dO < 38*38) touch_O = true;
            if (dX < 38*38) touch_X = true;
            if (dO < min_dist_O) min_dist_O = dO;
            if (dX < min_dist_X) min_dist_X = dX;
            
            // Bダッシュジャンプ (意図的に真ん中を押した時だけ両方ON)
            if (tx >= 250 && tx <= 320 && ty >= 80 && ty <= 96) {
                touch_O = true;
                touch_X = true;
            }
        }
    }

    // O button long press logic (only toggle if touch is closer to O)
    bool active_O = touch_O && (min_dist_O <= min_dist_X);
    static uint32_t press_start_time_O = 0;
    static bool prev_active_O = false;
    static bool toggled_O_this_press = false;
    if (active_O) {
        if (!prev_active_O) {
            press_start_time_O = millis();
            toggled_O_this_press = false;
            // Immediate release upon touch if it's currently held
            if (g_held_O) {
                g_held_O = false;
                toggled_O_this_press = true;
            }
        } else if (!toggled_O_this_press && millis() - press_start_time_O >= 1000) {
            g_held_O = true;
            toggled_O_this_press = true;
        }
    } else {
        toggled_O_this_press = false;
    }
    prev_active_O = active_O;
    if (g_held_O || touch_O) btn_state |= (1 << 4);

    // X button long press logic
    bool active_X = touch_X && (min_dist_X <= min_dist_O);
    static uint32_t press_start_time_X = 0;
    static bool prev_active_X = false;
    static bool toggled_X_this_press = false;
    if (active_X) {
        if (!prev_active_X) {
            press_start_time_X = millis();
            toggled_X_this_press = false;
            // Immediate release upon touch if it's currently held
            if (g_held_X) {
                g_held_X = false;
                toggled_X_this_press = true;
            }
        } else if (!toggled_X_this_press && millis() - press_start_time_X >= 1000) {
            g_held_X = true;
            toggled_X_this_press = true;
        }
    } else {
        toggled_X_this_press = false;
    }
    prev_active_X = active_X;
    if (g_held_X || touch_X) btn_state |= (1 << 5);

    return btn_state;
}

// ---------------------------------------------------------------------------
// Audio task
// ---------------------------------------------------------------------------

static void audio_task(void *pvParameters)
{
    const int sample_count = 256;
    int16_t *audio_buf[2];
    audio_buf[0] = (int16_t *)malloc(sample_count * sizeof(int16_t));
    audio_buf[1] = (int16_t *)malloc(sample_count * sizeof(int16_t));
    if (!audio_buf[0] || !audio_buf[1]) {
        if (audio_buf[0]) free(audio_buf[0]);
        if (audio_buf[1]) free(audio_buf[1]);
        vTaskDelete(NULL);
        return;
    }

    int current_buf = 0;
    while (1) {
        if (g_audio_hold.load()) {
            memset(audio_buf[current_buf], 0, sample_count * sizeof(int16_t));
        } else {
            render_sounds(audio_buf[current_buf], sample_count);
        }

        while (!M5.Speaker.playRaw(audio_buf[current_buf], sample_count, 22050, false, 1, 0)) {
            vTaskDelay(pdMS_TO_TICKS(1));
        }
        current_buf = 1 - current_buf;
    }
}

// ---------------------------------------------------------------------------
// Emulator C interface stubs
// ---------------------------------------------------------------------------

void process_volume_controls(uint16_t current_btn) {
    static uint16_t global_last_btn = 0;
    uint16_t global_pressed = current_btn & ~global_last_btn;
    global_last_btn = current_btn;
    bool vol_changed = false;
    if (global_pressed & (1 << 8)) { g_volume = (g_volume > 239) ? 255 : g_volume + 16; vol_changed = true; }
    if (global_pressed & (1 << 7)) { g_volume = (g_volume <  16) ?   0 : g_volume - 16; vol_changed = true; }

    if (vol_changed) {
        M5.Speaker.setVolume(g_volume);
        M5.Speaker.tone(1000, 10);
        Preferences prefs;
        prefs.begin("ronto8", false);
        prefs.putInt("volume", g_volume);
        prefs.end();
    }
}

// The physical panel is autodetected; the original touch path is preserved.
static uint16_t poll_controller_input()
{
    const bool was_present = g_faces.present.load();
    g_faces.update();
    const bool is_present = g_faces.present.load();
    if (was_present != is_present) {
        if (is_present) clear_base_leds(); // Switch must be at G25, not the audio G15 position.
        M5.Display.fillScreen(TFT_BLACK);
        if (!g_emulator_ready) draw_browser();
        if (!is_present) draw_virtual_gamepad();
        Serial.printf("RONTO8 Faces Gamepad3: %s\n", is_present ? "attached" : "detached");
    }
    const uint16_t btn = is_present ? g_faces.buttons() : get_touch_state();
    const bool select_down = is_present && (btn & (1u << 9));
    if (select_down && !g_select_pressed_prev && !g_select_menu_open)
        g_select_menu_pending = true;
    g_select_pressed_prev = select_down;
    if (g_select_menu_open) return btn; // Physical key state for menu navigation.
    if (g_swallow_until_release) {
        if (btn == 0) g_swallow_until_release = false;
        return 0; // Do not leak A/B/SELECT that closed the menu into the game.
    }
    // Show a large, live key name in the existing ROM browser header.
    // This confirms that the button reached RONTO8 without requiring
    // a separate diagnostics program or a tiny-text serial console.
    if (!g_emulator_ready && is_present) {
        static uint16_t last_displayed_key = 0xFFFFu;
        if (btn != last_displayed_key) {
            last_displayed_key = btn;
            const uint16_t yellow = M5.Display.color565(253, 192, 0);
            M5.Display.fillRect(195, 0, 125, 28, yellow);
            M5.Display.setTextColor(TFT_BLACK, yellow);
            M5.Display.setTextSize(2);
            M5.Display.setCursor(202, 9);
            M5.Display.print(g_faces.keyLabel());
        }
    }
    return btn;
}

extern "C" void m5stack_update_input()
{
    M5.update();
    uint16_t current_btn = poll_controller_input();
    
    process_volume_controls(current_btn);

    static bool prev_held_O = false;
    static bool prev_held_X = false;
    if (g_emulator_ready && (g_held_O != prev_held_O || g_held_X != prev_held_X)) {
        prev_held_O = g_held_O;
        prev_held_X = g_held_X;
        draw_virtual_gamepad();
    }

    if (!g_emulator_ready) {
        g_emulator_ready = true;
        if (!g_audio_task_started) {
            g_audio_task_started = true;
            xTaskCreatePinnedToCore(audio_task, "audio_task", 4096, NULL, 5, NULL, 0);
            M5.Display.fillScreen(TFT_BLACK);
            draw_virtual_gamepad();
        }
    }
    
    extern uint16_t m_buttons[8];
    m_buttons[0] = (g_select_menu_open || g_select_menu_pending)
        ? 0 : (current_btn & ~(1u << 9));
}

extern "C" void m5stack_suspend_frame_buf(void) {}
extern "C" void m5stack_resume_frame_buf(void)  {}

// ---------------------------------------------------------------------------
// Rendering
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// レンダリングの超高速化と画面サイズの縮小
// ---------------------------------------------------------------------------
extern "C" void p8_render()
{
    if (!m_memory || !line_buffer[0]) return;
    uint8_t* vram = &m_memory[0x6000]; // VRAM starts at 0x6000
    
    xSemaphoreTake(doneSem, portMAX_DELAY);
    M5.update(); // SAFE ZONE for I2C
    const bool full = g_faces.present.load();
    const int dst_w = full ? kPhysicalWidth : kTouchGameSize;
    const int dst_h = full ? kPhysicalHeight : kTouchGameSize;
    static uint8_t map192[kTouchGameSize];
    static uint8_t map320[kPhysicalWidth];
    static uint8_t map240[kPhysicalHeight];
    static bool maps_ready = false;
    if (!maps_ready) {
        for (int i = 0; i < kTouchGameSize; ++i) map192[i] = (i * 128) / kTouchGameSize;
        for (int i = 0; i < kPhysicalWidth; ++i) map320[i] = (i * 128) / kPhysicalWidth;
        for (int i = 0; i < kPhysicalHeight; ++i) map240[i] = (i * 128) / kPhysicalHeight;
        maps_ready = true;
    }
    const uint8_t* xmap = full ? map320 : map192;
    const uint8_t* ymap = full ? map240 : map192;
    for (int y = 0; y < dst_h; y++) {
        const int src_y = ymap[y];
        for (int x = 0; x < dst_w; x++) {
            uint8_t c;
            const int src_x = xmap[x];
            if (src_x % 2 == 0) {
                c = vram[(src_y * 64) + (src_x / 2)] & 0x0F;
            } else {
                c = (vram[(src_y * 64) + (src_x / 2)] >> 4) & 0x0F;
            }
            line_buffer[render_idx][y * dst_w + x] = m_colors[c];
        }
    }
    
    g_frame_physical.store(full);
    xSemaphoreGive(flipSem);
}

// ---------------------------------------------------------------------------
// Splash screen
// ---------------------------------------------------------------------------

void show_ronto8_splash()
{
    // Arcade-style title in the native LCD resolution. The banner and wordmark
    // use only vector primitives so no extra texture asset is needed.
    const uint16_t gold = arcade_gold();
    M5.Display.fillScreen(gold);
    arcade_logo(92, 11, 12);
    M5.Display.setTextColor(TFT_BLACK, gold);
    M5.Display.setTextSize(4);
    M5.Display.setCursor(106, 99);
    M5.Display.print("RONTO8");
    M5.Display.setTextSize(2);
    M5.Display.setCursor(65, 137);
    M5.Display.print("CORE S3 EDITION");
    M5.Display.fillRect(36, 160, 248, 3, TFT_BLACK);
    M5.Display.setCursor(52, 169);
    M5.Display.print("PICO-8 GAME SYSTEM");
    M5.Display.fillRect(8, 213, 304, 2, TFT_BLACK);
    M5.Display.setCursor(73, 220);
    M5.Display.print("FEMTO8 / ZEPTO8");

    bool prompt_visible = false;
    while (true) {
        M5.update();
        g_faces.update();
        if (M5.Touch.getCount() > 0) break;
        if (g_faces.present.load() &&
            (g_faces.buttons() & ((1u << 4) | (1u << 6)))) break;

        const bool want_visible = (millis() / 550u) % 2u == 0u;
        if (prompt_visible != want_visible) {
            prompt_visible = want_visible;
            M5.Display.fillRect(30, 188, 260, 23, gold);
            if (prompt_visible) {
                M5.Display.fillRect(30, 188, 260, 23, TFT_BLACK);
                M5.Display.setTextSize(2);
                M5.Display.setTextColor(gold, TFT_BLACK);
                M5.Display.setCursor(g_faces.present.load() ? 55 : 72, 191);
                M5.Display.print(g_faces.present.load() ?
                                 "PRESS START BUTTON" : "TOUCH TO START");
            }
        }
        delay(30);
    }

    M5.Display.fillScreen(gold);
    M5.Display.setTextSize(2);
    M5.Display.setTextColor(TFT_BLACK, gold);
    M5.Display.setCursor(102, 112);
    M5.Display.print("LOADING...");
}

// ---------------------------------------------------------------------------
// ROM loader
// ---------------------------------------------------------------------------

// ROM loading uses p8_init_file_with_param (declared in p8_emu.h)

String get_browser_name(int index)
{
    if (index < 0 || index >= g_browser_count) return "";
    return String(g_browser_name_buf + g_browser_name_offsets[index]);
}

void load_selected_rom()
{
    String filename = get_browser_name(g_browser_cursor);
    String fullpath = g_browser_path + filename;

    M5.Display.fillScreen(TFT_BLACK);

    // SD.open() uses "/" as root, but fopen() (used by the parser) needs the
    // VFS mount point which is "/sd" by default with SD.begin().
    g_current_rom_path = "/sd" + fullpath;

    if (p8_init_file_with_param(g_current_rom_path.c_str(), NULL) == 0) {
        g_emulator_ready = true;
        // Clear the line buffers so the previous game's frame doesn't flash
        extern uint16_t *line_buffer[2];
        if (line_buffer[0]) memset(line_buffer[0], 0, kBufferPixels * sizeof(uint16_t));
        if (line_buffer[1]) memset(line_buffer[1], 0, kBufferPixels * sizeof(uint16_t));
    } else {
        g_emulator_init_failed = true;
    }
}

// ---------------------------------------------------------------------------
// Arduino entry points
// ---------------------------------------------------------------------------

void setup()
{
    auto cfg = M5.config();
    // Required by the M5Stack official CoreS3 + Faces Gamepad3 example.
    cfg.fallback_board = m5::board_t::board_M5StackCoreS3;
    M5.begin(cfg);
    // GPIO5 is the safe CoreS3 lane for Faces Bottom3 LEDs when its switch is G25.
    // Clear any retained white state even if Gamepad3 has not yet been detected.
    clear_base_leds();
    g_faces.begin();
    Serial.printf("RONTO8 Faces Gamepad3 on I2C 0x08: %s\n",
                  g_faces.present.load() ? "READY" : "not detected (touch mode)");
    
    Preferences prefs;
    prefs.begin("ronto8", false);
    g_volume = prefs.getInt("volume", 255);
    prefs.end();

    M5.Speaker.begin();
    M5.Speaker.setVolume(g_volume);
    M5.Speaker.setChannelVolume(0, 255); // Ensure channel 0 is at max volume

    M5.Display.fillScreen(TFT_BLACK);

    line_buffer[0] = (uint16_t*)heap_caps_malloc(kBufferPixels * sizeof(uint16_t), MALLOC_CAP_SPIRAM | MALLOC_CAP_8BIT);
    line_buffer[1] = (uint16_t*)heap_caps_malloc(kBufferPixels * sizeof(uint16_t), MALLOC_CAP_SPIRAM | MALLOC_CAP_8BIT);
    if (!line_buffer[0] || !line_buffer[1]) {
        M5.Display.fillScreen(TFT_BLACK);
        M5.Display.setTextColor(TFT_RED, TFT_BLACK);
        M5.Display.setTextSize(2);
        M5.Display.setCursor(12, 68);
        M5.Display.println("VIDEO BUFFER ERROR");
        Serial.println("ERROR: cannot allocate PSRAM RGB565 buffers");
        for (;;) delay(1000);
    }
    
    flipSem = xSemaphoreCreateBinary();
    doneSem = xSemaphoreCreateBinary();
    xSemaphoreGive(doneSem);
    xTaskCreatePinnedToCore(flipTask, "flipTask", 4096, NULL, configMAX_PRIORITIES - 2, NULL, 1);
    
    M5.Display.setColorDepth(16);
    M5.Display.setSwapBytes(true);


    // [重要] 速度を劇的に上げるため、超高速なSRAMにバッファを確保！
    p8_sprite.setPsram(false);
    p8_sprite.createSprite(128, 128);

    // CoreS3 SD card CS pin = 4
    SPI.begin(36, 35, 37, 4);
    if (!SD.begin(4, SPI, 25000000)) {
        M5.Display.println("SD Card Mount Failed");
        while (1) { delay(100); }
    }

    g_browser_name_buf     = (char*)    malloc(MAX_BROWSER_BUF_SIZE);
    g_browser_name_offsets = (uint16_t*)malloc(MAX_BROWSER_ENTRIES * sizeof(uint16_t));
    g_browser_is_dir       = (bool*)    malloc(MAX_BROWSER_ENTRIES * sizeof(bool));

    show_ronto8_splash();

    M5.Display.fillScreen(TFT_BLACK); // スプラッシュ後に一度だけ全体をクリア
    scan_browser_directory(g_browser_path);
    draw_browser();
    draw_virtual_gamepad(); // コントローラーの描画は最初の一回だけ
}


/* Gamepad3 SELECT menu (physical buttons):
 * SELECT opens/closes, UP/DOWN choose, LEFT/RIGHT adjust selected volume,
 * A/START activates, B cancels. It is also available in the ROM browser,
 * where the restart entry is intentionally omitted.
 */
// Menu order during play: CONTINUE -> RESET GAME -> RESET CORE -> VOLUME.
// The ROM browser has no active game, so only RESET GAME is hidden.
static int select_menu_count() { return g_emulator_ready ? 4 : 3; }
static int select_game_reset_row() { return g_emulator_ready ? 1 : -1; }
static int select_core_reset_row() { return g_emulator_ready ? 2 : 1; }
static int select_volume_row() { return g_emulator_ready ? 3 : 2; }

static void persist_menu_volume()
{
    if (!g_menu_volume_dirty) return;
    Preferences prefs;
    if (prefs.begin("ronto8", false)) {
        prefs.putInt("volume", g_volume);
        prefs.end();
    }
    g_menu_volume_dirty = false;
}

static void draw_select_menu()
{
    const uint16_t gold = arcade_gold();
    M5.Display.fillScreen(gold);
    arcade_title_bar(g_emulator_ready ? "GAME MENU" : "SYSTEM MENU", "R9");

    const int rows = select_menu_count();
    for (int i = 0; i < rows; ++i) {
        const int y = 44 + i * 40;
        const bool chosen = (i == g_menu_selected);
        const uint16_t bg = chosen ? TFT_BLACK : gold;
        const uint16_t fg = chosen ? gold : TFT_BLACK;
        M5.Display.fillRoundRect(12, y, 296, 35, 4, bg);
        M5.Display.drawRoundRect(12, y, 296, 35, 4, TFT_BLACK);
        M5.Display.setTextColor(fg, bg);
        M5.Display.setTextSize(2);
        M5.Display.setCursor(22, y + 9);
        if (i == 0) M5.Display.print("CONTINUE");
        else if (i == select_game_reset_row()) M5.Display.print("RESET GAME");
        else if (i == select_core_reset_row()) M5.Display.print("RESET CORE");
        else if (i == select_volume_row()) {
            M5.Display.printf("VOLUME %3d%%", (g_volume * 100 + 127) / 255);
            // Ten-bar hardware-style volume meter; always clear at each redraw.
            const int lit = (g_volume * 10 + 127) / 255;
            for (int bar = 0; bar < 10; ++bar) {
                const uint16_t barcolor = bar < lit ? fg :
                     (chosen ? M5.Display.color565(80, 80, 80)
                             : M5.Display.color565(245, 226, 156));
                M5.Display.fillRect(206 + bar * 9, y + 12, 7, 13, barcolor);
            }
        }
    }
    M5.Display.fillRect(8, 205, 304, 3, TFT_BLACK);
    M5.Display.fillRect(0, 212, 320, 28, TFT_BLACK);
    M5.Display.setTextColor(gold, TFT_BLACK);
    M5.Display.setTextSize(2);
    M5.Display.setCursor(8, 219);
    M5.Display.print(g_menu_selected == select_volume_row()
        ? "LEFT/RIGHT:VOL B:BACK" : "A:OK B:BACK SEL:CLOSE");
}

static void begin_select_menu()
{
    g_select_menu_pending = false;
    g_select_menu_open = true;
    g_menu_selected = 0;
    g_menu_volume_dirty = false;
    g_menu_prev_btn = (1u << 9); // Opening SELECT must be released before toggling.
    g_audio_hold.store(true);
    // SELECT is seen in p8_post_flip, after p8_render queued a DMA frame.
    // Wait for that last game's frame before drawing the menu.
    if (doneSem) {
        xSemaphoreTake(doneSem, portMAX_DELAY);
        M5.Display.waitDMA();
        xSemaphoreGive(doneSem);
    }
    draw_select_menu();
}

static void close_select_menu()
{
    persist_menu_volume();
    g_select_menu_open = false;
    g_select_menu_pending = false;
    g_swallow_until_release = true;
    g_audio_hold.store(false);
    if (!g_emulator_ready) {
        draw_browser();
        draw_virtual_gamepad();
    } else {
        // Game framebuffer is redrawn on the next p8_step/p8_flip.
        M5.Display.fillScreen(TFT_BLACK);
    }
    m_start_time = 0; // Avoid a large game-time delta from the paused menu.
}

static void adjust_select_volume(int delta)
{
    const int next = constrain(g_volume + delta, 0, 255);
    if (next == g_volume) return;
    g_volume = next;
    g_menu_volume_dirty = true;
    M5.Speaker.setVolume(g_volume);
    draw_select_menu();
}

static void update_select_menu()
{
    M5.update();
    const uint16_t btn = poll_controller_input();
    const uint16_t pressed = btn & ~g_menu_prev_btn;
    g_menu_prev_btn = btn;

    if (pressed & ((1u << 5) | (1u << 9))) { // B or SELECT
        close_select_menu();
        return;
    }
    if (pressed & (1u << 2)) { // UP
        g_menu_selected = (g_menu_selected + select_menu_count() - 1) % select_menu_count();
        draw_select_menu();
    } else if (pressed & (1u << 3)) { // DOWN
        g_menu_selected = (g_menu_selected + 1) % select_menu_count();
        draw_select_menu();
    }
    if (g_menu_selected == select_volume_row()) {
        if (pressed & (1u << 0)) adjust_select_volume(-16);
        if (pressed & (1u << 1)) adjust_select_volume(+16);
    }
    if (pressed & ((1u << 4) | (1u << 6))) { // A or START
        if (g_menu_selected == 0) {
            close_select_menu();
        } else if (g_menu_selected == select_volume_row()) {
            // A on volume increases it; LEFT/RIGHT also work.
            adjust_select_volume(+16);
        } else if (g_menu_selected == select_core_reset_row()) {
            // Explicit user selection: reboot only the CoreS3 MCU.
            // Save pending volume preference; do not format or erase storage.
            persist_menu_volume();
            g_audio_hold.store(true);
            M5.Display.fillScreen(TFT_BLACK);
            M5.Display.setTextColor(TFT_WHITE, TFT_BLACK);
            M5.Display.setTextSize(2);
            M5.Display.setCursor(43, 104);
            M5.Display.println("RESTARTING CORE...");
            M5.Display.waitDMA();
            delay(100);
            ESP.restart();
            return; // ESP.restart does not normally return.
        } else if (g_menu_selected == select_game_reset_row() &&
                   g_emulator_ready && g_current_rom_path.length() != 0) {
            // p8_restart() longjmps through a returned stack frame on this
            // CoreS3 build. Use a fresh cartridge/Lua reload instead.
            M5.Display.fillScreen(TFT_BLACK);
            M5.Display.setTextColor(TFT_WHITE, TFT_BLACK);
            M5.Display.setTextSize(2);
            M5.Display.setCursor(65, 100);
            M5.Display.println("RESTARTING...");
            delay(25); // Allow audio worker to observe g_audio_hold before reloading.
            const int result = p8_reload_file_with_param(g_current_rom_path.c_str(), NULL);
            g_emulator_init_failed = (result != 0);
            if (result == 0) {
                if (line_buffer[0]) memset(line_buffer[0], 0, kBufferPixels * sizeof(uint16_t));
                if (line_buffer[1]) memset(line_buffer[1], 0, kBufferPixels * sizeof(uint16_t));
            }
            close_select_menu();
        }
    }
    // The menu does not need the full game loop's frame rate.
    delay(8);
}

void process_volume_controls(uint16_t current_btn);

void loop()
{
    if (g_select_menu_open) {
        update_select_menu();
        return;
    }
    if (g_select_menu_pending) {
        begin_select_menu();
        return;
    }
    if (g_emulator_init_failed) {
        static bool shown = false;
        if (!shown) {
            shown = true;
            M5.Display.fillScreen(TFT_BLACK);
            M5.Display.setCursor(0, 0);
            M5.Display.println("ROM init failed.");
            M5.Display.println("Please reset and choose another cart.");
        }
        return;
    }

    if (!g_emulator_ready) {
        M5.update();
        uint16_t current_btn = poll_controller_input();
        if (g_select_menu_pending) {
            begin_select_menu();
            return;
        }

        process_volume_controls(current_btn);

        // ROM browser: debounce with edge detection + repeat (long-press)
        static uint16_t last_btn = 0;
        static uint32_t hold_timer = 0;
        uint16_t pressed = current_btn & ~last_btn; // 押した瞬間の判定

        // リピート（長押し）の処理を追加
        if (current_btn == last_btn && current_btn != 0) {
            if (millis() - hold_timer > 250) { // 250ms長押しし続けたら
                pressed = current_btn;         // 再度押したことにして
                hold_timer = millis() - 200;   // 50ms間隔で連射させる
            }
        } else {
            hold_timer = millis(); // 離したり別のボタンを押したらタイマーリセット
        }
        last_btn = current_btn;

        bool cursor_moved = false;
        if (pressed & (1 << 3)) { // DOWN
            if (g_browser_cursor < g_browser_count - 1) {
                g_browser_cursor++;
                cursor_moved = true;
            }
        }
        if (pressed & (1 << 2)) { // UP
            if (g_browser_cursor > 0) {
                g_browser_cursor--;
                cursor_moved = true;
            }
        }
        if (pressed & (1 << 1)) { // RIGHT (Page Down)
            if (g_browser_cursor < g_browser_count - 1) {
                g_browser_cursor += kBrowserRows;
                if (g_browser_cursor >= g_browser_count) g_browser_cursor = g_browser_count - 1;
                cursor_moved = true;
            }
        }
        if (pressed & (1 << 0)) { // LEFT (Page Up)
            if (g_browser_cursor > 0) {
                g_browser_cursor -= kBrowserRows;
                if (g_browser_cursor < 0) g_browser_cursor = 0;
                cursor_moved = true;
            }
        }
        if (cursor_moved) {
            M5.Speaker.setVolume(g_volume / 2);
            M5.Speaker.tone(1500, 8); // ファイル選択時のクリック音 (音量50%)
            delay(10);
            M5.Speaker.setVolume(g_volume);
            draw_browser();
        }
        if (pressed & (1 << 5)) { // X = back
            if (g_browser_path != "/") {
                int last_slash = g_browser_path.lastIndexOf('/', g_browser_path.length() - 2);
                if (last_slash >= 0) {
                    g_browser_path = g_browser_path.substring(0, last_slash + 1);
                    if (g_depth > 0) g_depth--;
                    scan_browser_directory(g_browser_path);
                    g_browser_cursor = g_cursor_history[g_depth];
                    draw_browser();
                }
            }
        }
        if ((pressed & (1 << 4)) || (pressed & (1 << 6))) { // O or START = enter
            if (g_browser_is_dir[g_browser_cursor]) {
                if (g_depth < 9) {
                    g_cursor_history[g_depth] = g_browser_cursor;
                    g_depth++;
                }
                g_browser_path += get_browser_name(g_browser_cursor) + "/";
                scan_browser_directory(g_browser_path);
                draw_browser();
            } else {
                load_selected_rom();
            }
        }

    } else if (g_emulator_ready && !g_audio_task_started) {
        g_audio_task_started = true;
        xTaskCreatePinnedToCore(audio_task, "audio_task", 4096, NULL, 5, NULL, 0);
        M5.Display.fillScreen(TFT_BLACK);
        draw_virtual_gamepad();
    } else {
        // Game running. SELECT is observed by m5stack_update_input()
        // during p8_step(); present the menu after stepping returns.
        p8_step();
        if (g_select_menu_pending) begin_select_menu();
    }}