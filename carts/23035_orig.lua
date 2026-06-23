-- the slow and the curious
-- 1.2
-- by ethan muller

-- thanks for playing!
 
-- flow handles the state of the whole game. are you on a menu, playing the
-- game, paused, etc. you can use it to stop the game for reasons.
flow = {}

speed = 0.25
-- speed = 2
slowspeed = speed
fastspeed = speed*2

current_tip = 1

top_boundary = 86
bottom_boundary = 99

spawnrate = 80

palettes = {
 {
  -- day colors
  s=12,
  m=13,
  mh=6,
  c=7,
  cs=15,
  b=3,
  bh=11,
  g1=2,
  g2=4,
  t=1
 }, {
  -- afternoon colors
  s=15,
  m=5,
  mh=13,
  c=7,
  cs=6,
  b=3,
  bh=11,
  g1=2,
  g2=4,
  t=1
 }, {
  -- sunset colors
  s=9,
  m=8,
  mh=10,
  c=10,
  cs=8,
  b=3,
  bh=10,
  g1=2,
  g2=4,
  t=2
 }, {
  -- night colors
  s=1,
  m=0,
  mh=13,
  c=13,
  cs=0,
  b=1,
  bh=13,
  g1=0,
  g2=1,
  t=0
 }
}

-- there's probably a better way
-- to do this, but...
stars = {}

for i=0,1,0.05 do
 star={}
 star.x=128*i
 star.y=rnd(70)
 add(stars,star)
end

clr=palettes[1]

--sprites for clouds
bigcloudtable = {12, 44}
littlecloudtable = {10, 26, 42, 58}

obstacletable = {
 {
  name = "rock",
  death_message = "you ran into a rock.",
  taunt = "gneiss job.",
  hitbox = {
   x1 = 1,
   y1 = 2,
   x2 = 6,
   y2 = 7
  },
  sprite = 6
 },
 {
  name = "rock",
  death_message = "your life was taken by granite.",
  taunt = "ha ha ha ha ha, get it?",
  hitbox = {
   x1 = 1,
   y1 = 2,
   x2 = 6,
   y2 = 7
  },
  sprite = 7
 },
 {
  name = "rock",
  death_message = "death by rock.",
  taunt = "that's rough.",
  hitbox = {
   x1 = 1,
   y1 = 2,
   x2 = 6,
   y2 = 7
  },
  sprite = 8
 },
 {
  name = "tire",
  death_message = "you got tired.",
  taunt = "get it? you ran into a tire.",
  hitbox = {
   x1 = 0,
   y1 = 2,
   x2 = 8,
   y2 = 6
  },
  sprite = 22
 },
 {
  name = "banana",
  death_message = "you slipped on a banana peel.",
  taunt = "quit monkeying around!",
  hitbox = {
   x1 = 2,
   y1 = 3,
   x2 = 5,
   y2 = 7
  },
  sprite = 23
 },
 {
  name = "sock",
  death_message = "you were killed by a sock.",
  taunt = "that stinks.",
  hitbox = {
   x1 = 1,
   y1 = 2,
   x2 = 6,
   y2 = 7
  },
  sprite = 24
 },
 {
  name = "lego (tm)",
  death_message = "you stepped on a lego (tm)",
  taunt = "arguably the worst way to go.",
  hitbox = {
   x1 = 2,
   y1 = 4,
   x2 = 5,
   y2 = 5
  },
  sprite = 25
 }
}

tips = {
 "avoid the obstacles!",
 "slow and steady wins the race!",
 "patience is a virtue!",
 "believe in yourself!"
}


-- game functions


function update_player()
 -- p1.frame += 0.25
 p1.frame += speed

 -- prevent from exceeding existing animation frames
 p1.frame %= 2

 p1.y = clamp(p1.y, top_boundary, bottom_boundary)
end

function draw_player ()
 if (death_is_happening) return
 local ofst = flr(p1.frame)*32
 local h = get_absolute_hitbox(p1)
 spr(4+ofst, p1.x-8, p1.y-8, 2,2)
 -- rect(h.x1, h.y1, h.x2, h.y2, 7)
