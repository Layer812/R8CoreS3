import re

# 安全な変数・関数名の置換マッピング定義
# 文字列値として使用されている可能性が高い単語（classic, pause, powerupなど）は除外している
REPLACEMENTS = {
    "active_power_up": "v_apu",
    "game_state": "v_gst",
    "special_physics": "v_spp",
    "points_per_shot": "v_pps",
    "stage_complete_pending": "v_scp",
    "aim_angle": "v_aang",
    "goal_pegs_hit_total": "v_gpht",
    "balls_remaining": "v_brem",
    "power_ups_enabled": "v_pue",
    "stuck_frames": "v_stkf",
    "total_points": "v_tpts",
    "is_fired": "v_isf",
    "min_distance": "v_mdis",
    "peg_data": "v_pd",
    "power_choices": "v_pch",
    "random_aim_direction": "v_rad",
    "current_index": "v_cidx",
    "total_points_per_stage": "v_tpps",
    "power_peg_reference": "v_ppr",
    "active_balls": "v_ab",
    "record_message": "v_rm",
    "score_bar_sfx_playing": "v_sbsp",
    "current_power_pool": "v_cpp",
    "update_peg_hit_count": "f_uphc",
    "valid_position": "v_vp",
    "last_mode": "v_lm",
    "current_power_up": "v_cpu",
    "power_peg_reload_counter": "v_pprc",
    "basic_pegs_hit_total": "v_bpht",
    "bonus_peg_hits_per_shot": "v_bphps",
    "partial_aim_initialized": "v_pai",
    "generate_unique_choices": "f_guc",
    "selected_mode": "v_sm",
    "time_elapsed_frame_counter": "v_tefc",
    "expansion_active": "v_expa",
    "expansion_locked_x": "v_elx",
    "expansion_locked_y": "v_ely",
    "drops_remaining": "v_drem",
    "peg_config": "v_pcf",
    "ball_start_frames": "v_bsf",
    "gravity_sfx_playing": "v_gsp",
    "time_elapsed": "v_te",
    "records_checked": "v_rc",
    "aim_increment": "v_ainc",
    "generate_pegs": "f_gpegs",
    "time_boost": "v_tbst",
    "easter_ball": "v_ebl",
    "big_head": "v_bhd",
    "gravity_sfx_channel": "v_gsc",
    "format_time_elapsed": "f_fte",
    "deactivate_power_up": "f_dp",
    "reshoot_timer": "v_rt",
    "stage_message": "v_smg",
    "detect_and_handle_stuck_ball": "f_dhsb",
    "paddlex": "v_px",
    "randomization_frames": "v_rf",
    "points_finalized": "v_pf",
    "rock_drop_active": "v_rda",
    "check_valid_position": "f_cvp",
    "mirage_pegs": "v_mp",
    "nearest_peg": "v_npeg",
    "initialize_pegs": "f_ipegs",
    "stuck_tolerance": "v_st",
    "check_and_update_records": "f_caur",
    "cleared_this_stage": "v_cts",
    "collision_occurred": "v_co",
    "grav_timer": "v_gt",
    "mid_power_pool": "v_mpp",
    "reset_per_shot_counters": "f_rpsc",
    "basic_pegs_hit_per_shot": "v_bhps",
    "goal_pegs_hit_per_shot": "v_ghps",
    "expansion_sfx_playing": "v_esp",
    "initialize_game": "f_igame",
    "balls_earned": "v_be",
    "finalize_shot_points": "f_fsp",
    "custom_activate": "f_cact",
    "draw_aiming_reticle": "f_dar",
    "shuffle_active_pegs": "f_sapegs",
    "rock_drop_activated": "v_rdac",
    "attraction_strength": "v_as",
    "reset_counters": "f_rcnt",
    "base_increment": "v_bi",
    "peg_type": "v_pt",
    "draw_ball_chamber": "f_dbc",
    "draw_ball_counter": "f_dbcnt",
    "custom_deactivate": "f_cdeact",
    "lowest_min": "v_lm_min",
    "play_music": "f_pm"
}

def minify_p8(input_path, output_path):
    with open(input_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # Get __lua__ section
    lua_match = re.search(r'(__lua__\n)(.*?)(\n__(?:gfx|gff|map|sfx|music|label)__|$)', content, re.DOTALL)
    if not lua_match:
        print("No lua section found.")
        return

    lua_header = lua_match.group(1)
    lua_code = lua_match.group(2)

    # 1. コメント削除 (行頭から始まるコメント行のみ削除)
    lines = lua_code.splitlines()
    cleaned_lines = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("--"):
            # コメント行は削除
            continue
        cleaned_lines.append(line)
    
    lua_code = "\n".join(cleaned_lines)

    # 2. 変数・関数名の置換
    # 単語境界 (\b) を用いて、部分一致による誤置換を防ぐ
    for original, replacement in REPLACEMENTS.items():
        pattern = r'\b' + re.escape(original) + r'\b'
        lua_code = re.sub(pattern, replacement, lua_code)

    # __lua__ セクションを再構築
    new_content = content[:lua_match.start(2)] + lua_code + content[lua_match.end(2):]

    with open(output_path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(new_content)

    print(f"Minified P8 written to {output_path}")

if __name__ == "__main__":
    minify_p8("g:/PC8/pegball-3.p8", "g:/PC8/pegball-3_min.p8")
