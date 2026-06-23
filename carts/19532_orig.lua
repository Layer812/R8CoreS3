-- ~the wee dungeon~ --
-- bradley elliott

-----------
--globals--
-----------

--input variables
k_left=0
k_right=1
k_up=2
k_down=3
k_attack=4
k_shield=5

--set to true to build a new room
new_room = false

--a container to hold the current room chunks
cur_room = {}

--a container to hold each room in order
dungeon = 0

--a container to store our objects and players
objects = {}
players = {}

--defaults for camera controls
cam_x = 0
cam_y = 0

cursor_x = 10
cursor_y = 77
cursor_p = 1

--a container to hold debug info
debug = {}


--a container for the allowed chunks
allowed_next_chunk = {}

--container for list of exits for each chunk 0 is to the right, 1 is down, -1 is up
exits = {}

--container to store chunk coordinates (for collision detection). the first chunk is already added
chunk_coords = 
{
  {0,0}
}

chunk_coords_stored = false

--player's current chunk

--build mosnters
build_monsters = true

--monster container (x,y,chunk)
monsters = {}

--container for monster types
monster_type = { 192,208,208,211,196,200 }

difficulty = 0

--do something different when player dies
dead = false
death_timer = 40

--how much gold did you have when you died
gold = 0
gold_p2 = 0

--title screen
title = true

-----------------
--player object--
-----------------
player = 
{
  init=function(this)
    --set the sprite and hitbox
    this.spr = 1
    this.spr_stand = 2
    this.hitbox = {x=3,y=1,w=5,h=7}
    this.hp = 10
    this.damage = 0
    init_inventory(this, 1,0,0,0,0)
    --build inventory items (for placement purposes)
    create_equipment(this)
    if #players > 1 then this.player = 1 else this.player = 0 end
  end,
  update=function(this)
    if this.hp <= 0 then
      this.spr = 0
      init_inventory(this, 0,0,0,0,this.inventory.gold)
      this.spd = {x=0,y=0}
      if death_timer > 0 then
        if death_timer == 40 then
          for i=0,4 do
            init_object(smoke, this.x+4, this.y+4)
          end
          sfx(21)
          if #players == 1 then
            music(-1)
          end
        end
        death_timer -= 1
      else
        if this.player == 0 then
          gold = this.inventory.gold
        else
          gold_p2 = this.inventory.gold
        end
        if #players == 1 then
          dead = true
        else
          death_timer = 40
        end 
        destroy_player(this)   
      end
    elseif this.hp > 0 and not new_room then
      if this.hp > 10 then this.hp = 10 end
      set_equipment(this)
      --collision variables
      tile_info(this)
      --movement variables
      get_sign(this)

      --set left/right movement controls
      local input
      if not this.attacking and not this.defending then
        input = btn(k_right, this.player) and 1 or (btn(k_left, this.player) and -1 or 0)
      else
        input = 0
      end
      if this.hit then input = 0 end
      --movement
      if abs(this.spd.x) > this.maxrun then
    		this.spd.x=appr(this.spd.x,this.sign*this.maxrun,this.deccel)
      else
        this.spd.x=appr(this.spd.x,input*this.maxrun,this.accel)
      end

      --get "kicked" back if hit
      kick(this)

      --attacking
  		if btnp(k_attack, this.player) and this.attacking == false and not this.hit then
  			this.attacking = true
        sfx(22)
        this.weapon.spr_atk = 8
        if this.defending then
          this.spd.x += 1.5*this.sign
        end
  		end

      if this.attacking and this.atk_timer < 5 then
        this.atk_timer += 1
        if abs(this.spd.x) > this.maxrun then
          this.spd.x = this.maxrun*this.sign
        else
          this.spd.x *=.95
        end
      else
        this.atk_timer = 0
        this.attacking = false
        this.weapon.spr_atk = 0
        this.deccel=.05
        this.spd.x=appr(this.spd.x,this.sign*this.maxrun,this.deccel)
        if this.spd.x < .1 and this.spd.x > -.1 then this.spd.x = 0 end
      end

      --defending
  		if btn(k_shield, this.player) and not this.hit then
  			this.defending = true
      else
        this.defending = false
  		end

      --if the player is jumping and lets go of the button, deccelerate.
      if this.spd.y < 0 and not btn(k_up, this.player) then this.spd.y +=.5 end

      --basic camera control
      if cam_x < this.x-63 then
        cam_x += 1.5
      elseif cam_x > this.x-60 then
        cam_x -= 1.5
      end
      if cam_y < this.y-63 then
        cam_y += 1.5
      elseif cam_y > this.y-60 then
        cam_y -= 1.5
      end

      --facing
      if this.spd.x!=0 and not this.hit then
        this.flip.x=(this.spd.x<0)
      end

      --animate player
      animate(this)

      --figure out which chunk the player is currently in (for collisions)
      get_chunk(this)

      take_damage(this)

      --collisions
      get_collisions(this)
      
      --jump
    	if this.on_ground then
    		if btn(k_up, this.player) and not this.hit then
    			sfx(20)
    			this.spd.y = -this.jumpheight
    		end
    	end
      
      --update equipment placement
      place_equipment(this)

      if this.tile_below == 240 and this.spd.y > 0 then
        --this.hp = 0
        if this.inventory.shield == 0
        and this.inventory.armor == 0
        and this.inventory.helmet == 0
        and this.inventory.weapon == 1
        and not this.hit
        then
          this.hp = 0
        else
          this.inventory.shield = 0
          this.inventory.armor = 0
          this.inventory.helmet = 0
          this.inventory.weapon = 1
          this.hit = true
          for i=0,4 do
            init_object(smoke, this.x+4, this.y+4)
          end
        end
      end

      --enter door (new room)
      if btnp(k_down, this.player) then
        if this.tile_under == 30 then
          this.x = 16
          this.y = 112
          cam_x = this.x-60
          cam_y = this.y-60
          difficulty += .5
          this.chunk = 1
          sfx(26)
          new_room = true
        end
      end
      
    end
  end,
  draw=function(this)
    if this.hit and this.h_timer >= this.h_timer_max-2 then
      for i=0,15 do
        pal(i,8)
      end
    end
    --if shield isn't up, draw it behind the player
    if not this.defending then
      if this.inventory.shield > 0 then
        spr(this.shield.spr+(this.inventory.shield-1),this.shield.x-(2*this.sign),this.shield.y,1,1,this.flip.x,this.flip.y)
      end
    end
    
    --draw sprite
    spr(this.spr,this.x,this.y,1,1,this.flip.x,this.flip.y)

    --draw equipment
    if this.inventory.armor > 0 then
      spr(this.armor.spr+(this.inventory.armor-1),this.armor.x,this.armor.y,1,1,this.flip.x,this.flip.y)
    end
    if this.inventory.helmet > 0 then
      spr(this.helmet.spr+(this.inventory.helmet-1),this.helmet.x,this.helmet.y,1,1,this.flip.x,this.flip.y)
    end
    if this.defending then
      if this.inventory.shield > 0 then
        spr(this.shield.spr+(this.inventory.shield-1),this.shield.x,this.shield.y,1,1,this.flip.x,this.flip.y)
      end
    end
    if this.inventory.weapon > 0 and not this.hit then
      spr(this.weapon.spr+(this.inventory.weapon-1)+this.weapon.spr_atk,this.weapon.x,this.weapon.y,1,1,this.flip.x,this.flip.y)
    end
    pal()
  end
}