end

function draw_death()
 -- this is sloppy
 -- forgive me

 if (dt>100) return

 -- draw central explosion
 if (dt==2) rectfill(p1.x,p1.y-60, p1.x,p1.y+60, 7)
 if (dt==3) rectfill(p1.x-60,p1.y, p1.x+60,p1.y, 7)
 if (dt<3) circfill(p1.x,p1.y, 15, 7)
 if (dt<20) circ(p1.x,p1.y, 20-dt, 7)

 local num_circles = 20

 for i=1,num_circles do
  local x = p1.x + sin(i/num_circles)*dt*2.5
  local y = p1.y + cos(i/num_circles)*dt*2.5
  local r = (sin(dt/10)+2)*1.5
  circfill(x,y,r,7)
 end
end

function update_bg()
 groundofst += speed

 -- we need a separate
 -- offset for bg,
 -- because it loops
 -- at a different rate
 bgofst1 += speed
 -- this is used for
 -- the back layer.
 -- it moves slower,
 -- creating a parallax effect
 bgofst2 += speed * 0.125

 -- background is tiled every 16 pixels.
 -- this loops around, never exceeding 16
 groundofst %= 16
 bgofst1 %= 24
 bgofst2 %= 24
end

function next_time_of_day()
 set_time_of_day(time_of_day%#palettes+1)
end

function set_time_of_day(tod)
 init_clouds()
 time_of_day=tod
 clr=palettes[time_of_day]
end

function draw_bg ()
 -- underground
 rectfill(0,0, 127,127, 0)

 -- sky
 rectfill(0,0,127,80,clr.s)

 -- we need to change transparency for
 -- clouds, since they use the color
 -- we're using for transparency
 -- elsewhere
 palt(15,false)
 palt(12,true)

 if time_of_day == 2 then
  -- draw sun
  circfill(123,5,12,7)
 end

 if time_of_day == 3 then
  -- draw sunset
  circfill(60,60,12,7)
  circ(60,60,12,10)
 end

 if time_of_day == 4 then
  -- draw stars
  local star_color_ramp={1,5,13,7}

  -- sparkly stars!
  for i=1,#stars do
   local star=stars[i]
   local osc = sin(t/100 + (0.33*i%3))
   local color = flr((osc+1)/2*(#star_color_ramp-1) + 0.3)+1
   local sc = star_color_ramp[color]
   pset(star.x,star.y,sc)
  end
 end

 -- draw clouds
 pal(7,clr.c)
 pal(15,clr.cs)
 for c in all(clouds) do
  if c.big then
   spr(c.sprite, c.x, c.y, 4, 2)
  else
   spr(c.sprite, c.x, c.y, 2, 1)
  end
 end
 pal(7,7)
 pal(15,15)

 -- reset cloud transparencies
 palt(15,true)
 palt(12,false)

 -- mountains
 pal(13,clr.m)
 pal(6,clr.mh)
 map(0,5, 0,40, 16,3)
 rectfill(0,64, 128,88, 13)
 pal(13,13)
 pal(6,6)
 
 -- trees
 pal(1,clr.t)
 pal(3,clr.b)
 pal(11,clr.bh)
  map(0,10, -bgofst2,71, 19,1)
  rectfill(0,79, 128,86, 1)

  map(0,8, -bgofst1,76, 19,1)

  rectfill(0,84, 128,86, 3)
  map(0,9, -bgofst1,79, 19,1)
  rectfill(0,87, 128,87, 0)
 pal(1,1)

  -- ground

 pal(2,clr.g1)
 pal(4,clr.g2)
  map(0,0, -groundofst,88, 18,5)
 pal(2,2)
 pal(3,3)
 pal(4,4)
 pal(11,11)

end

function handle_controls ()
 if (death_is_happening) then
  return
 end

 if (btn(4)) then
  speed = fastspeed
 else
  speed = slowspeed
 end

 -- if (btnp(5)) next_time_of_day()

 if (btn(2)) p1.up()
 if (btn(3)) p1.down()
end

function update_enemies ()
 if (spawncooldown <= 0) then
  spawn_enemy()
 end

 -- loop through each enemy
 for e in all(enemies) do
  move_enemy(e)
  if not game_over then
   handle_collisions(e)
   if (not e.did_score) check_for_score(e)
  end
  despawn_enemy_if_necessary(e)
 end
end

function update_clouds ()
 for c in all(clouds) do
  c.x -= c.speed

  if c.x < -32 then
   --wrap around
   c.x = 128

   -- randomize sprite
   c.sprite = pick_random_cloud_sprite(c.big)

   -- randomize y value
   c.y = pick_random_cloud_y()
  end
 end
end

function move_enemy(e)
 if (e.y<p1.y) then
  e.layer=-1
 else
  e.layer=1
 end
 e.x -= speed
end

function handle_collisions(e)
 local p1box = get_absolute_hitbox(p1)
 local ebox = get_absolute_hitbox(e)
 if are_boxes_intersecting(p1box, ebox) then
  death(e)
 end
end

function check_for_score(e)
 if e.x < p1.x then
  score(e)
 end
end

function score(e)
 e.did_score=true
 player_score+=1
 last_score_at=t+1
 sfx(45,3)
end

function despawn_enemy_if_necessary(e)
  if e.x < -10 then
   del(enemies,e)
  end
end

function init_clouds ()
 clouds = {}

 -- this distributes clouds relatively evenly,
 -- but still randomly
 create_cloud(rnd(32)+0,  8 * 1)
 create_cloud(rnd(32)+32, 8 * 3, true)
 create_cloud(rnd(32)+64, 8 * 2)
 create_cloud(rnd(32)+96, 8 * 4, true)
end

function create_cloud (x,y,big)
 speed = 0.1 + rnd(0.1)
 add(clouds, {
  x = x,
  y = y,
  sprite = pick_random_cloud_sprite(big),
  speed = speed,
  big = big
 })
end

function pick_random_cloud_sprite(big)
 local ct
 if big then
  ct = bigcloudtable
 else
  ct = littlecloudtable
 end
 return ct[flr(rnd(#ct))+1]
end

function pick_random_cloud_y()
 return rnd(50) + 10
end

function spawn_enemy  ()
  local e = {}
  --subtracting groundofst
  --to ensure enemies
  --are aligned with
  --bg. adding 16 to
  --prevent enemies
  --from spawning onscreen
  e.x = 128-groundofst+16
  local yrange = bottom_boundary - top_boundary

  e.y = top_boundary + flr(rnd(yrange))

  --1 in 10 chance
  --an enemy spawns
  --at player's position!
  --gotta keep them on
  --their toes!
  if (rnd(10)<1) e.y=p1.y

  e.obstacle = pick_obstacle()
  e.hitbox = obstacletable[e.obstacle].hitbox

  add(enemies,e)

  spawncooldown = spawnrate
end

function pick_obstacle()
 -- start with rocks
 if (t < 200) return flr(rnd(3)) + 1

 if rnd(10) > 5 then
  if (rnd(10) > 9) return 7
  if (rnd(10) > 8) return 6
  if (rnd(10) > 7) return 5
  return 4
 end

 return flr(rnd(3)) + 1
end

function get_absolute_hitbox(table)
 local hitbox = {}

 hitbox.x1 = table.x + table.hitbox.x1
 hitbox.y1 = table.y + table.hitbox.y1
 hitbox.x2 = table.x + table.hitbox.x2
 hitbox.y2 = table.y + table.hitbox.y2

 return hitbox
end

function are_boxes_intersecting (boxa, boxb)
 if (boxa.x2 < boxb.x1) return false -- a is left of b
 if (boxa.x1 > boxb.x2) return false -- a is right of b
 if (boxa.y2 < boxb.y1) return false --  a is above b
 if (boxa.y1 > boxb.y2) return false --  a is below b

 return true
end

function corners_intersecting_box (corners,x1,y1,x2,y2)
 for c in all(corners) do
  -- loop through corners of bounds,
  -- check if they're in the box
  if c[1] >= min(x1,x2) and
     c[1] <= max(x1,x2) and
     c[2] >= min(y1,y2) and
     c[2] <= max(y1,y2) then
   return true
  end
 end
 return false
end

function draw_enemies (layer)
 for e in all(enemies) do
  if e.layer == layer then
   local o = obstacletable[e.obstacle]
   pal(3,clr.b)
   spr(o.sprite, e.x, e.y)
   pal(3,3)
  end
 end
end

function draw_box_from_point (x,y, box, color)
 local x1 = x + box.x1
 local y1 = y + box.y1
 local x2 = x + box.x2
 local y2 = y + box.y2
 rect(x1, y1, x2, y2, color)
end

function death(e)
 if (death_is_happening) return
 game_over=true
 killed_by=obstacletable[e.obstacle]
 death_is_happening=true
 stop_music()
 sfx(27)

 -- death time
 dt=0
end

function draw_score ()
 -- draw tally slashes
 for i=5,player_score,5 do
  local x=((i/5)*10-9)%120
  local y=3 + flr((i-1)/60)*10
  line(x,y+2,x+8,y+5,6)
  line(x,y+1,x+8,y+4,7)
 end
 -- draw tally marks
 for i=1,player_score do
  if not (i % 5 == 0) then
   local x=(i)%60
   local y=3 + flr((i-1)/60)*10
   line(x*2,0+y+1,x*2,5+y+1,6)
   line(x*2,0+y,x*2,5+y,7)
  end
 end
end

function draw_score_sprite()
 if last_score_at > 0 then
  local diff = t - last_score_at
  if diff < 20 then
   spr(35,p1.x-5,p1.y-25+(diff+10)/diff)
  end
 end
end

function start_music()
 music(0)
 music_playing=true
 current_music_pattern=0
end

function stop_music()
 music(-1)
 music_playing=false

 -- this helps prevent a weird
 -- bug where the game starts
 -- at night time
 pattern_hash=0
 last_pattern_hash=0
end

function update_current_music_pattern()
 --note: this is super duper fragile.
 --changing the song or channels
 --will probably break this code.

 if music_playing then
  -- this is a combination of currently-playing
  -- sfx. we compare it to the last one every update
  -- to check if the pattern has changed.
  -- we're leaving out the third channel,
  -- since it's used for sfx
  pattern_hash=stat(16)+stat(17)*stat(18)

  if (pattern_hash != last_pattern_hash) current_music_pattern+=1

  -- loop around, back to 0
  current_music_pattern%=64

  last_pattern_hash=pattern_hash
 else
  current_music_pattern=-1
 end
end

function update_time_of_day()
 local current_tod = time_of_day

 local tod=1

 if current_music_pattern >= 16 then
  tod=2
 end

 if current_music_pattern >= 32 then
  tod=3
 end

 if current_music_pattern >= 56 then
  tod=4
 end

 if current_tod != tod then
  set_time_of_day(tod)
 end
end

-- high-level flow functions
-- y'know, like init/update/draw type of functions

function init_game ()
 start_music()
 current_music_pattern=-1

 set_time_of_day(1)

 -- make tan transparent
 -- instead of black
 palt(15,true)
 palt(0,false)

 last_score_at=-1

 player_score=0
 
 -- phew, thank heavens
 death_is_happening=false
 game_over=false
 killed_by=nil
 
 t=0
 spawncooldown=0
 -- spawncooldown=spawnrate*0.2
 enemies = {}

 init_clouds()

 groundofst = 0
 bgofst1 = 0
 bgofst2 = 0

 p1 = {}
 p1.x = 15
 p1.y = 94
 p1.frame = 0

 --for hitbox
 p1.hitbox = {
  x1 = -7,
  y1 = -1,
  x2 = 7,
  y2 = 3
 }
 p1.width = 15
 p1.height = 6
 p1.hw = p1.width/2
 p1.hh = p1.height/2

 function p1.up()
  p1.y -= speed/2
 end

 function p1.down()
  p1.y += speed/2
 end

 update_player()
end

function update_game ()
 handle_controls()
 update_player()
 update_enemies()
 update_bg()
 update_clouds()

 if music_playing then
  update_current_music_pattern()
  update_time_of_day()
 end

 t+=1
 spawncooldown-=speed

 if death_is_happening then
  dt+=1
  if (dt>=100) set_flow("end")
 end
end

function draw_game ()
 cls()
 draw_bg()
 draw_enemies(-1) -- enemies behind p1
 draw_player()
 draw_enemies(1) -- enemies in front of p1
 draw_score()
 draw_score_sprite()

 if death_is_happening then
  draw_death()
 end
end

function init_end ()
 back_to_menu_timer=0
end

function init_menu ()
 t=0
 for c=0,16 do
  palt(c,false)
 end
end

function update_menu ()
 -- blinky text
 if flr(t/20)%2 == 1 then
  textcolor=0
 else
  textcolor=7
 end

 -- this is used to prevent jumping into the game
 -- immediately after looping back from end state
 if (not btn(4)) button_has_been_up=true

 if button_has_been_up and btnp(4) then
  button_has_been_up=false
  set_flow("game")
 end
 t+=1
end

function draw_menu ()
 cls()
 local anm=min(t/100,1)
 
 --draw title
 print("the", 64-(4*3)/2,4, 6)
 map(41,0, 38,11, 7,2)
 print("and the", 64-(4*7)/2,30, 6)
 map(41,2, 27,37, 10,2)
 
 -- draw sloth
 map(32,0, -64+64*anm,128-64*anm, 8,8)
 
 print("press z to\nstart game", 68,80,textcolor)
 
 print("up/down: move", 68,110,5)
 print("hold z:  turbo", 68,118)
end

function update_end ()
 -- this block is similar to update_game!
 update_enemies()
 update_bg()
 update_clouds()
 t+=1

 spawncooldown-=speed

 if btn(4) then
  back_to_menu_timer+=0.05
 else
  back_to_menu_timer=0
 end

 if back_to_menu_timer >= 1 then
  -- increase current_tip, but loop
  -- around to 1 when we hit the max
  -- number of tips
  current_tip%=#tips
  current_tip+=1

  set_flow("menu")
 end
end

function draw_end ()
 -- this block is similar to draw_game!
 cls()
 draw_bg()
 draw_enemies()
 -- draw_score()
 
 -- print(back_to_menu_timer)

 --note: using camera() to offset text box
 --because i'm lazy

 rectfill(0,0, 128,8, 0)

 if back_to_menu_timer then
  rectfill(-1,0, 128*back_to_menu_timer-1,8, 1)
 end

 if t%40 < 20 then
  local restart_message="hold z to restart"
  print(restart_message, 64-(4*#restart_message)/2, 2, 7)
 end

 --anti-cheat pixel ;)
 pset(127,0, player_score)

 camera(0,-74)

 -- draw text boxes
 line(0,-1, 128,-1, 0)
 rectfill(0,0, 128,20, 1)
 rectfill(0,21, 128,32, 0)
 rectfill(0,33, 128,54, 13)

 print(killed_by.death_message, 3,4, 7)
 print(killed_by.taunt, 3,12, 6)
 print("final score: ", 3,25, 6)
 print(player_score, 52,25, 12)

 print("hot tip:", 3,37, 1)

 -- wavy text!
 local tip=tips[current_tip]
 for c=1,#tip do
  local y = 46 + sin(t/30 + c/20)-0.5
  --shadow
  print(sub(tip,c,c), 4*c-1,y+1, 1)
  print(sub(tip,c,c), 4*c-1,y, 7)
 end

 camera(0,0)
end

function set_flow (newflow, flowdata)

 if newflow == "menu" then
  init_menu(flowdata)
  flow.update = update_menu
  flow.draw = draw_menu
 end

 if newflow == "game" then
  init_game(flowdata)
  flow.update = update_game
  flow.draw = draw_game
 end

 if newflow == "end" then
  init_end(flowdata)
  flow.update = update_end
  flow.draw = draw_end
 end

end

function _init ()
 set_flow ("menu")
end

function _update ()
 flow.update()
end

function _draw ()
 flow.draw()
end

-- utilities
function clamp(val, mn, mx)
 return min(max(val,mn),mx)
end