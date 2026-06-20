import re

def optimize_p8_tables(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # Get __lua__ section
    lua_match = re.search(r'(__lua__\n)(.*?)(\n__(?:gfx|gff|map|sfx|music|label)__|$)', content, re.DOTALL)
    if not lua_match:
        print("No lua section found.")
        return

    lua_header = lua_match.group(1)
    lua_code = lua_match.group(2)

    # 1. 毎フレーム・毎関数アロケートされるテーブル定義をファイル最上部（グローバル）に移動
    globals_definition = """
-- CONSTANT TABLES FOR MEMORY OPTIMIZATION
g_power_up_sprites = { boulder = 1, sniper = 5, paddle = 2, magnet = 3, multiball = 4, threepeat = 6, expansion = 7, gravity_flip = 8, no_aim = 17, random_aim = 18, half_pts = 19, rock_drop = 20, partial_aim = 21, blind_peg = 22, peg_shuffle = 23, ball_start = 24, reshoot = 9, peg_mirage = 25, wobble_aim = 26, ball_move = 10 }
g_special_hues = { boulder = 4, sniper = 14, paddle = 6, magnet = 13, multiball = 10, threepeat = 3, expansion = 2, gravity_flip = 0, rock_drop = 8, reshoot = 7 }
g_tile_map = { [1] = 1, [2] = 5, [3] = 2, [4] = 3, [5] = 4, [6] = 6, [7] = 7, [8] = 8, [9] = 9, [10] = 10, [11] = 17, [12] = 18, [13] = 19, [14] = 20, [15] = 21, [16] = 22, [17] = 23, [18] = 24, [19] = 25, [20] = 26 }
g_const_angles = {0.25, 0.35, 0.45, 0.65, 0.85, 1.05, 1.15, 1.25}
g_multiball_angles = {-0.15, 0, 0.15}
g_multiball_radii = {2, 3, 4}
"""

    # 挿入位置：先頭の変数の下（v_apu = nil の直後）
    insert_pos = lua_code.find("v_apu = nil\n")
    if insert_pos != -1:
        insert_end = insert_pos + len("v_apu = nil\n")
        lua_code = lua_code[:insert_end] + globals_definition + lua_code[insert_end:]

    # 2. 各所の一時アロケーションコードを置換
    
    # (a) power_up_sprites
    lua_code = re.sub(
        r'local\s+power_up_sprites\s*=\s*\{[^}]*\}',
        'local power_up_sprites = g_power_up_sprites',
        lua_code
    )

    # (b) special_hues
    lua_code = re.sub(
        r'local\s+special_hues\s*=\s*\{[^}]*\}',
        'local special_hues = g_special_hues',
        lua_code
    )

    # (c) tile_map
    lua_code = re.sub(
        r'local\s+tile_map\s*=\s*\{[^}]*\}',
        'local tile_map = g_tile_map',
        lua_code
    )

    # (d) angles = {0.25, ...}
    lua_code = re.sub(
        r'local\s+angles\s*=\s*\{0\.25,\s*0\.35,\s*0\.45,\s*0\.65,\s*0\.85,\s*1\.05,\s*1\.15,\s*1\.25\}',
        'local angles = g_const_angles',
        lua_code
    )

    # (e) angles = {-0.15, 0, 0.15}
    lua_code = re.sub(
        r'local\s+angles\s*=\s*\{-0\.15,\s*0,\s*0\.15\}',
        'local angles = g_multiball_angles',
        lua_code
    )

    # (f) radii = {2, 3, 4}
    lua_code = re.sub(
        r'local\s+radii\s*=\s*\{2,\s*3,\s*4\}',
        'local radii = g_multiball_radii',
        lua_code
    )

    # 3. draw_functions のグローバル化（_draw関数が大きいため、毎回アロケートされるのを防ぐ）
    # `local draw_functions = { ... }` を `g_draw_functions = { ... }` に置き換える
    lua_code = re.sub(
        r'local\s+draw_functions\s*=\s*\{',
        'g_draw_functions = {',
        lua_code
    )
    lua_code = re.sub(
        r'draw_functions\[v_gst\]',
        'g_draw_functions[v_gst]',
        lua_code
    )

    # __lua__ セクションを再構築
    new_content = content[:lua_match.start(2)] + lua_code + content[lua_match.end(2):]

    with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
        f.write(new_content)

    print("Successfully optimized table allocations in pegball-3_min.p8")

if __name__ == "__main__":
    optimize_p8_tables("g:/PC8/pegball-3_min.p8")