monster = 
{
  init=function(this)
    --randomly select the monster type
    local getmonster = rnd(1)+difficulty
    local types
    if getmonster >= 1 and getmonster < 2 then
      types = {2,3,3,3,4}
    elseif getmonster >= 2 and getmonster < 3 then
      types = {1,2,3,4,4,4}
    elseif getmonster >= 3 and getmonster < 4 then
      types = {1,1,1,1,1,5,2,3,4}
    elseif getmonster >= 4 and getmonster < 5 then
      types = {1,1,1,5,5,5,2,3,4}
    elseif getmonster >= 5 and getmonster < 6 then
      types = {1,5,5,5,5,5,6,2,3,4}
    elseif getmonster >= 6 and getmonster < 7 then
      types = {1,1,5,5,6,6,2,3,4}
    elseif getmonster >= 7 then
      types = {1,5,6,6,6,6,2,3,4}
    else  
      types = {2,2,2,2,2,2,3,4}
    end
    this.randmonster = types[flr(rnd(#types))+1]
    --set the sprite and hitbox
    this.spr = monster_type[this.randmonster]
    this.spr_stand = monster_type[this.randmonster]+1
    this.hitbox = {x=3,y=1,w=5,h=7}
    --control the animation speed
    this.start_x = this.x
    this.start_y = this.y
    
    
    this.maxrun = rnd(1.25)
    if this.spr >= 208 and this.spr <= 223 then
      this.hp = flr(rnd(4))+1
    elseif this.spr >= 192 and this.spr <= 207 then
      this.hp = flr(rnd(5))+5
    end
    
    if this.randmonster == 3 then this.hp += 5 end
    if this.randmonster == 4 then this.hp += 10 end
    if this.randmonster == 5 then this.hp += 5 end
    if this.spr >= 192 and this.spr <= 207 then
      init_inventory(
        this, 
        flr(rnd(7))+1,
        flr(rnd(8)),
        flr(rnd(8)),
        flr(rnd(8)),
        flr(rnd(8))
      )
    else
      init_inventory(this,0,0,0,0,flr(rnd(5)))
    end
    --build inventory items (for placement purposes)
    create_equipment(this)

    this.lasthit = 0
  end,
  update=function(this)
    if new_room or this.hp <= 0 then
      
      if not new_room then
        for i=0,4 do
          init_object(smoke, this.x+4, this.y+4)
        end
        for i=0,this.inventory.gold do
          init_object(goldcoin, this.x+4, this.y+4)
        end
        if rnd(1) > .5 then
          init_object(health, this.x+4, this.y+4)
        end
        --if rnd(1) > 0 then
        if rnd(1) > .9 then
          init_object(itemdrop, this.x+4, this.y+4, nil, this.lasthit)
        end
      end
      destroy_object(this)
    else
      set_equipment(this)
      --collision variables
      tile_info(this)
      
      --movement variables
      get_sign(this)

      --movement
      local input
      if this.flip.x then input = -1 else input = 1 end
      if abs(this.spd.x) > this.maxrun then
        --this.spd.x = 0
        this.spd.x=appr(this.spd.x,this.sign*this.maxrun,this.deccel)
      else
        this.spd.x=appr(this.spd.x,input*this.maxrun,this.accel)
      end

      kick(this)

      --stop skeleton when player is nearby
      if this.randmonster == 1 then
        for k,v in pairs(players) do
          if this.x <= players[k].x+players[k].hitbox.w+12 and this.x >= players[k].x+players[k].hitbox.x-16 and this.y >= players[k].y+players[k].hitbox.y-4 and this.y <= players[k].y+players[k].hitbox.h+4 then
            this.spd.x = 0
            if this.atk_timer == 0 then
              this.atk_timer = 20
              this.attacking = true
              this.weapon.spr_atk = 8
              this.spd.x = this.sign
            else  
              this.atk_timer -= 1
              this.attacking = false
              this.weapon.spr_atk = 0
            end
            
            --face player
            if this.x <= players[1].x then
              this.flip.x = false
              this.sign = 1
            else
              this.flip.x = true
              this.sign = -1
            end
          else
            this.attacking = false
            if abs(this.spd.x) > this.maxrun then
              --this.spd.x = 0
              this.spd.x=appr(this.spd.x,this.sign*this.maxrun,this.deccel)
            else
              this.spd.x=appr(this.spd.x,input*this.maxrun,this.accel)
            end
          end
        end
      end
      
      --animate
      animate(this)
      --get object's current chunk
      get_chunk(this)
      --update equipment placement
      place_equipment(this)
      --see if this monster has been hit (attacker, defender)
      for k,v in pairs(players) do
        check_attack(players[k], this)
        if this.randmonster == 1 then
          --see if this monster has hit the player
          check_attack(this, players[k])
        end
        --check if this slime has touched the player
        check_touch(this, players[k])

        --do stuff when this is hit
        take_damage(this)
        --check collisions
        get_collisions(this)

        if this.hit then
          if this.h_timer == this.h_timer_max then
            this.spd.x = 1.15*players[k].sign
            this.spd.y -= .3
            local do_damage
            if this.inventory.helmet > 0 then
              this.helmet.hp -= players[k].inventory.weapon
            elseif this.inventory.armor > 0 then
              this.armor.hp -= players[k].inventory.weapon
            else
              this.hp -= players[k].inventory.weapon
            end
            sfx(21)
            this.h_timer -= 1
          elseif this.h_timer == 0 then
            this.hit = false
            this.h_timer = this.h_timer_max
          else  
            this.h_timer -= 1
          end
        end
        if this.deflected and players[k].inventory.shield > 0 then
          if this.h_timer == this.h_timer_max then
            this.spd.x = 1.15*players[k].sign
            this.spd.y -= .3
            players[k].shield.hp -= 1
            this.h_timer -= 1
            sfx(23)
          elseif this.h_timer == 0 then
            this.deflected = false
            this.h_timer = this.h_timer_max
          else  
            this.h_timer -= 1
          end
        end

        if this.defending and this.inventory.shield > 0 then
          if players[k].h_timer == players[k].h_timer_max then
            players[k].kick.x = 1.15*this.sign
            players[k].spd.y -= .3
            this.shield.hp -= 1
            players[k].h_timer -= 1
            sfx(23)
          elseif players[k].h_timer == 0 then
            this.defending = false
            players[k].h_timer = players[k].h_timer_max
          else  
            players[k].h_timer -= 1
          end
        end
        
      end
    end
      
      
  end,
  draw=function(this)
    if this.randmonster == 3 then
      pal(11, 8)
      pal(3,2)
    end
    if this.hit and this.h_timer >= this.h_timer_max-2 then
      for i=0,15 do
        pal(i,8)
      end
    end
    --if shield isn't up, draw it behind the player
    if not this.defending then
      if this.inventory.shield > 0 then
        spr(this.shield.spr+(this.inventory.shield-1),this.shield.x-(2*this.sign),this.shield.y,1,1,this.flip.x,this.flip.y)
      end
    end
      
      spr(this.spr,this.x,this.y,1,1,this.flip.x,this.flip.y)
      --draw equipment
      if this.inventory.armor > 0 then
        spr(this.armor.spr+(this.inventory.armor-1),this.armor.x,this.armor.y,1,1,this.flip.x,this.flip.y)
      end
      if this.inventory.helmet > 0 then
        spr(this.helmet.spr+(this.inventory.helmet-1),this.helmet.x,this.helmet.y,1,1,this.flip.x,this.flip.y)
      end
      if this.defending then
        if this.inventory.shield > 0 then
          spr(this.shield.spr+(this.inventory.shield-1),this.shield.x,this.shield.y,1,1,this.flip.x,this.flip.y)
        end
      end
      if this.inventory.weapon > 0 and not this.hit then
        spr(this.weapon.spr+(this.inventory.weapon-1)+this.weapon.spr_atk,this.weapon.x,this.weapon.y,1,1,this.flip.x,this.flip.y)
      end
    pal()
  end
}

smoke = 
{
  init=function(this)
    this.radius = flr(rnd(3))+4
    this.dir_x = flr(rnd(3))
    this.dir_y = flr(rnd(3))
    this.dirvar_x = rnd(1)
    this.dirvar_y = rnd(1)
    if this.dirvar_x < 0.5 then this.dirvar_x = -1 else this.dirvar_x = 1 end
    if this.dirvar_y < 0.5 then this.dirvar_y = -1 else this.dirvar_y = 1 end
  end,
  update=function(this)
    if this.radius == 0 or new_room then
      destroy_object(this)
    end
    this.radius -= 1
    this.x += this.dir_x*this.dirvar_x
    this.y += this.dir_y*this.dirvar_y
  end,
  draw=function(this)
    circfill(this.x, this.y, this.radius)
  end
}

goldcoin = 
{
  init=function(this)
    this.spd.y = -1*flr(rnd(3))
    this.dirvar_x = rnd(1)
    if this.dirvar_x < 0.5 then 
      this.dirvar_x = -1 
    elseif this.dirvar_x > 0.5 then
      this.dirvar_x = 1 
    end
    this.spd.x = rnd(2)*this.dirvar_x
    this.gfx = 1
    this.hitbox = {x=-1,y=-1,w=1,h=1}
    this.sign = 1
    this.life = 400
  end,
  update=function(this)
    if new_room or this.life == 0 then
      destroy_object(this)
    end
    this.life -= 1
    tile_info(this)

    --movement variables
    if this.spd.x < 0 then
      this.spd.x += .05
    elseif this.spd.x > 0 then
      this.spd.x -= .05
    end
    
    --figure out which chunk the player is currently in (for collisions)
    get_chunk(this)

    get_collisions(this)
    
    for k,v in pairs(players) do
      if touching_player(this, players[k]) then
          players[k].inventory.gold +=1
          sfx(24)
          destroy_object(this)
      end
    end
    
  end,
  draw=function(this)
    if this.gfx < 4 then
      rectfill(this.x-1,this.y-1,this.x+1,this.y+1,10)
      this.gfx +=1
    elseif this.gfx < 8 and this.gfx > 3 then
      rectfill(this.x,this.y-1,this.x,this.y+1,9)
      this.gfx +=1
    else
      this.gfx = 1
    end
    color(6)
  end
}

hitpoints = 
{
  init=function(this)
    this.start_y = this.y
  end,
  update=function(this)
    this.y -= 1
    if this.y <= this.start_y-10 then
      destroy_object(this)
    end
  end,
  draw=function(this)
    local color
    if this.damage_taken > 0 then
      color = 11
    elseif this.critical != 0 then
      color = 8
    else
      color = 6
    end
    print(this.damage_taken, this.x, this.y, color)
  end
}

health = 
{
  init=function(this)
    this.spd.y = -1*flr(rnd(3))
    this.dirvar_x = rnd(1)
    if this.dirvar_x < 0.5 then this.dirvar_x = -1 else this.dirvar_x = 1 end
    this.spd.x = flr(rnd(2))*this.dirvar_x
    this.gfx = 1
    this.hitbox = {x=-1,y=-1,w=1,h=1}
    this.sign = 1
    this.life = 400
  end,
  update=function(this)
    if new_room or this.life == 0 then
      destroy_object(this)
    end
    this.life -= 1

    tile_info(this)

    --movement variables
    if this.spd.x < 0 then
      this.spd.x += .05
    elseif this.spd.x > 0 then
      this.spd.x -= .05
    end
    
    --figure out which chunk the player is currently in (for collisions)
    get_chunk(this)

    get_collisions(this)

    for k,v in pairs(players) do
      if touching_player(this, players[k]) then
          if players[k].hp != 10 then
            players[k].hp +=1
          end
          sfx(25)
          if players[k].hp < 10 then
            init_object(hitpoints, players[k].x, players[k].y, 1)
          end
          destroy_object(this)
      end
    end
  end,
  draw=function(this)
    if this.gfx < 4 then
      rectfill(this.x-1,this.y-1,this.x+1,this.y+1,12)
      this.gfx +=1
    elseif this.gfx < 8 and this.gfx > 3 then
      rectfill(this.x,this.y-1,this.x,this.y+1,1)
      this.gfx +=1
    else
      this.gfx = 1
    end
    color(6)
  end
}

itemdrop = 
{
  init=function(this)
    this.spd.y = -1*flr(rnd(3))
    this.dirvar_x = rnd(1)
    this.spd.x = 0
    this.gfx = 1
    this.hitbox = {x=0,y=0,w=8,h=8}
    this.life = 400
    local w
    local s
    local a
    local h
    if players[this.killed_by+1].inventory.weapon < 8 then w = players[this.killed_by+1].inventory.weapon+1 else w = 8 end
    if players[this.killed_by+1].inventory.shield < 8 then s = players[this.killed_by+1].inventory.shield+1 else s = 8 end
    if players[this.killed_by+1].inventory.armor < 8 then a = players[this.killed_by+1].inventory.armor+1 else a = 8 end
    if players[this.killed_by+1].inventory.helmet < 8 then h = players[this.killed_by+1].inventory.helmet+1 else h = 8 end
    this.items = 
    {
      --flr(rnd(8))+1,
      --flr(rnd(8))+1,
      --flr(rnd(8))+1,
      --flr(rnd(8))+1
      w,s,a,h
    }
    
    this.itemnum = flr(rnd(#this.items))+1
    if this.itemnum == 0 then this.itemnum = 1 end
    this.the_item = this.items[this.itemnum]

    if this.the_item > 8 then this.the_item = 8 end
  end,
  update=function(this)
    if new_room or this.life == 0 then
      destroy_object(this)
    end
    this.life -= 1
    tile_info(this)

    get_chunk(this)

    get_collisions(this)

    for k,v in pairs(players) do
      if touching_player(this, players[k]) then
          if this.itemnum == 1 then
            players[k].inventory.weapon = this.the_item
          elseif this.itemnum == 2 then
            players[k].inventory.shield = this.the_item
            players[k].shield.hp = 3*this.the_item
          elseif this.itemnum == 3 then
            players[k].inventory.armor = this.the_item
            players[k].armor.hp = 3*this.the_item
          elseif this.itemnum == 4 then
            players[k].inventory.helmet = this.the_item
            players[k].helmet.hp = 3*this.the_item
          end
          sfx(27)
          destroy_object(this)
      end
    end
  end,
  draw=function(this)
    if this.itemnum == 1 then
      spr(31+this.the_item, this.x, this.y)
    elseif this.itemnum == 2 then
      spr(47+this.the_item, this.x, this.y)
    elseif this.itemnum == 3 then
      spr(7+this.the_item, this.x, this.y)
    elseif this.itemnum == 4 then
      spr(15+this.the_item, this.x, this.y)
    end
    
  end
}

function _init()
  --a list of allowed next chunks for each chunk
  allowed_next_chunk = 
  {
    {2,4,9,10,12,18,20,21,23,24},
    {1,4,9,10,12,18,20,21,23,24},
    {1,2,4,9,10,12,18,20,21,23,24},
    {5,6,11,13,14,16},
    {6,11,13,14,16},
    {5,11,13,14,16},
    {1,2,4,9,10,12,18,20,21,23,24},
    {1,2,4,9,10,12,18,20,21,23,24},
    {1,2,4,10,12,18,20,21,23,24},
    {1,2,4,9,12,18,20,21,23,24},
    {1,2,4,9,10,12,18,20,21,23,24},
    {3,8,17},
    {5,6,11,14,16},
    {5,6,11,13,16},
    {0},
    {1,2,4,9,10,12,18,20,21,23,24},
    {1,2,4,9,10,12,18,18,18,18,18,18,18,18,20,20,20,20,20,20,20,21,23,24},
    {19,19,19,19,22},
    {1,2,4,9,10,12,18,20,20,20,20,20,20,20,20,20,20,21,23,24},
    {1,2,4,9,10,12,18,21,23,24},
    {19,22,22,22,22},
    {1,2,4,9,10,12,18,20,21,23,24},
    {5,6,11,13,14,16},
    {3,8,17}
  }

  exits = { 
  	0,0,0,1,1,1,0,0,
  	0,0,0,-1,1,1,0,0,
    0,0,0,0,0,0,1,-1}
  music(0,0,14)
end

function _update()
  --if new_room is true, we'll build a new room
  if new_room then
    build_new_room()
  elseif dead then
    foreach(objects, function(obj)
      destroy_object(obj)
    end)
    if btnp(k_attack, 0) then
      new_room = true
      dungeon = 0
      init_object(player, 16, 112)
      if cursor_p == 2 then
        init_object(player, 24, 112)
      end
      cam_x = players[1].x-60
      cam_y = players[1].y-60
      music(0,0,14)
      death_timer = 40
      dead = false
    end
  elseif title then
    if btnp(k_down, 0) or btnp(k_up, 0) then
      sfx(23)
      if cursor_p == 1 then
        cursor_p = 2
        cursor_y = 87
      else
        cursor_p = 1
        cursor_y = 77
      end
    end
    if btnp(k_attack, 0) then
      new_room = true
      dungeon = 0
      init_object(player, 16, 112)
      if cursor_p == 2 then
        init_object(player, 24, 112)
      end
      cam_x = players[1].x-60
      cam_y = players[1].y-60
      music(0,0,14)
      dead = false
      title = false
      --create the player on screen
      if #players == 0 then
        init_object(player, 16, 112)
      end
    end
  else
    --update each object
    	foreach(objects, function(obj)
    		obj.move(obj.spd.x,obj.spd.y)
        obj.move(obj.kick.x,obj.kick.y)
    		obj.type.update(obj)
    	end)
      foreach(players, function(obj)
    		obj.move(obj.spd.x,obj.spd.y)
        obj.move(obj.kick.x,obj.kick.y)
    		obj.type.update(obj)
    	end)

    --monster is attacked
    
    --basic camera control
  	camera(cam_x, cam_y)
  end
end

function _draw()
  --clear the screen every frame
  cls()
  if dead then
    music(-1)
    print('you died', cam_x+10, cam_y+60)
    print('rooms cleared: '.. dungeon-1, cam_x+10, cam_y+70)
    if cursor_p == 1 then
      print('gold found: '.. gold, cam_x+10, cam_y+80)
      print('play again', cam_x+10, cam_y+90)
    else
      print('p1 gold found: '.. gold, cam_x+10, cam_y+80)
      print('p2 gold found: '.. gold_p2, cam_x+10, cam_y+90)
      print('play again', cam_x+10, cam_y+100)
    end
    
  elseif title then
    print('the wee dungeon', cam_x+10, cam_y+60)
    print('1 player start', cam_x+18, cam_y+80)
    print('2 player start', cam_x+18, cam_y+90)
    spr(43, cursor_x, cursor_y)
  else
    if not new_room then
      --draw the map in a separate function
      draw_room()
      --draw objects
      foreach(objects, function(o)
    		draw_object(o)
    	end)
      foreach(players, function(o)
    		draw_object(o)
    	end)
    end
    --draw menu
    draw_menu()
    
  end
  

  --print debug info
  for k,v in pairs(debug) do
    print(v, cam_x+10, cam_y+(10*k))
  end
  
end

function draw_room()
  --variables to find where the chunk is stored
  local chunk_x
  local chunk_y

  --variables to find the relative position of each chunk to its previous position
  local chunk_pos_x = 0
  local chunk_pos_y = 0
  local prev_chunk_pos_x = 0
  local prev_chunk_pos_y = 0

  --determine the exit point of the previous chunk
  local the_exit = 0
  
  --run through the cur_room list and place chunks
  for k,v in pairs(cur_room) do
    --get the correct chunk from storage
    if(cur_room[k] > 8)then
      chunk_x = ((cur_room[k]-1)%8)*16
      chunk_y = 16*flr((cur_room[k]-1)/8)
    else
      chunk_x = (cur_room[k]-1)*16
      chunk_y = 0
    end
    
    --properly position each chunk
    if(k>1)then
      the_exit = exits[cur_room[k-1]]
      if(the_exit != 0) then
        chunk_pos_x = prev_chunk_pos_x
        chunk_pos_y = prev_chunk_pos_y + (128*the_exit)
      else
        chunk_pos_x = prev_chunk_pos_x + 128
        chunk_pos_y = prev_chunk_pos_y
      end
    end
    --set the previous chunk positions for the next go-round
    prev_chunk_pos_x = chunk_pos_x
    prev_chunk_pos_y = chunk_pos_y
    map(chunk_x,chunk_y,chunk_pos_x,chunk_pos_y,16,16,1)
    map(chunk_x,chunk_y,chunk_pos_x,chunk_pos_y,16,16,2)
    map(chunk_x,chunk_y,chunk_pos_x,chunk_pos_y,16,16,8)
    
  end
end

function init_object(type, x, y, d, k, c)
  --local variables
  local obj = {}
  obj.type = type
  obj.spr = 0
  obj.spr_stand = 0
  obj.flip = {x=false,y=false}

  obj.x = x
  obj.y = y
  obj.spd = {x=0,y=0}
  obj.kick = {x=0,y=0}
  obj.kickdir = 1
  obj.chunk = 1
  obj.damage_taken = d
  obj.killed_by = k
  obj.critical = c

  obj.aspd = 1
  obj.atimer =0
  obj.sign = 1
  obj.atk_timer = 10
  obj.hit = false
  obj.h_timer_max = 10
  obj.h_timer = obj.h_timer_max
  obj.attacking = false
  obj.defending = false
  obj.deflected = false
  obj.damage = 0

  obj.maxrun = 2
  obj.accel = .2
  obj.deccel=.01
  obj.maxgravity = 5
  obj.jumpheight = 3.1

  obj.on_ground=true
  obj.head_bump=false
  obj.right_wall=false
  obj.left_wall=false
  obj.tile_under=0
  obj.tile_below=0
  obj.tile_ahead=0
  obj.in_ground=0
  
  obj.move=function(ox,oy)
    obj.x += ox
    obj.y += oy
  end

  --collision functions
  obj.is_on_ground=function(this)
    if not new_room then
      --object's x,y position relative to the chunk
      local this_x = flr(this.x%128)
      local this_y = flr(this.y%128)
      local doorway = 0

      if this_x+this.hitbox.w > 120 then
        doorway = -2
      end
      if this_x+this.hitbox.x < 8 then
        doorway = 2
      end
      if this_y+this.hitbox.h > 126 then return false end
      --get the chunk's x,y location in memory
      local chunk_x
      local chunk_y
      if(cur_room[this.chunk] <= 8)then
        chunk_x = (cur_room[this.chunk]-1)*128
        chunk_y = 0
      else
        chunk_x = ((cur_room[this.chunk]-1)%8)*128
        chunk_y = 128*flr((cur_room[this.chunk]-1)/8)
      end
      local object_corners = check_hitbox(this,chunk_x, chunk_y, this_x, this_y)

      local val_tr = object_corners[1]
      local val_tl = object_corners[2]
      local val_br = object_corners[3]
      local val_bl = object_corners[4]
      
      local tile0 = mget((val_bl.x/8)+doorway, (val_bl.y+1)/8)
      local tile1 = mget((val_br.x/8)+doorway, (val_br.y+1)/8)
      
      if fget(tile0) == 2 or fget(tile1) == 2 then
        return true
      else
        return false
      end
    end
  end

  obj.check_tile_under=function(this)
    if not new_room then
      --object's x,y position relative to the chunk
      local this_x = flr(this.x%128)
      local this_y = flr(this.y%128)
      --get the chunk's x,y location in memory
      local chunk_x
      local chunk_y
      if(cur_room[this.chunk] <= 8)then
        chunk_x = (cur_room[this.chunk]-1)*128
        chunk_y = 0
      else
        chunk_x = ((cur_room[this.chunk]-1)%8)*128
        chunk_y = 128*flr((cur_room[this.chunk]-1)/8)
      end
      local val = {
        x=(chunk_x+this_x+this.hitbox.x+2)/8,
        y=(chunk_y+this_y+this.hitbox.h)/8
      }
      local tile = mget(val.x,val.y)
      return tile
    end
  end
  obj.check_tile_below=function(this)
    if not new_room then
      --object's x,y position relative to the chunk
      local this_x = flr(this.x%128)
      local this_y = flr(this.y%128)
      --get the chunk's x,y location in memory
      local chunk_x
      local chunk_y
      if(cur_room[this.chunk] <= 8)then
        chunk_x = (cur_room[this.chunk]-1)*128
        chunk_y = 0
      else
        chunk_x = ((cur_room[this.chunk]-1)%8)*128
        chunk_y = 128*flr((cur_room[this.chunk]-1)/8)
      end
      local val = {
        x=(chunk_x+this_x+this.hitbox.x+2)/8,
        y=(chunk_y+this_y+this.hitbox.h+1)/8
      }
      local tile = mget(val.x,val.y)
      return tile
    end
  end

  obj.check_tile_ahead=function(this)
    if not new_room then
      --object's x,y position relative to the chunk
      local this_x = flr(this.x%128)
      local this_y = flr(this.y%128)
      --get the chunk's x,y location in memory
      local chunk_x
      local chunk_y
      if(cur_room[this.chunk] <= 8)then
        chunk_x = (cur_room[this.chunk]-1)*128
        chunk_y = 0
      else
        chunk_x = ((cur_room[this.chunk]-1)%8)*128
        chunk_y = 128*flr((cur_room[this.chunk]-1)/8)
      end
      local val = {
        x=(chunk_x+this_x+this.hitbox.x+2+(this.sign*2))/8,
        y=(chunk_y+this_y+this.hitbox.h)/8
      }
      local tile = mget(val.x,val.y)
      return tile
    end
  end

  obj.is_right_wall=function(this)
    if not new_room then
      --object's x,y position relative to the chunk
      local this_x = flr(this.x%128)
      local this_y = flr(this.y%128)

      if (this_x+this.hitbox.w < 8 or this_x+this.hitbox.x+this.spd.x > 120) or ((this_y < 8 or this_y+this.hitbox.y+this.spd.y > 120) and (this_x+this.hitbox.w > 46 and this_x < 74)) then
        return false
      else
      
        --get the chunk's x,y location in memory
        local chunk_x
        local chunk_y
        if(cur_room[this.chunk] <= 8)then
          chunk_x = (cur_room[this.chunk]-1)*128
          chunk_y = 0
        else
          chunk_x = ((cur_room[this.chunk]-1)%8)*128
          chunk_y = 128*flr((cur_room[this.chunk]-1)/8)
        end
        
        local object_corners = check_hitbox(this,chunk_x, chunk_y, this_x, this_y)

        local val_tr = object_corners[1]
        local val_tl = object_corners[2]
        local val_br = object_corners[3]
        local val_bl = object_corners[4]
        
        local tile0 = mget((val_tr.x+2)/8, (val_tr.y-1)/8)
        local tile1 = mget((val_br.x+2)/8, (val_br.y-1)/8)
        if fget(tile0) == 2 or fget(tile1) == 2 then
          return true
        else
          return false
        end
      end
    end
  end

  obj.is_left_wall=function(this)
    if not new_room then
      --object's x,y position relative to the chunk
      local this_x = flr(this.x%128)
      local this_y = flr(this.y%128)
      if (this_x+this.hitbox.x < 8 or this_x+this.hitbox.x+this.spd.x > 120) or ((this_y < 8 or this_y+this.hitbox.y+this.spd.y > 120) and (this_x+this.hitbox.x > 49 and this_x < 74)) then
        return false
      else
      
        --get the chunk's x,y location in memory
        local chunk_x
        local chunk_y
        if(cur_room[this.chunk] <= 8)then
          chunk_x = (cur_room[this.chunk]-1)*128
          chunk_y = 0
        else
          chunk_x = ((cur_room[this.chunk]-1)%8)*128
          chunk_y = 128*flr((cur_room[this.chunk]-1)/8)
        end
        
        local object_corners = check_hitbox(this,chunk_x, chunk_y, this_x, this_y)

        local val_tr = object_corners[1]
        local val_tl = object_corners[2]
        local val_br = object_corners[3]
        local val_bl = object_corners[4]
        
        local tile0 = mget((val_tl.x-3)/8, (val_tl.y-1)/8)
        local tile1 = mget((val_bl.x-3)/8, (val_bl.y-1)/8)

        if fget(tile0) == 2 or fget(tile1) == 2 then
          return true
        else
          return false
        end
      end
    end
  end

  obj.is_head_bump=function(this)
    if not new_room then
      --object's x,y position relative to the chunk
      local this_x = flr(this.x%128)
      local this_y = flr(this.y%128)
      local doorway = 0

      if this_y+this.hitbox.h > 122 then
        return false
      end
      if this_y < 6 then
        return false
      end
      --get the chunk's x,y location in memory
      local chunk_x
      local chunk_y
      if(cur_room[this.chunk] <= 8)then
        chunk_x = (cur_room[this.chunk]-1)*128
        chunk_y = 0
      else
        chunk_x = ((cur_room[this.chunk]-1)%8)*128
        chunk_y = 128*flr((cur_room[this.chunk]-1)/8)
      end
      local object_corners = check_hitbox(this,chunk_x, chunk_y, this_x, this_y)

      local val_tr = object_corners[1]
      local val_tl = object_corners[2]
      local val_br = object_corners[3]
      local val_bl = object_corners[4]
      
      local tile0 = mget((val_tl.x/8)+doorway, (val_tl.y-1)/8)
      local tile1 = mget((val_tr.x/8)+doorway, (val_tr.y-1)/8)
      
      if fget(tile0) == 2 or fget(tile1) == 2 then
        return true
      else
        return false
      end
    end
  end

  obj.is_in_ground=function(this)
    if not new_room then
      --object's x,y position relative to the chunk
      local this_x = flr(this.x%128)
      local this_y = flr(this.y%128)
      local doorway = 0

      if this_x+this.hitbox.w > 120 then
        doorway = -2
      end
      if this_x+this.hitbox.x < 8 then
        doorway = 2
      end
      --get the chunk's x,y location in memory
      local chunk_x
      local chunk_y
      if(cur_room[this.chunk] <= 8)then
        chunk_x = (cur_room[this.chunk]-1)*128
        chunk_y = 0
      else
        chunk_x = ((cur_room[this.chunk]-1)%8)*128
        chunk_y = 128*flr((cur_room[this.chunk]-1)/8)
      end
      local object_corners = check_hitbox(this,chunk_x, chunk_y, this_x, this_y)

      local val_tr = object_corners[1]
      local val_tl = object_corners[2]
      local val_br = object_corners[3]
      local val_bl = object_corners[4]
      
      local tile0 = mget(((val_bl.x+1)/8)+doorway, (val_bl.y)/8)
      local tile1 = mget(((val_br.x-1)/8)+doorway, (val_br.y)/8)

      --mset((val1.x/8)-1, val1.y/8, 65)

      if fget(tile0) == 2 or fget(tile1) == 2 then
        return true
      else
        return false
      end
    end
  end

  --store object in objects container
  if obj.type != player then
    add(objects, obj)
  else
    add(players, obj)
  end
  
  --init object
  obj.type.init(obj)

  return obj
end

function destroy_object(obj)
	del(objects,obj)
end
function destroy_player(obj)
	del(players,obj)
end

--draw the objects on the screen
function draw_object(obj)
	obj.type.draw(obj)
end

function appr(val, target, amount)
	return val > target
	 and max(val-amount, target)
	 or min(val+amount, target)
end

function build_new_room()
  foreach(objects, function(obj)
    destroy_object(obj)
  end)
  cur_room = {}
  monsters = {}
  debug = {}
  chunk_coords = 
  {
    {0,0}
  }
  --randomly determine how many chunks the new room will have (between 5-11)
  local num_chunks = flr(rnd(6))+5
  --set the previous chunk to the number of the starter chunk by default
  local int prev_chunk = 7

  --create a variable to hold the current chunk
  local cur_chunk

  --store the coordinates of the chunks in a list
  local the_exit = 0
  local chunk_coords_x = 0
  local chunk_coords_y = 0
  
  --now iterate through num_chunks and grab the correct chunk for each iteration
  for i=1,num_chunks do
    --if we're on the first iteration, use the starter chunk
    if(i==1)then
      --add the starter chunk to the current room's chunk list
      cur_room[i] = 7  
    --otherwise, randomly get a chunk that works
    else
      --randomly choose an allowed next chunk from the list based on the previously created chunk. #allowed_next_chunk is the length of the list
      random_allowed_chunk = flr(rnd(#allowed_next_chunk[prev_chunk]))
      if(random_allowed_chunk==0)then
        random_allowed_chunk=1 
      end
      cur_chunk = allowed_next_chunk[prev_chunk][random_allowed_chunk]
      
      --add the chunk to the current room's chunk list
      cur_room[i] = cur_chunk

      --save cur_chunk to check for monsters
      local e_chunk = cur_chunk
      
      --set and store the coordinates for the new chunk_coords_y
      if(i>1)then
        if(the_exit != 0) then
          chunk_coords_x += 0
          chunk_coords_y += the_exit
        else
          chunk_coords_x += 1
          chunk_coords_y += 0
        end
      end
      add(chunk_coords,{chunk_coords_x,chunk_coords_y})
      
      --are there any monsters in this chunk? if so, add them to the mosnters object
      local cur_chunk_x = (e_chunk%8)
      if e_chunk == 8 or e_chunk == 16 or e_chunk == 24 then cur_chunk_x = 8 end
      local cur_chunk_y
      if e_chunk > 8 then 
        cur_chunk_y = 1*flr((e_chunk-1)/8)
      else 
        cur_chunk_y = 0 
      end

      --run through the current chunk and find monsters to place
      for tx=0,15 do
		      for ty=0,15 do
			         local tile = mget((cur_chunk_x-1)*16+tx,cur_chunk_y*16+ty)
               --if the tile is an monster, store its location and type in the monsters list
               if tile == 192 then
                 e_x = (chunk_coords_x*16*8)+(tx*8)
                 e_y = (chunk_coords_y*16*8)+(ty*8)
                 add(monsters, {e_x, e_y})
              end
          end
      end
      --set previous chunk to cur_chunk for the next go around, and where the player exited the room
      prev_chunk = cur_chunk
      the_exit = exits[prev_chunk]
    end
  end
  --add on those last 1 or 2 chunks
  if(the_exit == 1) then
    for i=1,2 do
      if(i==1)then 
        chunk_coords_x += 0
        chunk_coords_y += 1
        add(cur_room,11) 
      else 
        chunk_coords_x += 1
        chunk_coords_y += 0
        add(cur_room,15) 
      end
      add(chunk_coords,{chunk_coords_x,chunk_coords_y})
    end
  elseif(the_exit == -1) then
    for i=1,2 do
      if(i==1)then
        chunk_coords_x += 0
        chunk_coords_y += -1
        add(cur_room,3) 
      else 
        chunk_coords_x += 1
        chunk_coords_y += 0
        add(cur_room,15) 
      end
      add(chunk_coords,{chunk_coords_x,chunk_coords_y})
    end
  elseif(the_exit == 0) then
    if prev_chunk == 18 or prev_chunk == 21 then
      for i=1,2 do
        if(i==1)then
          chunk_coords_x += 1
          chunk_coords_y += 0
          add(cur_room,19) 
        else 
          chunk_coords_x += 1
          chunk_coords_y += 0
          add(cur_room,15) 
        end
        add(chunk_coords,{chunk_coords_x,chunk_coords_y})
      end
    else
      chunk_coords_x += 1
      chunk_coords_y += 0
      add(cur_room,15)
      add(chunk_coords,{chunk_coords_x,chunk_coords_y})
    end  
  end
  --add the monsters
  --create the player on screen
  for k,v in pairs(monsters) do
    --create the player on screen
    monster_x = v[1]
    monster_y = v[2]
    init_object(monster, monster_x, monster_y)

  end
  --once the new room is created, add it to the dungeon and set new_room to false
  dungeon += 1
  new_room=false
end

function create_equipment(obj)
  obj.weapon={spr=32,spr_atk=0,x=obj.x,y=obj.y}
  obj.helmet={spr=16,x=obj.x,y=obj.y,hp=obj.inventory.helmet*3}
  obj.armor={spr=08,x=obj.x,y=obj.y,hp=obj.inventory.armor*3}
  obj.shield={spr=48,x=obj.x,y=obj.y,hp=obj.inventory.shield*3}
end

function draw_menu()
  rectfill(cam_x, cam_y+112, cam_x+128, cam_y+128, 1)
  rectfill(cam_x, cam_y+112, cam_x+128, cam_y+112, 2)
  color(6)
  if cursor_p == 1 then
    for i=1,4 do
      spr(24, cam_x+(13*(i-1)+4), cam_y+117)
      if i==1 then
        if players[1].inventory.weapon > 0 then
          local sprite = 31+players[1].inventory.weapon
          spr(sprite, cam_x+6, cam_y+117)
        end
        if players[1].attacking then pal(11,3) pal(7,6) end
        spr(25, cam_x+2, cam_y+122)
        pal()
      end
      if i==2 then
        if players[1].inventory.shield > 0 then
          local sprite = 47+players[1].inventory.shield
          spr(sprite, cam_x+16, cam_y+116)
        end
        if players[1].defending then pal(8,2) pal(7,6) end
        spr(26, cam_x+15, cam_y+122)
        pal()
      end
      if i==3 then
        if players[1].inventory.helmet > 0 then
          local sprite = 15+players[1].inventory.helmet
          spr(sprite, cam_x+29, cam_y+118)
        end
      end
      if i==4 then
        if players[1].inventory.armor > 0 then
          local sprite = 7+players[1].inventory.armor
          spr(sprite, cam_x+43, cam_y+116)
        end
      end
    end
    for i=1,players[1].hp do
      if i%2 == 0 then
        spr(28, cam_x+51+(i*4)-4, cam_y+117)
      else
        spr(27, cam_x+51+(i*4), cam_y+117)
      end
    end
    spr(29, cam_x+100, cam_y+117)
    print('='.. players[1].inventory.gold, cam_x+110, cam_y+119)
  else
    if players[1] != nil then
      for i=1,players[1].hp do
        if i%2 == 0 then
          spr(57, cam_x+(i*4)-4, cam_y+113)
        else
          spr(56, cam_x+(i*4), cam_y+113)
        end
      end
      spr(58, cam_x+4, cam_y+120)
      print('='.. players[1].inventory.gold, cam_x+12, cam_y+122)
    end
    if players[2] != nil then
      for i=1,players[2].hp do
        if i%2 == 0 then
          spr(57, cam_x+83+(i*4)-4, cam_y+113)
        else
          spr(56, cam_x+83+(i*4), cam_y+113)
        end
      end
      spr(58, cam_x+87, cam_y+120)
      print('='.. players[2].inventory.gold, cam_x+95, cam_y+122)
    end
  end
end

function set_equipment(this)
  if this.shield.hp == 0 then this.inventory.shield = 0 end
  if this.helmet.hp == 0 then this.inventory.helmet = 0 end
  if this.armor.hp == 0 then this.inventory.armor = 0 end
end

function init_inventory(this, w,s,a,h,g)
  this.inventory = {
      weapon = w,
      shield = s,
      armor = s,
      helmet = h,
    gold = g
  }
end

function place_equipment(this)
  if this.inventory.weapon > 0 then
    if this.attacking then
      this.weapon.x = this.x+(this.sign*8)
    else
      this.weapon.x = this.x-this.sign
    end
    this.weapon.y = this.y
  end
  if this.inventory.helmet > 0 then
    this.helmet.x = this.x+this.sign
    this.helmet.y = this.y-1
  end
  if this.inventory.shield > 0 then
    this.shield.x = this.x+(this.sign*3)
    this.shield.y = this.y
  end
  if this.inventory.armor > 0 then
    this.armor.x = this.x
    this.armor.y = this.y
  end
end

function get_chunk(this)
  local this_chunk_coords = {flr(this.x/128), flr(this.y/128)}
  this.chunk = nil
  for k,v in pairs(chunk_coords) do
    if this_chunk_coords[1] == chunk_coords[k][1] and this_chunk_coords[2] == chunk_coords[k][2] then
      this.chunk = k
      break
    end
  end
  if this.chunk == nil then
    destroy_object(this)
  end
end

function get_collisions(this)
  --gravity
  if not this.on_ground then
    this.spd.y=appr(this.spd.y,1*this.maxgravity,this.accel)
  else
    this.spd.y = 0
  end
  if this.right_wall and (this.spd.x > 0 or this.kick.x > 0) then
    if not this.head_bump then
      local val0 = {x=this.x+this.hitbox.w+this.spd.x+1, y=this.y+this.hitbox.y}
        this.spd.x = 0
        this.kick.x = 0
      if this.type != player then this.flip.x = true end
    end
  end
  if this.left_wall and (this.spd.x < 0 or abs(this.kick.x) > 0) then
    if not this.head_bump then
      local val0 = {x=(this.x+this.hitbox.x)+this.spd.x-1, y=this.y+this.hitbox.y}
      this.spd.x = 0
      this.kick.x = 0
      if this.type != player then this.flip.x = false end
    end
  end
  if not this.on_ground then
    if this.head_bump then
      this.y +=1
      this.spd.y = 0
    end
  end
  if this.in_ground then
    this.y -= 1
  end
  if this.left_wall and not this.right_wall then
    this.x += 1
  elseif this.right_wall and not this.left_wall then
    this.x -= 1
  end
end

function animate(this)
  if this.on_ground then
    if this.spd.x != 0 then
      if this.atimer == this.aspd then
        if this.spr < this.spr_stand+1 then
          this.spr+=1
        else
          this.spr=this.spr_stand-1 
        end
        this.atimer = 0
      else
        this.atimer += 1
      end
    else
      this.spr = this.spr_stand
    end
  else
      this.spr = this.spr_stand+1
  end
  if this.attacking then
    this.spr = this.spr_stand+2
  end
end

function get_sign(this)
  if this.spd.x < 0 then
    this.sign = -1
  elseif this.spd.x > 0 then
    this.sign = 1
  end
end

function check_attack(attacker, defender)
  if (
    attacker.attacking and
    (attacker.weapon.x+8 > defender.x+defender.hitbox.x) and
    (attacker.weapon.x < defender.x+defender.hitbox.w) and
    (attacker.weapon.y+2 > defender.y+defender.hitbox.y) and
    (attacker.weapon.y < defender.y+defender.hitbox.h-1)
  ) then
    --give monster a change to defend himself
    if attacker == players[1] or attacker == players[2] then
      local block = rnd(1)
      if block > .5 then
        defender.defending = true
      else
        defender.defending = false
      end
    end
    if defender.defending and defender.shield.hp > 0 then
      attacker.deflected = true
    else
      defender.hit = true
      defender.lasthit = attacker.player
      defender.damage = attacker.inventory.weapon
      defender.kickdir = attacker.sign
      defender.atk_timer = 10
    end
  end
end

function check_touch(attacker, defender)
  --if monster touches player
  if touching_player(attacker, defender) then
    if defender.defending and defender.shield.hp > 0 then
      attacker.deflected = true
    else
      defender.damage = 1
      defender.hit = true
      defender.lasthit = attacker.player
      if attacker.x > defender.x then
        attacker.kick.x = 2
        defender.kickdir = -1
      else
        attacker.kick.x = -2
        defender.kickdir = 1
      end
    end
  end
end

function take_damage(this)
  if this.hit then
    if rnd(1) > .9 then
      this.critical = 1
    else
      this.critical = 0
    end
    if this.h_timer == this.h_timer_max then
      if this.inventory.helmet > 0 and this.helmet.hp > 0 then
        this.helmet.hp -= this.damage
        init_object(hitpoints, this.x, this.y, (this.damage+this.critical)*-1, nil, this.critical)
      end
      if (this.inventory.helmet <= 0 or this.helmet.hp <= 0)
      and (this.inventory.armor > 0 and this.armor.hp > 0) then
        this.armor.hp -= this.damage
        init_object(hitpoints, this.x, this.y, (this.damage+this.critical)*-1, nil, this.critical)
      end
      if (this.inventory.helmet <= 0 or this.helmet.hp <= 0)
      and (this.inventory.armor <= 0 or this.armor.hp <= 0) then
        this.hp -= this.damage
        init_object(hitpoints, this.x, this.y, (this.damage+this.critical)*-1, nil, this.critical)
      end
      sfx(21)
      this.h_timer -= 1
      this.spd.x = 0
      this.kick.x = this.kickdir*2
    elseif this.h_timer == 0 then
      this.hit = false
      this.h_timer = this.h_timer_max
    else
      this.h_timer -= 1
    end
  end
end

function tile_info(this)
  this.on_ground=this.is_on_ground(this)
  this.head_bump=this.is_head_bump(this)
  this.right_wall=this.is_right_wall(this)
  this.left_wall=this.is_left_wall(this)
  this.tile_under=this.check_tile_under(this)
  this.tile_below=this.check_tile_below(this)
  this.tile_ahead=this.check_tile_ahead(this)
  this.in_ground=this.is_in_ground(this)
end

function kick(this)
  if abs( this.kick.x > 0 ) then
    this.kick.x = this.kick.x*.9
  else
    this.kick.x = 0
  end
end

function check_hitbox(this,chunk_x,chunk_y,this_x,this_y)
  local val_tr = 
  {
    x=chunk_x+this_x+this.hitbox.w,
    y=chunk_y+this_y+this.hitbox.y
  }
  local val_tl = 
  {
    x=chunk_x+this_x+this.hitbox.x,
    y=chunk_y+this_y+this.hitbox.y
  }
  local val_br = 
  {
    x=chunk_x+this_x+this.hitbox.w,
    y=chunk_y+this_y+this.hitbox.h
  }
  local val_bl = 
  {
    x=chunk_x+this_x+this.hitbox.x,
    y=chunk_y+this_y+this.hitbox.h
  }
  local hitbox = {
    val_tr,
    val_tl,
    val_br,
    val_bl
  }
  return hitbox
  
end

function touching_player(this, player)
  if (
    this.x+8 >= player.x and
    this.x <= player.x+8 and
    this.y+8 >= player.y and
    this.y <= player.y+8
  ) then
    return true
  else
    return false
  end
end