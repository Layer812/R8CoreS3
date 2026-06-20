pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--pegball--
--by maxosirus and dinoboy

local game_state = "start_screen"
last_mode = nil
power_ups_enabled = true 
local music_playing = false
current_power_up = nil
active_power_up = nil

function _init()
    initialize_game()
    initialize_pegs()
    active_power_up = nil
    cartdata("maxosirus_pegball_data")

    local data_defaults = {
    [0] = 0,  -- overflow
    [1] = 0,  -- total_points
    [3] = 0,  -- lowest_min
    [4] = 0,  -- lowest_sec
    [5] = 0,  -- 100% stage
    [6] = 0,  -- overflow_dis
    [7] = 0,  -- total_points_dis
    [8] = 0,  -- lowest_min_dis
    [9] = 0,  -- lowest_sec_dis
    [10] = 0, -- 100% stage_dis
				[11] = 0, -- stage_reach
				[12] = 0  -- stage_reach_dis
				}
				
				for key, value in pairs(data_defaults) do
				    if dget(key) == 0 then
				        dset(key, value)
				    end
				end
end

function _update60()
 if game_state == "start_screen" then
   
   play_music()
   
   if btnp(⬆️) then
       power_ups_enabled = not power_ups_enabled
   elseif btnp(➡️) then
       music(-1) 
       music_playing = false
       initialize_game()
       initialize_pegs()
       cheat_modes()
       reset_counters()
       points_per_shot = 0
       if power_ups_enabled then
         game_state = "power_choice"
       else
         game_state = "classic"
       end
       last_mode = "classic" 
   elseif btnp(⬅️) then
       music(-1) 
       music_playing = false
       initialize_game()
       initialize_pegs()
       cheat_modes()
       reset_counters()
       points_per_shot = 0
       if power_ups_enabled then
         game_state = "power_choice"
       else
         game_state = "time_trial"
       end
       last_mode = "time_trial" 
   elseif btnp(⬇️) then
   				game_state = "how_to_1"
   elseif btnp(❎) and btnp(🅾️) then
   				game_state = "easter_egg"
   end
 
 elseif game_state == "power_choice" then
    if randomization_frames > 0 then
        sfx(0)
        generate_power_choices() 
        randomization_frames -= 1
    else
        if btnp(⬆️) then
            selected_mode = 1
            current_power_pool = power_choices.high 
            game_state = last_mode
        elseif btnp(➡️) then
            selected_mode = 2
            current_power_pool = power_choices.mid 
            game_state = last_mode
        elseif btnp(⬅️) then
            selected_mode = 3
            current_power_pool = power_choices.low 
            game_state = last_mode
        elseif btnp(❎) then
            selected_mode = 4
            current_power_pool = power_choices.overdrive 
            game_state = last_mode
        elseif btnp(🅾️) then
            selected_mode = 5
            current_power_pool = power_choices.gauntlet 
            game_state = last_mode
        elseif btnp(⬇️) then
            selected_mode = 6
            current_power_pool = power_choices.potluck 
            game_state = last_mode
        end
    end
 
 elseif game_state == "how_to_1" then
   if btnp(⬆️) then
   		game_state = "how_to_2"
   end
 elseif game_state == "how_to_2" then
   if btnp(➡️) then
   		game_state = "how_to_3"
   elseif btnp(⬅️) then
     game_state = "how_to_1"
   end
 elseif game_state == "how_to_3" then
   if btnp(⬅️) then
   		game_state = "how_to_2"
   elseif btnp(❎) then
   		game_state = "start_screen"
   end  
 elseif game_state == "classic" or game_state == "time_trial" then
	  score_sound()
	  paddle()
	  update_time_elapsed()
	  balls_earned = 0
	  display_checks()
	  ball_fired()
  
	  if active_power_up and active_power_up.name == "gravity_flip" then
			  if ball.is_fired then
			    if grav_timer > 0 then
			      grav_timer -= 1 
			    else
			      game_state = "pause" 
			    end
			  end
			end
			
			if active_power_up and active_power_up.name == "reshoot" then
			  if reshoot_timer > 0 then
			    reshoot_timer -= 1
			  else
			    game_state = "pause"
			  end
			end
	  
	  if active_power_up and active_power_up.name == "ball_start" and not ball.is_fired then
	      ball_start_frames += 1
	      if ball_start_frames >= 15 then
	          local positions = {26, 51, 77, 102}
	          ball.x = positions[flr(rnd(#positions)) + 1] 
	          ball_start_frames = 0 
	      end
	  end
  
	  if ball.is_fired then
	      if ball.special_physics == "multiball" then
	          for b in all(active_balls) do
	              update_physics(b, peg_data)
	          end
	          detect_and_handle_stuck_ball(ball)
	      else
	          update_physics(ball, peg_data)
	          detect_and_handle_stuck_ball(ball)
	      end
	  end

	  if game_state == "classic" or game_state == "time_trial" then
	      last_mode = game_state
	  end

 		if balls_remaining <= 0 and goal_pegs_hit_total < 20 and not ball.is_fired then
     game_state = (last_mode == "classic") and "game_over" or "trial_lost"
    
		 elseif goal_pegs_hit_total == 20 then
			    if active_power_up then
			        if active_power_up.name == "multiball" then
			            local all_done = true
			            for b in all(active_balls) do
			                if not b.is_done then
			                    all_done = false
			                    break
			                end
			            end
			            if all_done and (ball.y > 128 or ball.stuck_frames >= 120) then
			                stage_complete_pending = true
			                game_state = "pause"
			            end
			        elseif active_power_up.name == "expansion" then
			            if (not expansion_active and (ball.y > 128 or ball.stuck_frames >= 120)) or ball.radius >= 20 then
			                stage_complete_pending = true
			                expansion_active = false 
			                game_state = "pause"
			            end
			        elseif active_power_up.name == "gravity_flip" then
															if ball.is_fired then
															    if grav_timer <= 0 then
															        stage_complete_pending = true
															        game_state = "pause"
															    elseif ball.y > 128 then
															        stage_complete_pending = true
															        game_state = "pause"
															    elseif ball.stuck_frames >= 120 then
															        stage_complete_pending = true
															        game_state = "pause"
															    elseif (ball.y > 128 or ball.stuck_frames >= 120) and btn(❎) and abs(ball.vy) < 0.1 then
															        stage_complete_pending = true
															        game_state = "pause"
															    end
															end    
											elseif active_power_up.name == "reshoot" then
											    if reshoot_timer <= 0 then
									      	stage_complete_pending = true
									       game_state = "pause"
									      elseif ball.y > 128 or ball.stuck_frames >= 120 then
									       stage_complete_pending = true
									       game_state = "pause"
									      end
			        elseif active_power_up.name == "rock_drop" then
											    if ball.is_fired then
											        local gravity_value = 0.08
											        local stuck_criteria = (abs(ball.vx) < 0.01 and abs(ball.vy - gravity_value) < 0.01)
											
											        if ball.y > 128 then
											            stage_complete_pending = true
											            game_state = "pause"
											        elseif ball.stuck_frames >= 120 and stuck_criteria then
											            stage_complete_pending = true
											            game_state = "pause"
											        end
											    end
			        elseif active_power_up.name == "magnet" then
			            if (ball.y > 128 or ball.stuck_frames >= 120) then
			                stage_complete_pending = true
			                game_state = "pause"
			            end        
			        elseif active_power_up.name == "boulder" then
			            if ball.y > 128 or ball.stuck_frames >= 120 then
			                stage_complete_pending = true
			                game_state = "pause"
			            end
			        else
			            if ball.y > 128 or ball.stuck_frames >= 120 then
			                stage_complete_pending = true
			                game_state = "pause"
			            end
			        end
			    else
			        if ball.y > 128 or ball.stuck_frames >= 120 then
			            stage_complete_pending = true
			            game_state = "pause" 
			        end
			    end
			end
 elseif game_state == "pause" then
  sfx(-1, gravity_sfx_channel)
  score_sound()
  power_up_on = false
  grav_timer = time_boost and 3660 or 1830
  reshoot_timer = time_boost and 3660 or 1830
  secret_hint = flr(rnd(10))+1
  
  if not points_finalized then
      finalize_shot_points()
      points_finalized = true
  end

  pause_frames += 1
  if pause_frames >= 90 then
      pause_frames = 0

      total_points_per_stage += points_per_shot
      if total_points + points_per_shot < 10000 then
          total_points += points_per_shot
      else
          local new_total = total_points + points_per_shot
          overflow += flr(new_total / 10000)
          total_points = new_total % 10000
      end

      ball_calc()
      
      display_checks()
      reload_ball()
      points_per_shot = 0
      points_finalized = false

      if stage_complete_pending then
          stage_complete_pending = false 
          game_state = (last_mode == "classic") and "stage_clear" or "time_trial_complete"
      else
          game_state = last_mode or "classic" 
      end
  end

 elseif game_state == "game_over" or game_state == "trial_lost" then
	    stop_sfx()
	    points_per_shot = 0
	    play_music()
	    
	    if not records_checked then
	        check_and_update_records()
	        records_checked = true 
	    end
	    
	    if btnp(❎) or btnp(🅾️) then
	        record_message, stage_message, records_checked  = nil, nil, false
	        reboot_prep()
	    end
	
	elseif game_state == "time_trial_complete" then
	    stop_sfx()
	    points_per_shot = 0
	    play_music()
	    total_clear()
	    
	    if not records_checked then
	        check_and_update_records()
	        records_checked = true 
	    end
	    
	    if btnp(❎) or btnp(🅾️) then
	        record_message, stage_message, records_checked  = nil, nil, false
	        reboot_prep()
	    end 
 
 elseif game_state == "stage_clear" then
     stop_sfx()
     points_per_shot = 0
     play_music()
     
     total_clear()
     
     if btnp(🅾️) then
         music(-1)
         stage_balls_earned()
         initialize_stage()
         initialize_pegs()
         reset_per_shot_counters()
         total_points_per_stage = 0
         points_per_shot = 0
         if not active_power_up then
             ball.hue = 6
         end
         stage += 1
         randomization_frames = 90
         stage_count += 1
         if stage_count % 3 == 0 and power_ups_enabled then
									  game_state = "power_choice"
									else
									  game_state = last_mode
									end
     end
 end
end

function _draw()
  cls(1)

  if game_state == "start_screen" then
 			draw_start_screen()
							  
  elseif game_state == "classic" or game_state == "time_trial" then
    
    draw_aim() 
    draw_ball()
    draw_pegs()
    

    if game_state == "classic" then
        print("score:" .. padhi .. overflow .. padlo .. total_points, 10, 0, 7)
    elseif game_state == "time_trial" then
        print("time:" .. format_time_elapsed(), 10, 0, 7)
    end
    print(points_per_shot, 10, 10, 7)
				print("pegballs:" .. balls_remaining, 75, 0, 7)
				
				if bonus_peg_hits_per_shot > 0 then print("x2!", 27, 10, 12) end
				if active_power_up and active_power_up.name == "half_pts" then print("x1/2!", 40, 10, 8) end
				if power_up_on then print("power peg!", 77, 10, 11) end
				
				rectfill(121, 10, 128, 128, 0)
				draw_walls()

    if active_power_up then
				    local power_up_sprites = {
				        boulder = 1,
				        sniper = 5,
				        paddle = 2,
				        magnet = 3,
				        multiball = 4,
				        threepeat = 6,
				        expansion = 7,
				        gravity_flip = 8,
				        no_aim = 17,
				        random_aim = 18,
				        half_pts = 19,
				        rock_drop = 20,
				        partial_aim = 21,
				        blind_peg = 22,
				        peg_shuffle = 23,
				        ball_start = 24,
				        reshoot = 9,
				        peg_mirage = 25,
				        wobble_aim = 26,
				        ball_move = 10
				    }
				
				    local sprite_id = power_up_sprites[active_power_up.name]
				    if sprite_id then
				        spr(sprite_id, 120, 0)
				    end
				    
				    if active_power_up.name == "paddle" then
								    rectfill(paddlex - 18, 126, paddlex + 18, 128, 7)
								elseif active_power_up.name == "gravity_flip" and ball.is_fired and grav_timer > 0 then
								    print("hold ❎   countdown: " .. flr(grav_timer / 60) .. " sec", 11, 120, 7)
								elseif active_power_up.name == "reshoot" and reshoot_timer > 0 then
								    print("countdown: " .. flr(reshoot_timer / 60) .. " sec", 12, 120, 7)
								elseif active_power_up.name == "ball_move" and not ball.is_fired then
								    print("move left ⬇️ ⬆️ move right", 13, 120, 7)
								end
				end
    
    draw_score_bar()
    draw_ball_chamber()
    draw_ball_counter()
    draw_multiplier()
  elseif game_state == "how_to_1" then
    draw_how_to_1()
  elseif game_state == "how_to_2" then
    draw_how_to_2()
  elseif game_state == "how_to_3" then
    draw_how_to_3()
  elseif game_state == "pause" then
    rectfill(121, 10, 128, 128, 0)
    draw_walls()
    draw_pegs()
    draw_ball_chamber()
    draw_ball_counter()
    draw_multiplier()
    
    if last_mode == "classic" then
      print("score:" .. padhi .. overflow .. padlo .. total_points, 10, 0, 7)
    else
      print("time:" .. format_time_elapsed(), 10, 0, 7)
    end
    draw_score_bar()
    draw_points_per_shot()
  
  else
    local draw_functions = {
				    power_choice = draw_power_choice,
				    game_over = draw_game_over_screen,
				    stage_clear = draw_stage_clear,
				    trial_lost = draw_trial_lost_screen,
				    time_trial_complete = draw_trial_done_screen,
				    easter_egg = function()
				        print("easter egg found!", 31, 20, 7)
				        print("-- cheat menu --", 20, 40, 7)
				        print("⬆️ start with 16 balls:", 5, 50, 7)
				        print("➡️ 'big head' mode:", 5, 60, 7)
				        print("⬅️ extended countdown:", 5, 70, 7)
				        print("press ⬇️ to exit", 31, 120, 7)
				        print("❎ and ⬇️ to reset records", 5, 80, 7) 
				
				        if btnp(⬆️) then easter_ball = not easter_ball end
				        print(easter_ball and "on!" or "off", 100, 50, easter_ball and 11 or 8)
				
				        if btnp(➡️) then big_head = not big_head end
				        print(big_head and "on!" or "off", 100, 60, big_head and 11 or 8)
				
				        if btnp(⬅️) then time_boost = not time_boost end
				        print(time_boost and "on!" or "off", 100, 70, time_boost and 11 or 8)
				
				        if btnp(⬇️) then game_state = "start_screen" end
				
				        if btnp(❎) and btnp(⬇️) then
				            for i = 0, 12 do
				                dset(i, 0)
				            end
				        end
				    end
				}
				
				if draw_functions[game_state] then draw_functions[game_state]() end

  end
end

easter_ball, big_head, time_boost, secret_hint  = false, false, false, nil

function cheat_modes()
 if easter_ball == true then
 				balls_remaining += 6
 end
end
-->8
-- page 1: drawing and initialization functions

function initialize_game()
  initialize_stage()
  balls_remaining, total_points, stage, stage_count, overflow = 10, 0, 1, 0, 0
  padhi, padlo, record_message, stage_message = "00000", "0000", nil, nil
  power_peg_hit, power_up_on, power_choices_generated, randomizing, records_checked = false, false, false, false, false
  paddlex, drops_remaining, grav_timer, reshoot_timer, randomization_frames, selected_mode = 64, 2, 1830, 1830, 90, nil
end

function initialize_stage()
  cls()
  ball.x, ball.y, ball.vx, ball.vy = 64, 10, 0, 0
  ball.is_fired, aim_angle = false, 0.75
  total_points_per_stage, points_finalized, recently_hit, goal_pegs_hit_total = 0, false, 0, 0
  ball.last_x, ball.last_y, ball.stuck_frames = ball.x, ball.y, 0
  power_peg_reload_counter, current_music, cleared_this_stage, basic_pegs_hit_total, secret_hint = 0, nil, false, 0, nil

  local special_hues = {
      boulder = 4, sniper = 14, paddle = 6, magnet = 13,
      multiball = 10, threepeat = 3, expansion = 2, gravity_flip = 0,
      rock_drop = 8, reshoot = 7
  }
  ball.hue = special_hues[ball.special_physics] or 6

  if ball.special_physics == "boulder" then
      ball.radius = 8
  elseif big_head then
      ball.radius = 5
  else
      ball.radius = 2
  end
end

function reboot_prep()
  reset_counters()
  points_per_shot, game_state, last_mode = 0, "start_screen", nil
end

function draw_start_screen()
  cls(2)
  print("pegball", 50, 5, 7)
  print("by maxosirus and dinoboy", 18, 15, 6)
  print("➡️ peg-a-thon", 65, 60, 7)
  print("peg rush ⬅️", 15, 60, 7)

  local power_ups_status = power_ups_enabled and "enabled" or "disabled"
  print("power-ups?", 43, 30, 7)
  print("⬆️", 58, 50, 7)
  print(power_ups_status, 47, 40, power_ups_enabled and 11 or 8)
  print("how to?", 49, 80, 7)
  print("⬇️", 58, 70, 7)

  local keys = power_ups_enabled and {0, 1, 3, 4, 5, 11} or {6, 7, 8, 9, 10, 12}
  local overflow, total_points, min, sec, full_clear, stage_reached = 
      dget(keys[1]), dget(keys[2]), dget(keys[3]), dget(keys[4]), dget(keys[5]), dget(keys[6])

  local pad = function(value)
    return (value < 1000 and "0" or "") .. (value < 100 and "0" or "") .. (value < 10 and "0" or "") .. value
  end

  print("hi score", 89, 90, 7)
  print((overflow + total_points == 0) and "no record" or pad(overflow) .. pad(total_points), 89, 100, 7)

  print("best time", 4, 90, 7)
  print((min > 0 or sec > 0) and "  " .. min .. "m " .. sec .. "s" or "no record", 4, 100, 7)

  print("stages:", 16, 115, 7)
  print("100% cleared= " .. full_clear, 48, 110, 7)
  print("hi reached= " .. stage_reached, 48, 120, 7)

  if easter_ball or big_head or time_boost then
    print("cheats", 50, 90, 12) print("active", 50, 100, 12)
		end

end

function draw_power_choice()
    cls(2)

    print("high risk/reward press ⬆️", 10, 2, 7)
    draw_tiles(power_choices.high, 18, 10)

    print("medium risk/reward press ➡️", 10, 21, 7)
    draw_tiles(power_choices.mid, 18, 29)

    print("low risk/reward press ⬅️", 10, 40, 7)
    draw_tiles(power_choices.low, 18, 48)

    print("overdrive press ❎", 10, 59, 7)
    print("all power-ups only", 20, 69, 7)

    print("gauntlet press 🅾️", 10, 79, 7)
    print("all curses only", 20, 89, 7)

    print("potluck press ⬇️", 10, 99, 7)
    print("all powers/curses active", 20, 109, 7)

    print("select again every 3 stages",11,120,7)
end

function draw_tiles(choices, x, y)
    for i, choice in ipairs(choices) do
        spr(get_tile_for_choice(choice), x + (i - 1) * 20, y)
    end
end

function get_tile_for_choice(choice)
    local tile_map = {
        [1] = 1, [2] = 5, [3] = 2, [4] = 3, [5] = 4, [6] = 6,
        [7] = 7, [8] = 8, [9] = 9, [10] = 10,
        [11] = 17, [12] = 18, [13] = 19, [14] = 20, [15] = 21,
        [16] = 22, [17] = 23, [18] = 24, [19] = 25, [20] = 26
    }
    return tile_map[choice] or 0
end

function draw_game_over_screen()
  cls(2)
  print("game over", 46, 10, 8)
  print("press 🅾️ or ❎ to restart", 15, 120, 7)
  print("stage reached: " .. stage, 32, 55, 7)
  print("time elapsed: " .. format_time_elapsed(), 25, 65, 7)
  print("total points: " .. padhi .. overflow .. padlo .. total_points, 20, 85, 7)
  local y = 95 
  if record_message then
      for i = 1, #record_message do
          print(record_message[i], 34, y, 10)
          y += 10 
      end
  end
  if stage_message then
      print(stage_message, 29, y, 10) 
  end
end

function draw_trial_done_screen()
  cls(2)
  print("peg rush completed!", 27, 10, 7)
  print("press ❎ or 🅾️ to restart", 15, 120, 7)
  print("time elapsed: " .. format_time_elapsed(), 23, 65, 7)
  print("total points: " .. padhi .. overflow .. padlo .. total_points, 19, 85, 7)
  local y = 34
  if record_message then
      for i = 1, #record_message do
          local msg = record_message[i]
          local msg_width = #msg * 4 
          local x = (128 - msg_width) / 2 
          print(msg, x, y, 10)
          y += 10
      end
  end
end

function draw_trial_lost_screen()
  cls(2)
  print("peg rush lost!", 35, 10, 8)
  print("try again", 44, 20, 8)
  print("press 🅾️ or ❎ to restart", 15, 120, 7)
end

function draw_stage_clear()
  cls(2)
  print("stage " .. stage .. " clear!", 39, 10, 11)
  print("new stage generating...", 23, 20, 7)
  print("total score = " .. padhi .. overflow .. padlo .. total_points, 21, 35, 7)
  print("points this stage = " .. total_points_per_stage, 15, 45, 7)
  print("balls at end of stage: " .. balls_remaining, 12, 55, 7)
  print("pegballs earned = " .. flr(total_points_per_stage / 1500), 25, 65, 7)
  print("press 🅾️ to begin next stage", 9, 85, 7)
  if flr(total_points_per_stage / 1500) + balls_remaining >= 16 then
      print("balls for next stage: 16 (max!)", 2, 75, 7)
  else
      print("balls for next stage: " .. flr(total_points_per_stage / 1500) + balls_remaining, 15, 75, 7)
  end  

  if secret_hint == 8 then
      print("hint: easter egg on start screen", 0, 95, 12)
  end

  if basic_pegs_hit_total == 29 then
      print("stage 100% cleared!", 28, 110, 7)
      print("+1 ball has already been added", 4, 120, 7)
  end
end

function draw_ball_chamber()
  rectfill(0, 0, 8, 128, 0)
  spr(48, 0, 2)
  for y = 8, 112, 8 do
    spr(49, 0, y)
  end
  spr(49, 0, 115)
  spr(50, 0, 119)
end

function draw_walls()
    rectfill(7, -1, 8, 130, 0)
    rectfill(120, -1, 121, 130, 0)
    rectfill(-1, -2, 129, -1, 0)
    for y = 8, 18, 9 do rectfill(120, y, 129, y + 1, 0) end

    local rect_height, gap_height = 3.45, 2
    for i = 0, 19 do
        local y_start = 127 - i * (rect_height + gap_height)
        rectfill(126, flr(y_start), 128, flr(y_start - rect_height), i < goal_pegs_hit_total and 9 or 7)
    end
end

function display_checks()
  padhi = overflow < 10 and "000" or overflow < 100 and "00" or overflow < 1000 and "0" or ""
  padlo = total_points < 10 and "000" or total_points < 100 and "00" or total_points < 1000 and "0" or ""
end

function draw_how_to_1()
    cls(1)
    
    print("⬅️ aim left   aim right ➡️", 15, 50, 7)
    print("hold 🅾️ for precise aim", 20, 60, 7)
    print("❎ to fire", 44, 70, 7)
    print("obj: clear all goal pegs", 10, 80, 7)
    spr(55, 110, 78) 
    print("hit   to earn double points!", 8, 90, 7)
    spr(57, 21, 88)
    print("hit   to for powers/curses!", 10, 100, 7)
    spr(58, 23, 98)
    print("hit   for some points too", 12, 110, 7)
    spr(56, 25, 108)
    print("press ⬆️ for next page", 18, 120, 7)
    if not ball.is_fired then
        ball.y, ball.vx, ball.vy, ball.is_fired = 10, 0, 0, false

        draw_aiming_reticle()
        draw_ball()
        handle_aiming()
        
        if btnp(❎) then
            ball.is_fired = true
            ball.vx = cos(aim_angle) * 2 
            ball.vy = sin(aim_angle) * 2 
        end
    else
        ball.vy += 0.1 
        ball.x += ball.vx
        ball.y += ball.vy

        if ball.y > 128 or ball.x < 0 or ball.x > 128 then
            ball.is_fired = false
            ball.x = 64
            ball.y = 10
        end
    end

    circfill(ball.x, ball.y, ball.radius or 2, ball.hue or 7)
end

function draw_how_to_2()
    cls(1)
    local instructions = {
        {2, 0, "low tier power-ups:"},
        {12, 9, "sniper, high velocity shot", 5},
        {12, 19, "threepeat, ball falls thrice", 6},
        {12, 29, "move the ball left or right", 10},
        {2, 37, "mid tier power-ups:"},
        {12, 46, "boulder, smashes thru pegs", 1},
        {12, 56, "paddle, keep the ball in play", 2},
        {12, 66, "multiball, 3 balls shoot out", 4},
        {12, 76, "expansion, grows and consumes", 7},
        {2, 84, "high tier power-ups:"},
        {12, 93, "magnet, seeks out goal pegs", 3},
        {12, 103, "gravity flip, hold ❎ to flip", 8},
        {12, 113, "reshoot, launch from each peg", 9}
    }

    for _, ins in pairs(instructions) do
        print(ins[3], ins[1], ins[2], 7)
        if ins[4] then spr(ins[4], 3, ins[2] - 2) end
    end
    print("prevous page ⬅️ ➡️ next page", 8, 120, 7)
end

function draw_how_to_3()
    cls(1)
    local instructions = {
        {2, 0, "curses:"},
        {12, 9, "no reticle, but can still aim", 17},
        {12, 19, "random aim, timing is key", 18},
        {12, 29, "partial aim increments", 21},
        {12, 39, "wobbly, but can still aim", 26},
        {12, 54, "half points this shot", 19},
        {12, 64, "ball moves randomly", 24},
        {12, 74, "drop like a rock, no bounce", 20},
        {12, 89, "all pegs look the same", 22},
        {12, 99, "a mirage of pegs", 25},
        {12, 109, "all pegs shuffle to new spots", 23}
    }

    for _, ins in pairs(instructions) do
        print(ins[3], ins[1], ins[2], 7)
        if ins[4] then spr(ins[4], 3, ins[2] - 2) end
    end
    print("prevous page ⬅️ ❎ start screen", 3, 120, 7)
end

-->8
-- page 2: ball mechanics

ball = {
 x = 64,
 y = 10,
 vx = 0,
 vy = 0,
 speed = 2,
 is_fired = false,
 radius = 2,
 hue = 6
}

ball_start_frames = 0

function ball_fired()
  if not ball.is_fired then
	   local aim_increment = btn(🅾️) and 0.001 or 0.008
	
	   if active_power_up and active_power_up.name == "random_aim" then
      if not random_aim_direction then
          random_aim_direction = 1 
      end

      local aim_change = 0.03 * random_aim_direction
      aim_angle += aim_change

      if aim_angle >= 1.25 then
          aim_angle = 1.25
          random_aim_direction = -1
      elseif aim_angle <= 0.25 then
          aim_angle = 0.25
          random_aim_direction = 1
      end
	
	   elseif active_power_up and active_power_up.name == "partial_aim" then
      local angles = {0.25, 0.35, 0.45, 0.65, 0.85, 1.05, 1.15, 1.25}

      if not partial_aim_initialized then
          aim_angle = 0.65
          partial_aim_initialized = true 
      end

      local current_index = 1
      for i, angle in ipairs(angles) do
          if abs(aim_angle - angle) < 0.05 then
              current_index = i
              break
          end
      end

      if btnp(⬅️) and current_index > 1 then
          current_index -= 1
      elseif btnp(➡️) and current_index < #angles then
          current_index += 1
      end

      aim_angle = angles[current_index]
	
	   elseif active_power_up and active_power_up.name == "wobble_aim" then
		    if not wobble_timer then wobble_timer = 0 end
		
		    wobble_timer += 0.05 
		
		    local base_increment = 0
		    if btn(⬅️) then
		        base_increment -= 0.008 
		    elseif btn(➡️) then
		        base_increment += 0.008 
		    end
		
		    local wobble_effect = sin(wobble_timer) * 0.02 
		
		    aim_angle += base_increment + wobble_effect
	   
	   elseif active_power_up and active_power_up.name == "ball_move" and ball.is_fired == false then
	       
      if btn(⬇️) then
          sfx(12)
          ball.x -= 1
      elseif btn(⬆️) then
          sfx(12)
          ball.x += 1
      end
      
      if ball.x <= 12 then
          ball.x = 12
      elseif ball.x >= 116 then
          ball.x = 116
      end
      
      if btn(⬅️) then
          aim_angle -= aim_increment
      elseif btn(➡️) then
          aim_angle += aim_increment
      end
      
	   else
      partial_aim_initialized = false

      if btn(⬅️) then
          aim_angle -= aim_increment
      elseif btn(➡️) then
          aim_angle += aim_increment
      end
	   end
	
	   aim_angle = mid(0.25, aim_angle, 1.25)
	
	   if btnp(❎) then
				    sfx(13)
				    if ball.special_physics == "multiball" then
				        local angles = {-0.15, 0, 0.15}
				        local radii = {2, 3, 4}
				        active_balls = {}
				        for i = 1, #angles do
				            add(active_balls, {
				                x = ball.x,
				                y = ball.y,
				                vx = cos(aim_angle + angles[i]) * ball.speed,
				                vy = sin(aim_angle + angles[i]) * ball.speed,
				                radius = radii[i],
				                is_fired = true,
				                last_x = ball.x,
				                last_y = ball.y,
				                stuck_frames = 0
				            })
				        end
				        ball.is_fired = true
				    else
				        ball.vx = cos(aim_angle) * ball.speed
				        ball.vy = sin(aim_angle) * ball.speed
				        ball.is_fired = true
				    end
				end
  end
end

function draw_aim()
	 if active_power_up and active_power_up.name == "no_aim" then 
	   return 
	 elseif not ball.is_fired then
	   draw_aiming_reticle()
	 end
end

function handle_aiming()
  local aim_increment = btn(🅾️) and 0.001 or 0.008

  if active_power_up and active_power_up.name == "random_aim" then
    if not random_aim_direction then
      random_aim_direction = 1 
    end

    aim_angle += 0.03 * random_aim_direction

    if aim_angle >= 1.25 then
      aim_angle = 1.25
      random_aim_direction = -1
    elseif aim_angle <= 0.25 then
      aim_angle = 0.25
      random_aim_direction = 1
    end

  elseif active_power_up and active_power_up.name == "partial_aim" then
    local angles = {0.25, 0.35, 0.45, 0.65, 0.85, 1.05, 1.15, 1.25}

    if not partial_aim_initialized then
      aim_angle = 0.65
      partial_aim_initialized = true 
    end

    local current_index = 1
    for i, angle in ipairs(angles) do
      if abs(aim_angle - angle) < 0.05 then
        current_index = i
        break
      end
    end

    if btnp(⬅️) and current_index > 1 then
      current_index -= 1
    elseif btnp(➡️) and current_index < #angles then
      current_index += 1
    end

    aim_angle = angles[current_index]

  else
    partial_aim_initialized = false

    if btn(⬅️) then
      aim_angle -= aim_increment
    elseif btn(➡️) then
      aim_angle += aim_increment
    end
  end

  aim_angle = mid(0.25, aim_angle, 1.25)
end

function check_fire()
  if btnp(❎) then
    ball.vx = cos(aim_angle) * ball.speed
    ball.vy = sin(aim_angle) * ball.speed
    ball.is_fired = true
  end
end

function draw_ball()
  if ball.special_physics == "multiball" then
    if not ball.is_fired then
      circfill(ball.x, ball.y, ball.radius, ball.hue)
    else
      for b in all(active_balls) do
        circfill(b.x, b.y, b.radius, ball.hue)
      end
    end
  else
    circfill(ball.x, ball.y, ball.radius, ball.hue)
  end

end

function draw_aiming_reticle()
       
  local steps = 150
  local time_step = 0.1
  local x, y, vx, vy = ball.x, ball.y, cos(aim_angle) * ball.speed, sin(aim_angle) * ball.speed
  for i = 1, steps do
    vx = vx
    vy += 0.08 * time_step
    x += vx * time_step
    y += vy * time_step
    pset(x, y, 2)
  end

end

function check_ball_off_screen()
	 if ball.y > 128 then
    if balls_remaining > 0 then
      game_state = "pause"
    else
      ball.is_fired = false
    end
	 end
end

function ball_calc()
    local rewards = {
        {19500, 12}, {18000, 11}, {16500, 10}, {15000, 9}, {13500, 8},
        {12000, 7}, {10500, 6}, {9000, 5}, {7500, 4}, {6000, 3},
        {4500, 2}, {3000, 1}
    }

    if points_per_shot < 1500 then
        balls_remaining -= 1
    else
        for _, r in ipairs(rewards) do
            if points_per_shot >= r[1] then
                balls_remaining += r[2]
                break
            end
        end
    end

    balls_remaining = min(balls_remaining, 16)

    if goal_pegs_hit_total == 20 and basic_pegs_hit_total == 29 then
        balls_remaining += 1
    end
end


function reload_ball()
    active_balls = {}
    ball.is_fired, ball.special_physics, ball.hue, ball.vx, ball.vy, drops_remaining, ball_start_frame = false, nil, 6, 0, 0, 2, 0

    ball.radius = big_head and 5 or 2

    mirage_pegs = {}

    finalize_shot_points()
    
    if goal_pegs_hit_total == 20 then
        stage_complete_pending = true
        if not ball.is_fired and (ball.y > 128 or ball.stuck_frames >= 120) then
            game_state = "pause" 
        end
    end
    
    if power_peg_reload_counter < 4 then
		    power_peg_reload_counter += 1
		  end
		
		  if power_peg_reload_counter == 4 and power_ups_enabled then
		    if power_peg_reference and power_peg_reference.state == "dead" then
		      generate_pegs(1, peg_config.power.color, "power")
		      for peg in all(peg_data) do
		        if peg.type == "power" then
		          power_peg_reference = peg
		          break
		        end
		      end
		    elseif power_peg_reference and power_peg_reference.state == "active" then
		      del(peg_data, power_peg_reference)
		      generate_pegs(1, peg_config.power.color, "power")
		      for peg in all(peg_data) do
		        if peg.type == "power" then
		          power_peg_reference = peg
		          break
		        end
		      end
		    end
		    power_peg_reload_counter = 0
		  end

    local active_pegs = {}
    for peg in all(peg_data) do
        if peg.state == "active" then
            add(active_pegs, peg)
        end
    end
    peg_data = active_pegs

    if active_power_up then
        deactivate_power_up()
    end

    if current_power_up then
        activate_power_up(current_power_up)
        current_power_up = nil 
    else
        
        ball.hue = 6
    end

    
    if balls_remaining <= 0 then
        game_state = "game_over"
        return
    end

    if active_power_up and active_power_up.name == "ball_start" then
        local positions = {26, 51, 77, 102}
        ball_start_frames = (ball_start_frames + 1) % 45
        if ball_start_frames == 0 then
            ball.x = positions[flr(rnd(#positions)) + 1] 
        end
    else
        ball.x = 64
    end

    ball.y, ball.vx, ball.vy, ball.is_fired = 10, 0, 0, false

    regenerate_bonus_peg()

    reset_per_shot_counters()

    expansion_locked_x, expansion_locked_y, expansion_active, rock_drop_active = nil, nil, false, false 
end

function draw_ball_counter()
  for i = 1, balls_remaining - 1 do
    local ball_y = 128 - (i * 8)
    circfill(3, ball_y, 2, 6)
  end
end

-->8
-- page 3: peg mechanics

peg_data = {}

peg_config = {
	 basic = {count = 29, color = 5},
	 goal = {count = 20, color = 9},
	 bonus = {count = 1, color = 12},
	 power = {count = 1, color = 11}
}

mirage_pegs = {}

function check_valid_position(x, y)
  for peg in all(peg_data) do
	   local distance = sqrt((peg.x - x)^2 + (peg.y - y)^2)
	   if distance < 6 then
	     return false
	   end
  end
  for mirage in all(mirage_pegs) do
    local distance = sqrt((mirage.x - x)^2 + (mirage.y - y)^2)
    if distance < 6 then
      return false
    end
  end
  return true
end

function initialize_pegs()
  peg_data = {}
  generate_pegs(peg_config.basic.count, peg_config.basic.color, "basic")
  generate_pegs(peg_config.goal.count, peg_config.goal.color, "goal")
  generate_pegs(peg_config.bonus.count, peg_config.bonus.color, "bonus")
  if power_ups_enabled then
    generate_pegs(1, peg_config.power.color, "power")
    for peg in all(peg_data) do
      if peg.type == "power" then
        power_peg_reference = peg
        break
      end
    end
  else
    power_peg_reference = nil
  end

  if ball.special_physics == "peg_shuffle" then
    shuffle_active_pegs()
  end
end

function generate_pegs(count, color, peg_type)
  local attempts = 0
  for i = 1, count do
    local valid_position = false
    local x, y
    while not valid_position do
      x = flr(rnd(107)) + 11
      y = flr(rnd(96)) + 20
      valid_position = check_valid_position(x, y)
      attempts += 1
      if attempts > 1000 then
        break
      end
    end
    if valid_position then
      add(peg_data, {
        x = x,
        y = y,
        color = color,
        type = peg_type,
        state = "active",
        radius = 2
      })
    end
  end
end

function regenerate_bonus_peg()
    for peg in all(peg_data) do
        if peg.type == "bonus" and peg.state == "active" then
            del(peg_data, peg)
            break
        end
    end
    generate_pegs(peg_config.bonus.count, peg_config.bonus.color, "bonus")
end


function draw_pegs()
	 if ball.special_physics == "blind_peg" then
	   for peg in all(peg_data) do
      if peg.state == "active" then
        circfill(peg.x, peg.y, peg.radius, 7) 
      elseif peg.state == "dead" then
        circ(peg.x, peg.y, peg.radius, 7) 
      end
    end
	 else
    for peg in all(peg_data) do
      if peg.state == "active" then
        circfill(peg.x, peg.y, peg.radius, peg.color)
      elseif peg.state == "dead" then
        circ(peg.x, peg.y, peg.radius, 7)
      end
    end

    if ball.special_physics == "peg_mirage" then
      for mirage in all(mirage_pegs) do
        circfill(mirage.x, mirage.y, mirage.radius, mirage.color)
      end
    end
	 end
end

function shuffle_active_pegs()
  local attempts = 0
  for peg in all(peg_data) do
    if peg.state == "active" then
      local valid_position = false
      local new_x, new_y
      while not valid_position do
        new_x = flr(rnd(107)) + 11 
        new_y = flr(rnd(96)) + 20 
        valid_position = check_valid_position(new_x, new_y)
        attempts += 1
        if attempts > 1000 then
          break 
        end
      end

      if valid_position then
        peg.x = new_x
        peg.y = new_y
      end    
    end
  end
end



-->8
-- page 4: points tracking and mechanics

time_elapsed, basic_pegs_hit_per_shot, basic_pegs_hit_total = 0, 0, 0
goal_pegs_hit_per_shot, goal_pegs_hit_total, bonus_peg_hits_per_shot, bonus_peg_hits_total = 0, 0, 0, 0
pause_frames, points_finalized, points_per_shot, balls_earned, ball_earned_display = 0, false, 0, 0, 0

local score_bar_sfx_playing = false

function reset_per_shot_counters()
  basic_pegs_hit_per_shot, goal_pegs_hit_per_shot, bonus_peg_hits_per_shot, points_per_shot = 0, 0, 0, 0
end

function reset_counters()
  time_elapsed, basic_pegs_hit_total, goal_pegs_hit_total, bonus_pegs_hit_total, total_points = 0, 0, 0, 0, 0
  deactivate_power_up()
end

function update_time_elapsed()
    if time_elapsed == nil then
        time_elapsed = 0
    end
    if time_elapsed_frame_counter == nil then
        time_elapsed_frame_counter = 0
    end

    time_elapsed_frame_counter += 1
    if time_elapsed_frame_counter >= 60 then
        time_elapsed += 1
        time_elapsed_frame_counter = 0
    end
end

function format_time_elapsed()
    local minutes = flr(time_elapsed / 60)
    local seconds = time_elapsed % 60
    return minutes .. "m " .. seconds .. "s"
end

function get_peg_point_values()
  if goal_pegs_hit_total <= 6 then
    return 100, 25
  elseif goal_pegs_hit_total <= 11 then
    return 200, 50
  elseif goal_pegs_hit_total <= 15 then
    return 400, 100
  else
    return 800, 200
  end
end

function update_peg_hit_count(peg_type)
    local goal_points, basic_points = get_peg_point_values()

    if peg_type == "basic" then
        basic_pegs_hit_per_shot += 1
        basic_pegs_hit_total += 1
        points_per_shot += basic_points
    elseif peg_type == "goal" then
        goal_pegs_hit_per_shot += 1
        goal_pegs_hit_total += 1
        points_per_shot += goal_points
    elseif peg_type == "bonus" then
        bonus_peg_hits_per_shot += 1
        bonus_peg_hits_total += 1
    elseif peg_type == "power" then
        power_peg_hit = true
        power_peg_reload_counter = 0
	       if current_power_pool then
	            current_power_up = current_power_pool[flr(rnd(#current_power_pool)) + 1]
	       elseif selected_mode == 4 then 
	            current_power_up = flr(rnd(10)) + 1 
	       elseif selected_mode == 5 then 
	            current_power_up = flr(rnd(10)) + 11 
	       elseif selected_mode == 6 then 
	            current_power_up = flr(rnd(20)) + 1 
	       end

        power_up_on = true
    end
end


function in_table(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

power_choices = {}

function generate_power_choices()
    local high_power_pool = { 4, 8, 9 }
    local high_power = high_power_pool[flr(rnd(#high_power_pool)) + 1] 
    local high_curses = generate_unique_choices({ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, 4) 
    power_choices.high = { high_power, unpack(high_curses) }

    local mid_power_pool = { 1, 3, 5, 7 }
    local mid_powers = generate_unique_choices(mid_power_pool, 2) 
    local mid_curses = generate_unique_choices({ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, 3) 
    power_choices.mid = { mid_powers[1], mid_powers[2], unpack(mid_curses) } 

    local low_power_pool = { 2, 6, 10 }
    local mid_power_pool = { 1, 3, 5, 7 }
    local low_powers = generate_unique_choices(low_power_pool, 2) 
    local low_mid_power = mid_power_pool[flr(rnd(#mid_power_pool)) + 1] 
    local low_curses = generate_unique_choices({ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }, 2) 
    power_choices.low = { low_powers[1], low_powers[2], low_mid_power, unpack(low_curses) } 

    power_choices.overdrive = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }

    power_choices.gauntlet = { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }

    power_choices.potluck = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }
end

function generate_unique_choices(pool, count)
    local selected = {}
    while #selected < count do
        local choice = pool[flr(rnd(#pool)) + 1]
        if not in_table(selected, choice) then
            add(selected, choice)
        end
    end
    return selected
end

function finalize_shot_points()
  if bonus_peg_hits_per_shot > 0 then
      points_per_shot *= 2
  end

  if active_power_up and active_power_up.name == "half_pts" then
    if points_per_shot % 2 == 0 then
      points_per_shot = points_per_shot * 0.5 
    else
      points_per_shot = flr(points_per_shot * 0.5) + 1 
    end
  end
  bonus_peg_hits_per_shot = 0
end


function stage_balls_earned()
  balls_earned = flr(total_points_per_stage / 1500)
  if balls_earned + balls_remaining >= 16 then
    balls_remaining = 16
  else
    balls_remaining += balls_earned
  end
end

function draw_score_bar()
  local max_points, max_height = 1500, 107
  local height = min(flr(points_per_shot / max_points * max_height), max_height)
  if points_per_shot > 0 then
    local bar_color = points_per_shot <= 499 and 9 or
                      points_per_shot <= 999 and 10 or
                      points_per_shot < 1500 and 11 or
                      (flr(time() * 4) % 2 == 0 and 3 or 7)
    rectfill(121, 127, 124, max(127 - height, 20), bar_color)
  end
end

score_bar_sfx_playing = false 

function score_sound()
  if points_per_shot >= 1500 then
    if not score_bar_sfx_playing then
      sfx(14) 
      score_bar_sfx_playing = true
    end
  else
    if score_bar_sfx_playing then
      sfx(-1) 
      score_bar_sfx_playing = false
    end
  end
end

function play_music()
	if current_music ~= 01 then
   music(01) 
   current_music = 01
 end
end

function stop_sfx()
 if score_bar_sfx_playing then
     sfx(-1) 
     score_bar_sfx_playing = false
 end
end

function draw_points_per_shot()
  local display_message = "points this shot: " .. points_per_shot
  local x = (128 - #display_message * 4) / 2
  print(display_message, x, 10, 10)

  local rewards = {
    {24000, "15 balls earned!"},
    {22500, "14 balls earned!"},
    {21000, "13 balls earned!"},
    {19500, "12 balls earned!"},
    {18000, "11 balls earned!"},
    {16500, "10 balls earned!"},
    {15000, " 9 balls earned!"},
    {13500, " 8 balls earned!"},
    {12000, " 7 balls earned!"},
    {10500, " 6 balls earned!"},
    {9000,  " 5 balls earned!"},
    {7500,  " 4 balls earned!"},
    {6000,  " 3 balls earned!"},
    {4500,  " 2 balls earned!"},
    {3000,  " 1 ball earned!"},
    {1500,  "   ball saved!"}
  }

  for _, reward in ipairs(rewards) do
    if points_per_shot >= reward[1] then
      print(reward[2], x + 12, 20, 10)
      break
    end
  end

  if (flr(points_per_shot / 1500) + (balls_remaining - 1) >= 16) and (points_per_shot >= 1500) then
    print("max balls earned! (16 total)", 10, 30, 10)
  end
end

function draw_multiplier()
  local multiplier_text = goal_pegs_hit_total >= 16 and "x8" or 
                          goal_pegs_hit_total >= 12 and "x4" or 
                          goal_pegs_hit_total >= 7 and "x2" or 
                          "x1"
  print(multiplier_text, 121, 11, 7)
end

function check_and_update_records()
    if easter_ball or big_head or time_boost then return end 
    
    record_message = {} 
    stage_message = nil 

    local overflow_key = power_ups_enabled and 0 or 6
    local total_points_key = power_ups_enabled and 1 or 7
    local lowest_min_key = power_ups_enabled and 3 or 8
    local lowest_sec_key = power_ups_enabled and 4 or 9
    local stage_reach_key = power_ups_enabled and 11 or 12

    if overflow > dget(overflow_key) or 
       (overflow == dget(overflow_key) and total_points > dget(total_points_key)) then
        dset(overflow_key, overflow)
        dset(total_points_key, total_points)
        add(record_message, "new high score!")
    end  

    if game_state == "time_trial_complete" then
        local lowest_min, lowest_sec = dget(lowest_min_key), dget(lowest_sec_key)
        local current_min, current_sec = flr(time_elapsed / 60), time_elapsed % 60

        if lowest_min == 0 and lowest_sec == 0 or 
           current_min < lowest_min or 
           (current_min == lowest_min and current_sec < lowest_sec) then
            dset(lowest_min_key, current_min)
            dset(lowest_sec_key, current_sec)
            add(record_message, "new fastest time!")
        end
    end

    if stage > dget(stage_reach_key) then
        dset(stage_reach_key, stage)
        stage_message = "new highest stage!"
    end
end

cleared_this_stage = false 

function total_clear()
    if easter_ball or big_head or time_boost then return end 
    
    if cleared_this_stage or basic_pegs_hit_total ~= 29 then return end

    local index = power_ups_enabled and 5 or 10
    local total_clear_sum = dget(index)
    total_clear_sum += 1
    dset(index, total_clear_sum)
    cleared_this_stage = true
end




-->8
-- page 5: physics

expansion_locked_x, expansion_locked_y, expansion_active, rock_drop_active, gravity_sfx_channel = nil, nil, false, false, 2

function update_physics(ball, peg_data)
  
  local gravity = 0.08
		
		if ball.special_physics == "gravity_flip" then
		    if btn(❎) then
		        gravity = -0.08
		        if not gravity_sfx_playing then
		            sfx(16, gravity_sfx_channel) 
		            gravity_sfx_playing = true
		        end
		    else
		        gravity = 0.08
		        if gravity_sfx_playing then
		            sfx(-1, gravity_sfx_channel) 
		            gravity_sfx_playing = false
		        end
		    end
		else
		    if gravity_sfx_playing then
		        sfx(-1, gravity_sfx_channel) 
		        gravity_sfx_playing = false
		    end
		end
		  
  local balls_to_update = ball.special_physics == "multiball" and active_balls or {ball}

  for b in all(balls_to_update) do
    if b.is_fired then
      b.vy += gravity 
      local sub_steps = 5
      local step_vx = b.vx / sub_steps
      local step_vy = b.vy / sub_steps

      for step = 1, sub_steps do
        local collision_occurred = false
        b.x += step_vx
        b.y += step_vy

        if b.special_physics == "boulder" then
          for peg in all(peg_data) do
            if peg.state == "active" then
              local dx = b.x - peg.x
              local dy = b.y - peg.y
              local distance = sqrt(dx^2 + dy^2)
              local min_distance = b.radius + peg.radius

              if distance < min_distance then
                peg.state = "dead" 
                update_peg_hit_count(peg.type) 
                if peg.type == "bonus" then
                  sfx(10) 
				            elseif peg.type == "power" then
				              sfx(9) 
				            else
				              sfx(0) 
				            end
                collision_occurred = false
              end
            end
          end
        
        elseif b.special_physics == "reshoot" then
						    for peg in all(peg_data) do
				        if peg.state == "active" then
		            local dx = b.x - peg.x
		            local dy = b.y - peg.y
		            local distance = sqrt(dx^2 + dy^2)
		            local min_distance = b.radius + peg.radius
		
		            if distance < min_distance then
                peg.state = "dead" 
                update_peg_hit_count(peg.type)
                if peg.type == "bonus" then
                  sfx(10) 
				            elseif peg.type == "power" then
				              sfx(9) 
				            else
				              sfx(0) 
				            end
                b.is_fired = false
		              
		              if goal_pegs_hit_total == 20 and (b.y > 128 or b.stuck_frames >= 120) then
		                game_state = "pause"
		              end
		            end
				        end
						    end
        
        elseif b.special_physics == "expansion" then
						    if not expansion_active then
				        expansion_locked_x = nil
				        expansion_locked_y = nil
				        b.radius = ball.radius 
				        expansion_active = true						      
						      expansion_sfx_playing = false
						    end
						
						    for peg in all(peg_data) do
				        local dx = b.x - peg.x
				        local dy = b.y - peg.y
				        local distance = sqrt(dx^2 + dy^2)
				        local min_distance = b.radius + peg.radius
				
				        if distance < min_distance then
		            if not expansion_locked_x then
                expansion_locked_x = peg.x
                expansion_locked_y = peg.y
		            end
		
		            b.x = expansion_locked_x
		            b.y = expansion_locked_y
		            b.vx = 0
		            b.vy = 0
		            b.y -= 0.08 
		
		            if peg.state == "active" then
                peg.state = "dead"
                update_peg_hit_count(peg.type)
		              if peg.type == "bonus" then
                  sfx(10) 
				            elseif peg.type == "power" then
				              sfx(9) 
				            else
				              sfx(0) 
				            end
		            end
		            
		            if b.vy == 0 and expansion_active then
                b.radius += 0.16                 
                if not expansion_sfx_playing then
								            sfx(15,3) 
								            expansion_sfx_playing = true
								        end
                
                for peg in all(peg_data) do
                  if peg.state == "active" then
                    local dx = b.x - peg.x
                    local dy = b.y - peg.y
                    local distance = sqrt(dx^2 + dy^2)
                    local min_distance = b.radius + peg.radius

                    if distance < min_distance then
                      peg.state = "dead"
                      update_peg_hit_count(peg.type)
                      if peg.type == "bonus" then
						                  sfx(10) 
										            elseif peg.type == "power" then
										              sfx(9) 
										            else
										              sfx(0) 
										            end
                    end
                  end
                end
		            end 
		
		            return
				        end
						    end
						
						    if b.radius >= 20 then
				        b.special_physics = nil 
				        expansion_locked_x = nil
				        expansion_locked_y = nil
				        expansion_active = false
						      sfx(-1,3)
						    end
            
        elseif b.special_physics == "rock_drop" then
						    if not rock_drop_active then
				        rock_drop_active = false 
				        b.rock_drop_activated = false 
						    end
						
						    if not b.rock_drop_activated then
				        for peg in all(peg_data) do
		            if peg.state == "active" or peg.state == "dead" then
                local dx = b.x - peg.x
                local dy = b.y - peg.y
                local distance = sqrt(dx^2 + dy^2)
                local min_distance = b.radius + peg.radius

                if distance < min_distance then
                    b.rock_drop_activated = true 
                    rock_drop_active = true 
                    
                    local nx = dx / distance
                    local ny = dy / distance
                    local overlap = min_distance - distance
                    b.x += nx * overlap
                    b.y += ny * overlap
                    b.vx = 0
                    b.vy = gravity
                    
                    if peg.state == "active" then
                      peg.state = "dead"
                      update_peg_hit_count(peg.type)
                      if peg.type == "bonus" then
						                  sfx(10) 
										            elseif peg.type == "power" then
										              sfx(9) 
										            else
										              sfx(0) 
										            end
                    end

                    break
                end
		            end
				        end
						    else
				        b.vx = 0 
				        b.vy += gravity 
				
				        for peg in all(peg_data) do
		            if peg.state == "active" or peg.state == "dead" then
                local dx = b.x - peg.x
                local dy = b.y - peg.y
                local distance = sqrt(dx^2 + dy^2)
                local min_distance = b.radius + peg.radius

                if distance < min_distance then
                  local nx = dx / distance
                  local ny = dy / distance
                  local overlap = min_distance - distance
                  b.x += nx * overlap
                  b.y += ny * overlap
                  b.vx = 0
                  b.vy = gravity

                  if peg.state == "active" then
                    peg.state = "dead"
                    update_peg_hit_count(peg.type)
                    if peg.type == "bonus" then
				                  sfx(10) 
								            elseif peg.type == "power" then
								              sfx(9) 
								            else
								              sfx(0) 
								            end
                  end

                  break
                end
		            end
				        end
						    end
        
        elseif b.special_physics == "magnet" then
          local nearest_peg = find_nearest_goal_peg(b, peg_data)
          if nearest_peg then
              local dx = nearest_peg.x - b.x
              local dy = nearest_peg.y - b.y
              local distance = sqrt(dx^2 + dy^2)

              if distance > 0 and distance < 40 then 
                  local nx = dx / distance 
                  local ny = dy / distance
                  local attraction_strength = 0.115 
                  b.vx += nx * attraction_strength
                  b.vy += ny * attraction_strength
              end
          end

          b.vx = b.vx * 0.98 + rnd() * 0.1 - 0.05 
          b.vy = b.vy * 0.98 + rnd() * 0.1 - 0.05 

          local max_speed = 3.5
          local speed = sqrt(b.vx^2 + b.vy^2)
          if speed > max_speed then
              b.vx = b.vx / speed * max_speed
              b.vy = b.vy / speed * max_speed
          end 
        end

        if b.special_physics ~= "boulder" then
          for peg in all(peg_data) do
            if peg and (peg.state == "active" or peg.state == "dead") then
              local dx = b.x - peg.x
              local dy = b.y - peg.y
              local distance = sqrt(dx^2 + dy^2)
              local min_distance = b.radius + peg.radius

              if distance < min_distance then
                local nx = dx / distance
                local ny = dy / distance
                local overlap = min_distance - distance
                b.x += nx * overlap
                b.y += ny * overlap
                local dot_product = (b.vx * nx) + (b.vy * ny)
                b.vx = (b.vx - 2 * dot_product * nx) * 0.84
                b.vy = (b.vy - 2 * dot_product * ny) * 0.84

                if peg.state == "active" then
                  peg.state = "dead"
                  update_peg_hit_count(peg.type)
                  if peg.type == "bonus" then
		                  sfx(10) 
						            elseif peg.type == "power" then
						              sfx(9) 
						            else
						              sfx(0) 
						            end
                end

                collision_occurred = true
                break
              end
            end
          end
        end
                   
        if active_power_up and active_power_up.name == "threepeat" then
	         
	         if ball.y > 126 and drops_remaining > 0 then
	      			  ball.y = 1
	      			  drops_remaining -= 1
	      		 elseif ball.y > 126 and drops_remaining == 0 then
	      			 --nothing
	      			end
	      			
	      			if drops_remaining == 2 then
	      			  ball.hue = 3
	      			elseif drops_remaining == 1 then
	      			  ball.hue = 11
	      			elseif drops_remaining == 0 then
	      			  ball.hue = 6
	      			end
	      
        end
        
        if active_power_up and active_power_up.name == "paddle" then
								    if b.y + b.radius >= 126 and b.y + b.radius <= 128 and
								       b.x >= paddlex - 19 and b.x <= paddlex + 19 then
								        sfx(11)
								        b.vy = -abs(b.vy) * 1.05
								        local hit_offset = (b.x - paddlex) / 18
								        b.vx += hit_offset * 0.5
								        b.y = 126 - b.radius
								    end
								end

        if b.x - b.radius <= 8 then
          b.x = 8 + b.radius
          b.vx = -b.vx * 0.9
          --sfx(0)
        elseif b.x + b.radius >= 120 then
          b.x = 120 - b.radius
          b.vx = -b.vx * 0.9
          --sfx(0)
        end

        if b.y - b.radius <= 0 then
          b.y = b.radius
          b.vy = -b.vy * 0.84
          --sfx(0)
        end

        if b.y > 128 then
          b.is_done = true
        end

        if collision_occurred then
          break
        end
      end
    end
  end

  if ball.special_physics == "multiball" then
    local all_done = true
    for b in all(active_balls) do
      if not b.is_done then
        all_done = false
        break
      end
    end

    if all_done then
      active_balls = {} 
      ball.special_physics = nil 
      ball.is_fired = false 
      game_state = "pause" 
    end
  end

  for peg in all(peg_data) do
    if peg.recently_hit and peg.recently_hit > 0 then
      peg.recently_hit -= 1
    end
  end
end

function find_nearest_goal_peg(ball, peg_data)
  local nearest_peg = nil
  local min_distance = 9999 

  for peg in all(peg_data) do
    if peg.type == "goal" and peg.state == "active" then
      local dx = ball.x - peg.x
      local dy = ball.y - peg.y
      local distance = sqrt(dx^2 + dy^2)
      if distance < min_distance then
        min_distance = distance
        nearest_peg = peg
      end
    end
  end

  return nearest_peg
end

function detect_and_handle_stuck_ball(ball)
  
  local stuck_tolerance = big_head and 5 or 3
  local max_stuck_frames = 120

  if ball.special_physics == "multiball" then
    for b in all(active_balls) do
      if not b.stuck_frames then
        b.stuck_frames = 0
      end

      if b.y > 128 then
        del(active_balls, b)
      elseif abs(b.x - b.last_x) < stuck_tolerance and abs(b.y - b.last_y) < stuck_tolerance then
        b.stuck_frames += 1
        if b.stuck_frames >= max_stuck_frames then
          del(active_balls, b)
        end
      else
        b.stuck_frames = 0
        b.last_x = b.x
        b.last_y = b.y
      end
    end

    if #active_balls == 0 then
      ball.special_physics = nil
      ball.is_fired = false
      game_state = "pause"
    end
  else
    if abs(ball.x - ball.last_x) < stuck_tolerance and abs(ball.y - ball.last_y) < stuck_tolerance then
      ball.stuck_frames += 1
    else
      ball.stuck_frames = 0
      ball.last_x = ball.x
      ball.last_y = ball.y
    end

    if ball.stuck_frames >= max_stuck_frames or ball.y > 128 then
      ball.stuck_frames = 0
      if balls_remaining > 0 then
        game_state = "pause"
      else
        game_state = "game_over"
      end
    end
  end
end


-->8
-- page 6: power-ups

current_power_up, active_power_up, power_up_display = nil, nil, ""
active_balls = {}

power_ups = {
    [1] = {name = "boulder", radius = 8, hue = 4, special_physics = "boulder"},
    [2] = {name = "sniper", speed = 6, hue = 14},
    [3] = {name = "paddle", special_physics = "paddle", paddlex = 64},
    [4] = {name = "magnet", special_physics = "magnet", hue = 13},
    [5] = {name = "multiball", special_physics = "multiball", hue = 10},
    [6] = {name = "threepeat", special_physics = "threepeat", hue = 3},
    [7] = {name = "expansion", special_physics = "expansion", hue = 2},
    [8] = {name = "gravity_flip", special_physics = "gravity_flip", hue = 0},
    [9] = {name = "reshoot", special_physics = "reshoot", hue = 7},
    [10] = {name = "ball_move", special_physics = "ball_move"},
    [11] = {name = "no_aim", special_physics = "no_aim"},
    [12] = {name = "random_aim", special_physics = "random_aim"},
    [13] = {name = "half_pts", special_physics = "half_pts"},
    [14] = {name = "rock_drop", special_physics = "rock_drop", hue = 8},
    [15] = {name = "partial_aim", special_physics = "partial_aim"},
    [16] = {name = "blind_peg", special_physics = "blind_peg"},
    [17] = {name = "peg_shuffle", special_physics = "peg_shuffle", custom_activate = shuffle_active_pegs},
    [18] = {name = "ball_start", special_physics = "ball_start"},
    [19] = {
        name = "peg_mirage",
        special_physics = "peg_mirage",
        custom_activate = function()
            mirage_pegs = {}
            for i = 1, 50 do
                local valid_position = false
                local x, y
                while not valid_position do
                    x = flr(rnd(107)) + 10
                    y = flr(rnd(96)) + 20
                    valid_position = check_valid_position(x, y)
                end
                add(mirage_pegs, {x = x, y = y, radius = 2, color = flr(rnd(3)) == 0 and 5 or (rnd() < 0.5 and 9 or 12)})
            end
        end,
        custom_deactivate = function()
            mirage_pegs = {}
        end
    },
    [20] = {name = "wobble_aim", special_physics = "wobble_aim"}
				}

function activate_power_up(power_up_id)
    if active_power_up then deactivate_power_up() end
    local power_up = power_ups[power_up_id]
    if not power_up then return end

    ball.special_physics = power_up.special_physics or ball.special_physics
    ball.hue = power_up.hue or ball.hue
    ball.radius = power_up.radius or ball.radius
    ball.speed = power_up.speed or ball.speed
    paddlex = power_up.paddlex or paddlex

    if power_up.custom_activate then power_up.custom_activate() end
    active_power_up = power_up
end

function deactivate_power_up()
    if not active_power_up then return end

    ball.special_physics, ball.hue, ball.radius, ball.speed = nil, 6, big_head and 5 or 2, 2

    if active_power_up.custom_deactivate then active_power_up.custom_deactivate() end
    active_power_up = nil
end

function handle_power_up_logic()
  if active_power_up then
    deactivate_power_up() 
  end
end

function paddle()
    paddlex = mid(27, paddlex + (btn(➡️) and 2.2 or 0) - (btn(⬅️) and 2.2 or 0), 101)
end




__gfx__
000000003311111333663333dddddddd3333333accceecccc33ccccc33333333ddd66777d7722dddcc7cc7cc0000000000000000000000000000000000000000
000000003544441336666333d88dd88d33333333cceeeecc3333cbbc32222223ddd6677dd77dd2ddc7cccc7c0000000000000000000000000000000000000000
0070070054444d4136666333d55dd55d3333aa33ceccccec3333bbbb32eeee23d7ddd7d7dddddd77777777770000000000000000000000000000000000000000
0007700054d4444133663333d55dd55d3333aa33eeceeceec33cbbbb32e66e237dddddd7ddd22277c7cccc7c0000000000000000000000000000000000000000
0007700054d4444133333333d55dd55d3aa33333eeceeceecc66cbbc32e66e237dddddd7dd2dddddcc7cc7cc0000000000000000000000000000000000000000
00700700544d444133333333d555555daaaa3333ceccccecc6666ccc32eeee237d7ddd7d77ddddddcccccccc0000000000000000000000000000000000000000
000000005544441337777773dd5555ddaaaa3333cceeeeccc6666ccc32222223d7766ddd7722ddddccc66ccc0000000000000000000000000000000000000000
000000003555553337777773dddddddd3aa33333ccceeccccc66cccc3333333377766ddddddd2dddccc66ccc0000000000000000000000000000000000000000
00000000188778818811118887888878888778888887881818888881899888888668888819918818188178180000000000000000000000000000000000000000
00000000817777188177771887888788877777788877818881777718999987786666877891991881817717810000000000000000000000000000000000000000
00000000871881788788881887887888887777888788188187177178999988786666887899198188871881780000000000000000000000000000000000000000
00000000778178777787781787878777888778887787881887711778899888888668888889188188771771770000000000000000000000000000000000000000
00000000778718777781117788788887888888887787818887711778888885588888866881881551718718710000000000000000000000000000000000000000
00000000871881788781887887888777887777888788188187177178878855558788666618815515178188180000000000000000000000000000000000000000
00000000817777188877778878888788878888788877881881777718877855558778666618815515187177180000000000000000000000000000000000000000
00000000188778818881788888888777877777788887818818888881888885588888866881881551818718810000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000820002808200028000000000000000000000000000000000111111111111111111111111111111110000000000000000000000000000000000000000
08828800820002808200028000000000000000000000000000000000111111111111111111111111111111110000000000000000000000000000000000000000
882028808200028082000280000000000000000000000000000000001119991111155511111ccc11111bbb110000000000000000000000000000000000000000
82000280820002808200028000000000000000000000000000000000119999911155555111ccccc111bbbbb10000000000000000000000000000000000000000
82000280820002808200028000000000000000000000000000000000119999911155555111ccccc111bbbbb10000000000000000000000000000000000000000
82000280820002808820288000000000000000000000000000000000119999911155555111ccccc111bbbbb10000000000000000000000000000000000000000
820002808200028008828800000000000000000000000000000000001119991111155511111ccc11111bbb110000000000000000000000000000000000000000
82000280820002800088800000000000000000000000000000000000111111111111111111111111111111110000000000000000000000000000000000000000
__sfx__
0001000022030170300e7000670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001800001f03023030260302803026030230301f0303500021030240302803026030230301f0300000000000320302f030300302d0302f030320303403000000370303403030030320302f0302d0302b03000000
0018000013150000001a150000001c1500000018150000001a1500000015150000001715000000131500000013150000000c150000001a150000001715000000181500000015150000001a150000001315000000
001800001f04026040230400000021040280402404000000230402a04026040000001c0401f04023040000001f040230401a040000002104024040280400000023040260402a040000001c0401f0402304000000
00180000183700030018370000001d370000000000000000183700000018300000001d370007001837000000183700030018370000001d370000000000000000183700000018300000001d370007001837000000
00180000280302b0302d0302a0302b0302803026030000002403021030230301f030210301e03028030000001f03023030260302803024030210301f0300000026030290302b03028030230301f0302403000000
0018000010150000001515000000171500000013150000001515000000121500000010150000000e15000000131500000018150000001a150000001515000000181500000013150000001d150000000e15000000
001800001c0401f04023040000002104024040280400000023040260402a040000001c0401f04023040000001f04023040260400000024040280402b040000001d0402104024040000001c0401f0402304000000
00180000183700000018370000001d370000000000000000183700000000000000001d370000001837000000183702400018370000001d370000000000000000183700000000000000001d370000001837000000
000300001532016320193201c3201d120201202412027120292202e22000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000010730127301573016730187301c7301f730217302473027730297302d7303173034730377300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000029030210301c0300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000073000730007300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000034620266201c620141200f1200a1200752005620045200362002520016200052000700006000060000000006000060000600006000260003600086000000000000000000000000000000000000000000
000501100e00009000080000c0001100017000190001a00000000110300e0300e03012030150301503011030000000e0000a000080000c0001300016000180000000000000000000000000000000000000000000
001000000d7300e7300f730107301173012730137301573016730187301b7301d7302073024730297300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00080942609426074160741609426094260741607416004060040600006000060640600006284060000600006000060000600006000060000600006000000000000000000000000000000000000000000000
__music__
00 41424344
01 01020344
02 05060748
00 0e424344
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111157111111111111577777777111111111111577111111111111111111111111111111111111111111
11111111111111111111111111111111111111117111115777777111111115777777777771111111157777711111111111111111111111111111111111111111
11111111111111111111111111111111111117777111157777777771111157755555577777111111157777771111157111111111111111111111111111111111
11111111111111111111111111111111111777711111577777777771111157111111155777111111577555777111157711111111111571111111111111111111
11111111111111111111777771111111177771111111577755557777111577111111115777111115777115577711157711111111115771111111111111111111
11111111111111111117777777711117777751111115777711115777111577111111115577111115771111557711157711111111115771111111111111111111
11111111111111111777555577711177775111111115777111111577111577111111111577111157771111157711577711111111115771111111111111111111
11111111111111117755111157757777751111111115777111111157111577111111111577111157711111157711577711111111115771111111111111111111
11111111111111177511111157757777511111111157777111111111111577111111111577111157711111157711577711111111157771111111111111111111
11111111111111771111111157757775111111111157771111111111111577111111111777111157711111157711577711111111157771111111111111111111
11111111111577711111111157757751111111111157771111111111111577111111117777111157711111157711577711111111157771111111111111111111
11111111111577111111111157757711111111111157711111111111111577111111777771111577111111157711577111111111157771111111111111111111
11111111111577111111111157757771111111111157711111111111111577111177777711111577111111157711577111111111157771111111111111111111
11111111111577111111111157757771111111111157711111111111111577777777771111111577111111157711577111111111157771111111111111111111
11111111111577111111111157757771111117111157711111111111111577777777711111111577111111157711577111111111157711111111111111111111
11111111111577111111111157757771111771111157711111111111111577771555777111111577111111157711577111111111157711111111111111111111
11111111111557711111111777157771177711111157711111111111111577111115577711111577111111157711577111111111157711111111111111111111
11111111111157711111111771157777777511111157711111111177111577111111577777111577111111157715777111111111157711111111111111111111
11111111111157711111117711157777775111111157711111117777111577111111555777711577777777777715777111111111157711111111111111111111
11111111111157711111177711157777751111111157711157777777111577111111115577711577777777777715777111111111577711111111111111111111
11111111111155711111777111157777511111111157711157777777711577111111111557771577777777777715771111111111577711111111111111111111
11111111111115711117711111157777511111111157711577775577711577111111111155771577555555557715771111111111577711111111111111111111
11111111111115771177711111157775111111111157711575551157711577111111111115771577111111157715771111111111577711111111111111111111
11111111111115777777111111157771111111111757711551111157711577111111111115777577111111157715771111111111577711111111111111111111
11111111111115777711111111157771111111117157711111111157711577111111111157777577111111577757771111111111577111111111111111111111
11111111111115577111111111157771111111171157771111111157771577111111111157777577111111577757771111111111577111111111111111111111
11111111111111577111111111157771111111711155771111111115771577111111111577777577711111577757771111111111577111111111111111111111
11111111111111577111111111157771111177111115771111111115771577111111117777771577711111577757771111111111577111111111111111111111
11111111111111577711111111157771111771111115777111111115771577711111177777711577711115777757771111111111577111111111111111111111
11111111111111577711111111157771117711111115577711111157771557777777777777111577711115777157771111111111577111111111111111111111
11111111111111577711111111157771777511111111577711111157777155777777777771111557711115777157777711111111577111111111111111111111
11111111111111577711111111155777777111111111557771111157577115557777771111111155711115771157777777111115777111111111111111111111
11111111111111557711111111115777775111111111155777711177577111155555551111111115511115711155577777771115777111111111111111111111
11111111111111157771111111115577751111111111115577777775577111111111111111111111111115511111555557777715777711111111111111111111
11111111111111157771111111111557511111111111111555555551577711111111111111111111111111111111111155577775777777111111111111111111
11111111111111157777111111111157511111111111111111111111577711111111111111111111111111111111111111555775557777777111111111111111
11111111111111155777711111111155111111111111111111111111557771111111111111111111111111111111111111115577155577777711111111111111
11111111111111115777111111111111111111111111111111111111155777711111111111111111111111111111111111111555111555557777111111111111
11111111111111115771111111111111111111111111111111111111115555511111111111111111111111111177111111111111111111155557771111111111
11111111111111115551111111111111111111111111111111111111111111111111111111111111111111111711111111111111111111111155551111111111
11111111111111111111111111111111111111111111177111111111111111111111111111111111111111111711111111111111111111111111111111111111
11111111111111111111111111111111111111111111711711111111111111111111111111111111111111171177711111111111111111111111111111111111
11111111111111111111111111111111111111111111711171111111111111111111111111111111111711117111171111111111111111111111111111111111
11111111111111111111111111111111111111111111711711111111111111111111111111111111111171117111171111111111111111111111111111111111
111111111111111111111111111111111111111111117171111111111111111111111111111111117711171117177111111111111111111111bbbbb111111111
1111111111111111111111111111111111111111111171171111117111111111111111111111111711711711171111111111111111111111bbbbbbbbb1111111
1111111111111111111111111116666661111111111171117117117111111111111111111111111711711171171111111111111111111bbbbbbbbbbbbbbb1111
11111111111111111111111166666666666611111111711117171711111111111111111111111711717711177111111111111111111bbbbbbbbbbbbbbbbbbb11
1111111111111111111111166666666666666111111171117117771111111111111111111177177117117711111111111111111111bbbbbbbbbbbbbbbbbbbbb1
111111111111111111111666666666666766666111117117111171111111111111111111171111771711111111111111111111111bbbbbbbbbbbbbbb77bbbbbb
11111111111111111111666666666666666766661111177111117111111111111111177117111117117111111111111111111111bbbbbbbbbbbbbbbbb777bbbb
1111111111111111111166666666666666667666111111111111711111111111111171171177711771111111111111111111111bbbbbbbbbbbbbbbbbbbb77bbb
111111111111111111166666666666666666676661111111117711111111111111117111711117117111111111111111111111bbbbbbbbbbbbbbbbbbbbb777bb
111111111111111111666666666666666666676666111111111111111111111111717111711117111111111111111111111111bbbbbbbbbbbbbbbbbbbbbb777b
11111111111111111166666666666666666666766611111111111111111111111171171117177111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbb77b
11111111111111111166666666666666666666776611111111111111111111177171177117111111117117117177111111111bbbbbbbbbbbbbbbbbbbbbbbb77b
11111111111111111666666666666666666666676661111111111111111177111777117771111111171717717171711111111bbbbbbbbbbbbbbbbbbbbbbbbbbb
1111111111111111166666666666666666666667666111111111111711117171117177111111111117771717717171111111bbbbbbbbbbbbbbbbbbbbbbbbbbbb
1111111111111111166666666666666666666666666111111117711771117117117111111111111117171711717711111111bbbbbbbbbbbbbbbbbbbbbbbbbbbb
111111111111111116666666666666666666666666611111111717171711711771711111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
111111111111111116665666666666666666666666611111111711771711177717111111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
111111111111111116665566666666666666666666611111111711171171171111177711717111711771177711177117171bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
111111111111111111666566666666666666666666111111111711111171171111171771717711717117171171711717171bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
111111111111111111666566666666666666666666111111111711111117171111171171717771717117177711711717171bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
111111111111111111666656666666666666666666111111111711111117111111171171717171717117171171711717771bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
111111111111111111166665666666666666666661111111111711111111711111171171717117717117171171711711711bbbbbbbbbbbbbbbbbbbbbbbbbbbbb
1111111111111111211166666666666666666666111211111117111111111111111717717171177171171711717117117111bbbbbbbbbbbbbbbbbbbbbbbbbbbb
1111111111111111221166666566666666666666112211111117111111111111111777117171117117711777111771117111bbbbbbbbbbbbbbbbbbbbbbbbbbbb
11111111111111112211166666666666666666611222111111171111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbb
11111111111111112221111666666666666661111222111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbb
11111111111111112222211166666666666611112222111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbbb
111111111111111122222211111666666111112222211111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbbb
1111111111111111222222211111111111111222222111111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbbb
11111111111111111222222221111111111222222221111111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbbb
111111111111111112222222222222222222222222211111111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbbbb
1111111111111111122222222222222222222222222111111111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbbbbbb1
11111111111111111222222222222222222222222221111111111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbbbb11
111111111111111112221222222222222222222222211111111111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbbbbbb111
11111111111111111122122222222222222222212221111111111111111111111111111111111111111111111111111111111111111111bbbbbbbbbbbbb11111
111111111111111111221222222222222222222122211111111111111111111111111111111111111111111111111111111111111111111111bbbbb111111111
11111111111111111122122222222222222222211221111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111122111222222222222222211221111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111112111222222222222222211121111111111111111111111111111111111111111111111111111111111555555555511111111111111111
11111111111111111112111222222222222222211111111111111111111111111111111111111111111111111111111111155555555555555111111111111111
11111111111111111111111222211222222122211111111111111111111111111111111111111111111111111111111115555555555555555551111111111111
11111111111111111111111122211222222112221111111111111111111111111111111111111111111111111111111555555555555555555555511111111111
11111111111111111111111122211122222111221111111111111111111111111111111111111111111111111111115555555555555555555555551111111111
11111111111111111111111122221122222111121111111111111111111111111111111111111111111111111111155555555555555555555755555111111111
11111111111111111111111112221112222111121111111111111111111111111111111111111111111111111111555555555555555555555777555511111111
11111111111111111111111112221112222111112111111111111111111111111111111111111111111111111111555555555555555555555577755511111111
11111111111111111111111111221111222211111111111111111111111111111111111111111111111111111115555555555555555555555557775551111111
11111111111111111111111111222111222211111111111111111111111111111111111111111111111111111155555555555555555555555555775555111111
11111111111111111111111111112211222211111111111111111111111111111111111111111111111111111155555555555555555555555555577555111111
11111111111111111111111111111211122211111111111111111111111111111111111111111111111111111555555555555555555555555555557555511111
11111111111111111111111111111111122211111111111111111111111111111111111111111111111111111555555555555555555555555555555555511111
11111111111111111111111111111111122221111111111111111111199999991111111111111111111111111555555555555555555555555555555555511111
11111111111111111111111111111111112221111111111111111199999999999991111111111111111111115555555555555555555555555555555555551111
11111111111111111111111111111111111222111111111111119999999999999999911111111111111111115555555555555555555555555555555555551111
11111111111111111111111111111111111222211111111111199999999999999999991111111111111111115555555555555555555555555555555555551111
11111111111111111111111111111111111122211111111111999999999999999999999111111111111111115555555555555555555555555555555555551111
11111111111111111111111111111111111112221111111119999999999999999779999911111111111111115555555555555555555555555555555555551111
11111111111111111111111111111111111111122111111199999999999999999977799991111111111111115555555555555555555555555555555555551111
11111111111111111111111111111111111111111111111999999999999999999997779999111111111111115555555555555555555555555555555555551111
11111111111111111111111111111111111111111111119999999999999999999999777999911111111111111555555555555555555555555555555555511111
11111111111111111111111111111111111111111111199999999999999999999999977999991111111111111555555555555555555555555555555555511111
11111111111111111111111111111111111111111111199999999999999999999999999999991111111111111555555555555555555555555555555555511111
1111111111111111cccccc1111111111111111111111199999999999999999999999999999991111111111111155555555555555555555555555555555111111
1111111111111cccccccccccc1111111111111111111999999999999999999999999999999999111111111111155555555555555555555555555555555111111
1111111111cccccccccccccccccc1111111111111111999999999999999999999999999999999111111111111115555555555555555555555555555551111111
111111111cccccccccccccccccccc111111111111111999999999999999999999999999999999111111111111115555555555555555555555555555551111111
11111111cccccccccccccccc7ccccc11111111111119999999999999999999999999999999999911111111111111555555555555555555555555555511111111
1111111cccccccccccccccccc77cccc1111111111119999999999999999999999999999999999911111111111111155555555555555555555555555111111111
111111cccccccccccccccccccc77cccc111111111119999999999999999999999999999999999911111111111111115555555555555555555555551111111111
11111cccccccccccccccccccccc77cccc11111111119999999999999999999999999999999999911111111111111111555555555555555555555511111111111
1111cccccccccccccccccccccccc77cccc1111111119999999999999999999999999999999999911111111111111111155555555555555555555111111111111
1111ccccccccccccccccccccccccc77ccc1111111111999999999999999999999999999999999111111111111111111111555555555555555511111111111111
111cccccccccccccccccccccccccc77cccc111111111999999999999999999999999999999999111111111111111111111115555555555551111111111111111
111cccccccccccccccccccccccccccccccc111111111999999999999999999999999999999999111111111111111111111111155555555111111111111111111
11cccccccccccccccccccccccccccccccccc11111111199999999999999999999999999999991111111111111111111111111111111111111111111111111111
11cccccccccccccccccccccccccccccccccc11111111199999999999999999999999999999991111111111111111111111111111111111111111111111111111
1cccccccccccccccccccccccccccccccccccc1111111199999999999999999999999999999991111111111111111111111111111111111111111111111111111
1cccccccccccccccccccccccccccccccccccc1111111119999999999999999999999999999911111111111111111111111111111111111111111111111111111
1cccccccccccccccccccccccccccccccccccc1111111111999999999999999999999999999111111111111111111111111111111111111111111111111111111
1cccccccccccccccccccccccccccccccccccc1111111111199999999999999999999999991111111111111111111111111111111111111111111111111111111
