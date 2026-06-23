-- alpine alpaca
-- created by @johanpeitz
-- audio by @gruber_music

-- special thanks
-- intro graphic by @2darray
-- art tips from @ilkkke

debug=false
extcmd("rec")
--goto donewithintro


-- intro
daynumber="14"
::_::
if (btnp()>0) goto donewithintro
cls(7)
f=4-abs(t()-4)
for z=-3,3 do
 for x=-1,1 do
  for y=-1,1 do
   b=mid(f-rnd(.5),0,1)
   b=3*b*b-2*b*b*b
   a=atan2(x,y)-.25
   c=8+(a*8)%8
   if (x==0 and y==0) c=7
   u=64.5+(x*13)+z
   v=64.5+(y*13)+z
   w=8.5*b-abs(x)*5
   h=8.5*b-abs(y)*5
   if (w>.5) rectfill(u-w,v-h,u+w,v+h,c) rect(u-w,v-h,u+w,v+h,c-1)
  end
 end
end
 
if rnd()<f-.5 then
 ?daynumber,69-#daynumber*2,65,2
end
 
if f>=1 then
 for j=0,1 do
  for i=1,f*50-50 do
   x=cos(i/50)
   y=sin(i/25)-abs(x)*(.5+sin(t()))
   circfill(65+x*8,48+y*3-j,1,2+j*6)
  end
 end
 
 for i=1,20 do
  ?sub("pico-8 advent calendar",i),17+i*4,90,mid(1-(-1-i/20+f),0,1)*7
 end
end
 
if (t()==8) goto donewithintro
 
flip()
goto _
::donewithintro::

function _init() 

 best=1
 cartdata("jpaalpaca")

 -- reset best
 best=dget(0)
 if (best==0) then
  reset_best()
 end

 swap_state(title_state)
end


function reset_best()
 set_best(10)
end

function set_best(b)
 best=b
 dset(0,b) 
end

-->8
--------------------------------
-- main game
--------------------------------

upgrade={
 { id=1,amt=2,df=0,icon=78,name="traversing",desc="add more turns to your deck", },
 { id=2,amt=2,df=0,icon=94,name="schussing",desc="add more downhill cards to your deck", },
-- -{ id=3,amt=3, name="perseverance",desc="reduces difficulty when played", },
-- -{ id=4,amt=1, name="bottom line",desc="awards instant points when played", },
 { id=5,amt=2,df=0,icon=110,name="ripping",desc="add strafe cards for sideways movement", },
 { id=6,amt=1,df=0,icon=76,name="snowplough",desc="reduces any gained speed", },
 { id=7,amt=1,df=0.5,icon=92,name="bombing",desc="speed up and get extra points, but game gets harder", },
 { id=8,amt=1,df=0,icon=126,name="mini schuss",desc="add short downhill cards to your deck", },
 { id=9,amt=1,df=1,icon=74,name="kicker",desc="jump obstacles when played, but game gets harder", },
 { id=10,amt=1,df=1,icon=108,name="snow bomb",desc="destroy obstacles when played, but game gets harder", }, 
-- -{ id=11,amt=1, name="shuffle",desc="reshuffles deck and hand when played", },
}

function init_play()
 first=false
 letters={
  {0,16,12}, --w
  {36,0,6}, --i
  {24,0,12}, --p
  {54,0,12}, --e
  {12,16,12}, --d
  
  {24,16,12}, --o
  {36,16,12}, --u
  {48,16,12}, --t
 }
 
 
 t=0
 hand={}
 deck={}
 pile={}
 trail={}
 particles={}
 ptext={}
 obs_lookup={}
 punch={
  active=false
 }

 fx={}
 fx[0]=0
 fx[2]=132 -- :(
 fx[4]=132
 fx[6]=128 --!
 fx[8]=128
 fx[10]=134
 fx[12]=130 -- :)
 fx[14]=134
 fx[32]=132
 fx[34]=132
 
 difficulty=2
 x_diff=0
 cpup=0
 cpicks={}
 pup_ui_y=128
 pup_ui_delay=0
 end_ui_y=130
 end_ui_delay=20
 end_t=0
 ui_gates=0
 max_deck=99
 wipe=16
 has_bombing=false
 broke_high=false
 broke_high_sfx=false
 bounce_count=0
 
 pl={
  x=3,
  y=1,
  jy=0,
  jyd=1,
  spr=66,
  moves={},
  cmove=nil,
  score=0,
  speed=0,
  gates=0,
  level_up=false,
  lx=0,
  ly=0,
  actions=0,
  jumps=0
 }
 
 tcamx=8
 tcamy=8
 set_cam_target(tcamx,tcamy)
 camx=tcamx
 camy=tcamy
 cam_delay=0
 -- mode
 -- -1 tutorial
 -- 0 draw
 -- 1 choose card
 -- 2 use card
 -- 3 impact
 -- 4 level up
 mode=-1
 last_mode=-2
 step_count=0
 
 -- obstacles & gates
 obstacles={}
 for y=1,64 do
  add_gate(y*7-3) 
 end
 -- todo: ugly hack
 next_gate=obstacles[2]
 
 for y=1,16 do
  add_obstacle(difficulty+x_diff,y)
 end
 
 -- inital deck
 for i=1,3 do 
  add_card(2,184,i) -- down
  add_card(1,183,i) -- left
  add_card(3,185,i) -- right
 end

 reshuffle(deck)

 -- initial hand
 add_card(1,183,2) -- left
 add_card(3,185,2) -- right
 add_card(2,184,2) -- down
 --add_card(4,188,3) -- slow
 --add_card(5,189,5) -- fast
 --add_card(9,174,0) -- jump
 --add_card(10,158,0) -- eraser
 for i=1,3 do
  draw_new_card(10+i*10)
 end
 
end

function reshuffle(array)
 for i=1,16 do
  local id=flr(rnd()*#array)
  local c=array[id]
  del(array,c)
  add(array,c)
 end
end

-- card sizes
cw=28
ch=10
function add_card(p_id,p_spr,p_spd)
  local c={
   x=98,
   ex=0,
   y=120,
   id=p_id,
   spr=p_spr,
   speed=p_spd,
   dx=0,
   dy=1,
   ds=0,
   pspr=66,
   hidden=true,
   delay=0,
   sm=1 -- speed multiplier
  }
 
  if (p_id==1) then
   c.dx=-1
   c.pspr=64
  end
  if (p_id==3) then
   c.dx=1
   c.pspr=68
  end
  if (p_id==4) then
   c.pspr=70
   c.str="slow down!"
  end
  if (p_id==5) then
   --c.pspr=70
   c.str="speed up!"
  end

  if (p_id==6) then
   c.dx=-1
   c.dy=0
   c.sm=0
  end
  if (p_id==7) then
   c.dx=1
   c.dy=0
   c.sm=0
  end  
  
  if (p_id==10) then
   c.dx=0
   c.dy=0
   c.sm=0
   c.speed=0
   c.on_complete=remove_obstacles
  end
  
  if (p_id==9) then
   c.dx=0
   c.dy=0
   c.sm=0
   c.speed=0
   c.on_complete=add_jump
   c.str="jump ready!"
  end
 
  add(deck,c)
end

function add_jump()
 pl.jumps+=1
 
 mode=0
end

function remove_obstacles()
 jumps=0
 for o in all(obstacles) do
  local dx=o.x-pl.x
  local dy=o.y-pl.y
  if (abs(dx)<=1 and dy>=-1 and dy<=1) then
   o.sink=16
  end
 end
 
 -- play bomb sfx
 sfx(53)
 
 -- fx
 for i=0,31 do 
  add(particles,{
   x=pl.x*16+8,
   y=pl.y*16+8,
   dx=(rnd(2)+3)*cos(i/32),
   dy=(rnd(2)+3)*sin(i/32),
   life=30-rnd(20),
   uf=function(p)
    p.x+=p.dx 
    p.y+=p.dy 
    p.dx*=0.9
    p.dy*=0.9
    p.life-=1
   end,
   df=function(p)
    circfill(p.x,p.y,10*(p.life/30),12)
    circfill(p.x-1,p.y-1,8*(p.life/30),7)
   end,
  })
 end


 mode=0

end

function draw_new_card(delay)
 if (#deck==0) then
  deck=pile
  pile={}
  reshuffle(deck)
  max_deck=0
  delay=#deck*3
 end

 local c=deck[#deck]
 c.delay=delay
 c.ex=0
 c.x=98
 c.y=120
 c.hidden=true
 add(hand,c)
 del(deck,c)
end


function update_play()
 t+=1
 if (t>10000) t-=9000
 
 if (wipe>0) then
  wipe-=1
 end
   
 if (mode==-1) then --tutorial
  if (t>305 or 
      bp()) then
   mode=0
   add_punch("let's go!")
  end
 elseif (mode==0) then -- draw
  last_mode=0
  draw_new_card(t>10 and 0 or 50)
  ccard=hand[1]
  mode=1
 elseif (mode==0.5) then
  if (btn(ƒ) or btn(”) or bp()) then   
   ccard=hand[1]
   mode=1
   sfx(63)
  end
 elseif (mode==1) then -- choose
  local last_card=ccard
  if (btnp(”)) ccard=get_prev_card()
  if (btnp(ƒ)) ccard=get_next_card()
  
  if (last_card!=ccard) sfx(63)
  
  if (ccard!=nil) then
   pl.spr=ccard.pspr
   if (last_card!=ccard or last_mode==0) then
    set_cam_target(pl.x*16-3*16+8+(ccard.speed*16*ccard.dx))
   end
   
   local ok_to_use=true
   if (ccard.id==4 and pl.speed==0) ok_to_use=false
   
   if (bp() and ok_to_use) then
    if (ccard.id>=9) then
     sfx(61)
    else
     sfx(62)
    end
    
    mode=2
    bounce_count=0
    pl.actions+=1
    
    if (ccard.str!=nil) then
     add_punch(ccard.str)
    end
    
    -- create delta list
    local spd=ccard.speed+ccard.sm*pl.speed
    for i=1,spd do
     add(pl.moves,{
      x=ccard.dx,
      y=ccard.dy,
      spd=2
     })
    end
    step_count=0
    if (spd==0) then
     step_count=16
     add(pl.moves,{
      x=0,
      y=0,
      spd=0
     })
    end
    
    pl.cmove=pl.moves[#pl.moves]
    del(hand,ccard)
    add(pile,ccard)
   end 
  end
  last_mode=1
 elseif (mode==2) then -- use
  local boom=false
  if (pl.jy==0) then
   add(trail,{
    x=7+pl.x*16+pl.cmove.x*step_count,
    y=8+pl.y*16+pl.cmove.y*step_count
   })
   add(trail,{
    x=7+pl.x*16+pl.cmove.x*(step_count+1),
    y=8+pl.y*16+pl.cmove.y*(step_count+1)
   })
  
   local pcs={12,6,7}
   for i=1,16 do
    add(particles,{
     x=rnd(4)-2+7+pl.x*16+pl.cmove.x*(step_count+1),
     y=rnd(4)-2+8+pl.y*16+pl.cmove.y*(step_count+1),
     dx=0.5*(-pl.cmove.x*2+rnd(2)-1),
     dy=-2-rnd(),
     c=pcs[flr(1+rnd(#pcs))],
     life=10+rnd(10),
     uf=u_snow,
     df=d_snow
    })
   end
  end 
  
  if (pl.jy>0) then  
   pl.jy+=pl.jyd
   if (pl.jy>16) pl.jyd=-2
   if (pl.jy<0) then
    pl.jy=0
   end
  end
  
  -- check next obstacle
  if (pl.jy==0 and step_count==0) then
   for i=1,#obstacles do
    o=obstacles[i]
    if (o.y>pl.y+10) i=9999
     
    if (o.x==pl.x+pl.cmove.x and
        o.y==pl.y+pl.cmove.y) then
     if (fx[o.spr]==132) then
      if (pl.jumps>0) then
       pl.jumps-=1
       pl.jyd=4
       pl.jy=1
       -- play land jump sfx
       sfx(52)
       
       -- duplicate last move
       add(pl.moves,{
        x=pl.cmove.x,
        y=pl.cmove.y,
        spd=pl.cmove.spd
       })
      end
     end     
    end
   end
  end
  
  -- done skiing?  
  step_count+=pl.cmove.spd
  if (step_count==16) then
   step_count=0

   pl.x+=pl.cmove.x
   pl.y+=pl.cmove.y
   pl.lx=pl.cmove.x
   pl.ly=pl.cmove.y
   del(pl.moves,pl.cmove)
   set_cam_target(pl.x*16-3*16+8,
      pl.y*16-24,1)

   -- check for impacts
   next_gate=nil  
   for i=1,#obstacles do
    o=obstacles[i]
    if (o.y>pl.y+10) i=9999

    if (o.x==pl.x and o.y==pl.y and o.hit==false) then
     if (pl.jy==0) o.ht=10
     if (pl.jy==0) o.hit=true
     if (o.spr==6) then
      add(pl.moves,{x=1,y=0,spd=4})
      bounce_count+=1
      add_score(bounce_count)
      sfx(60)
     elseif (o.spr==8) then
      add(pl.moves,{x=-1,y=0,spd=4})
      bounce_count+=1
      add_score(bounce_count)
      sfx(60)
     elseif (o.spr==10) then
      add(pl.moves,{x=1,y=0,spd=4})
      sfx(60)
     elseif (o.spr==14) then
      add(pl.moves,{x=-1,y=0,spd=4})
      sfx(60)
     elseif (o.spr==12) then
      clear_gate(o)
      if (ui_gates==3) then
       pl.level_up=true
      end
     elseif (fx[o.spr]==132) then
      if (pl.jy==0) then
       pl.moves={}
       boom=true
      end
     end
    end
    
    -- set next gate
    if (next_gate==nil and o.y>pl.y and o.spr==12) then
     next_gate=o
    end 
   end
 
   -- get next move
   pl.cmove=pl.moves[#pl.moves]

   -- add obstacles
   add_obstacle(difficulty+x_diff,16)
   
  
  end
  if (#pl.moves==0) then
   if (boom) then
    pl.spr=72
    music(27)
    sfx(58)
    if (pl.score>best) then
     set_best(pl.score)
    end
    end_t=0
    mode=3
   elseif (pl.level_up) then
    mode=4
    pl.level_up=false
    cpup=0
    pup_ui_delay=20
    pup_ui_y=128
  
    cpicks={}
    for i=1,#upgrade do
     -- dont add id=6 unless 
     -- pl has_bombing
     if (upgrade[i].id==6) then
      if (has_bombing) add(cpicks,i)
     else
      add(cpicks,i)
     end
    end
    while(#cpicks>3) do
     del(cpicks,cpicks[flr(rnd(#cpicks+1))])
    end

    
   elseif (ccard.on_complete) then
    mode=5
    ccard.on_complete()
   else
    mode=0
    pl.jumps=0
    pl.jy=0
    
    if (ccard.id==4) pl.speed-=1
    if (ccard.id==5) pl.speed+=1
    pl.speed=max(0,pl.speed)
   
    pl.cmove=nil
    ccard=nil
    set_cam_target(pl.x*16-3*16+8,
      pl.y*16-24,1)
   end
  end
 elseif (mode==3) then
  pl.lx+=sign(pl.lx)
  pl.ly+=sign(pl.ly)
  pl.lx*=0.95
  pl.ly*=0.95

  if (abs(pl.lx)>0.1 or abs(pl.ly)>0.1) then
   add(trail,{
    x=7+pl.x*16+pl.lx,
    y=8+pl.y*16+pl.ly,
    boom=true
   })
  end  
  
  if (bp()) then
   --swap_state(title_state)
   swap_state(wipe_state)
   sfx(61)
  end
 elseif (mode==4) then
  local ocpup=cpup
  if (btnp(‹)) cpup-=1
  if (btnp(‘)) cpup+=1
  if (cpup<0) cpup+=3
  if (cpup>2) cpup-=3
  if (cpup!=ocpup) then
   pup_ui_y-=5
   sfx(63)
  end
  if (bp()) then
   sfx(61)
   -- add cards
   local u=upgrade[cpicks[cpup+1]]
   apply_upgrade(u)
  
   -- move on
   mode=0
   pl.jumps=0
   pl.jy=0
   ui_gates=0
  end
 end
 
 -- update text particles
 for p in all(ptext) do
  p.x+=p.dx
  p.y+=p.dy
  p.dx*=0.95
  p.dy*=0.9
  p.life-=1
  if (p.life<0) del(ptext,p)
 end

 --if (mode==2 or mode==3) do
  for p in all(particles) do
   p.uf(p)
   if (p.life<0) del(particles,p)
  end
 --end
 
 -- update obstacles
 for o in all(obstacles) do
  if (o.ht>0) o.ht-=2
  if (o.y<pl.y-5) then
   del_o(o)
   del(obstacles,o)
  end
 end
 
 -- cull trail
 for p in all(trail) do
  if (p.y<(pl.y-6)*16) del(trail,p)
 end
 
 -- update camera
 if (cam_delay>0) then
  cam_delay-=1
  if (cam_delay==0) then
   tcamx=next_tcamx
   tcamy=next_tcamy
  end
 end

 camx+=(tcamx-camx)*0.08
 camy+=(tcamy-camy)*0.08
 
 -- update punch
 if (punch.active) then
  punch.t-=1
  if (punch.t==0) punch.active=false
 end
 
 -- base difficulty
 difficulty=2+flr(pl.y/10)
end

function u_snow(p)
 p.x+=p.dx
 p.y+=p.dy
 p.dx*=0.95
 p.dy+=0.2
 p.life-=1
end

function d_snow(p)
 pset(p.x,p.y,p.c)
end



function apply_upgrade(u)
 if (u.id==1) then
  -- turns
  add_card(1,183,2)  -- left
  add_card(3,185,2) -- right
 elseif (u.id==2) then
  -- straights
  add_card(2,184,2) -- down
  add_card(2,184,3) -- down
 elseif (u.id==3) then
  -- less difficulty
 elseif (u.id==4) then
  -- points
 elseif (u.id==5) then
  -- strafe
  add_card(6,186,1)
  add_card(7,187,1)
 elseif (u.id==6) then
  -- slow down
  add_card(4,188,2)
 elseif (u.id==7) then
  -- speed up
  add_card(5,189,4)
  has_bombing=true
 elseif (u.id==8) then
  -- short straight
  add_card(2,184,1) -- down
 elseif (u.id==9) then
  -- jump
  add_card(9,174,0)
 elseif (u.id==10) then
  -- white out
  add_card(10,158,0)
 elseif (u.id==11) then
  -- shuffle
 end

 x_diff+=u.df
 
 reshuffle(deck)
end

function add_score(amt)
 pl.score+=amt
 
 add(ptext,{
  str="+"..amt,
  x=pl.x*16+4,
  y=pl.y*16-8,
  dx=0,
  dy=-1,
  life=20
 })
end

function clear_gate(g)
 add_score(pl.speed+3)
 
 if (pl.score>best) then
  broke_high=true
 end
-- add_punch("gate passed!")
 pl.gates+=1
 ui_gates+=1
 sfx(59)

 for i=1,#obstacles do
  o=obstacles[i]
  if (o.y>pl.y+12) i=999
   
  if (o.spr==10 or o.spr==14) then
   if (o.y==g.y) then
    o.spr+=32
    o.ht=10
   end
  end
 end
end

function set_cam_target(x,y,delay)
 if (x) next_tcamx=x
 if (y) next_tcamy=y
 if (delay) then
  cam_delay=delay
 else 
  cam_delay=10
 end
end

function add_gate(dist)
  local gx=pl.x+flr(rnd(6))-3
  add(obstacles,{
   x=gx-1,
   y=pl.y+dist,
   spr=10,
   ht=0,
   hit=false
  })
  set_o(obstacles[#obstacles])

  add(obstacles,{
   x=gx,
   y=pl.y+dist,
   spr=12,
   ht=0,
   hit=false
  })
  set_o(obstacles[#obstacles])

  add(obstacles,{
   x=gx+1,
   y=pl.y+dist,
   spr=14,
   ht=0,
   hit=false
  })
  set_o(obstacles[#obstacles])

end

function add_obstacle(amnt,dist)
 local os={2,4,32,34, 6,8}
 for j=1,amnt do
  local ospr=os[flr(rnd(#os)+1)]
  local rx=pl.x+flr(rnd(32))-16
  local ry=pl.y+dist
  -- just skip occupied slots
  if (get_o(rx,ry)==nil) then
   add(obstacles,{
    x=rx,
    y=ry,
    spr=ospr,
    ht=0,
    hit=false
   })
   set_o(obstacles[#obstacles])
  end
 end
end

function set_o(o)
 obs_lookup[o.x.."x"..o.y]=o.spr
end

function del_o(o)
 obs_lookup[o.x.."x"..o.y]=nil
end

function get_o(x,y)
 return obs_lookup[x.."x"..y]
end

function get_next_card()
 local hit=false
 for c in all(hand) do
  if (hit) return c
  if (ccard==c) hit=true
 end
 
 return ccard 
end

function get_prev_card()
 local prev=ccard
 for c in all(hand) do
  if (ccard==c) return prev
  prev=c
 end
 
 return ccard 
end

function add_punch(str)
 punch.str=str
 punch.active=true
 punch.t=50
 punch.ty=50
 punch.y=128
end

function draw_punch()
 local y=punch.y
 
 if (punch.t<10) punch.ty=-20
 
 punch.y+=(punch.ty-punch.y)*0.2
 
 for yy=0,10 do
  line(15-yy/2,y+yy+2,80-yy/2,y+yy+2,12)
  line(15-yy/2,y+yy,80-yy/2,y+yy,14)
 end
 print(punch.str,
       48-2*#punch.str,y+3,1)
end

function draw_play()
 cls(7)
 
 -- grid
 local ox=flr(camx)%16
 local oy=flr(camy)%16
 for x=0,8 do
  for y=0,8 do
   spr(0,-ox+x*16,-oy+y*16,2,2)
  end
 end
 
 -- world 
 camera(camx,camy)

 -- trail
 for p in all(trail) do
  if (p.boom) then
   circfill(p.x,p.y,3,12)
  else
   rectfill(p.x-3,p.y,p.x-2,p.y+1,12)
   rectfill(p.x+2,p.y,p.x+3,p.y+1,12)
  end
 end
 
 -- card effects
 for c in all(hand) do
  local ok_to_use= c==ccard
   
  if (c.id==4 and pl.speed==0) ok_to_use=false

  if (ok_to_use) draw_path(c)
 end 
 
 -- obstacles
 for o in all (obstacles) do
  local sx=8*(o.spr%16)
  local sy=8*flr(o.spr/16)
  local h=16+o.ht
  
  if (o.sink) then
   o.sink-=1
   
   if (o.sink<=0) del(obstacles,o)
   
   h*=(o.sink/16)
   sspr(sx,sy,16,16,
        o.x*16,o.y*16-4-o.ht+(16-h),16,h)
  else
   sspr(sx,sy,16,16,
        o.x*16,o.y*16-4-o.ht,16,h)
  end
 end
 
 -- particles
 for p in all(particles) do
  p.df(p)
 end
 
 -- player
 local mx=0
 local my=0
 if (pl.cmove!=nil) then
  mx=pl.cmove.x*step_count
  my=pl.cmove.y*step_count
 end
 local pjy=0
 if (pl.jumps>0 and mode==1) then
  pjy=abs(3.5*sin(t/30))
 end
 
 spr(pl.spr,
     pl.x*16+mx+pl.lx,
     pl.y*16-4+my+pl.ly-pl.jy+pjy,
     2,2,boom and pl.lx>0 or false)
  
 for c in all(hand) do
  if (c==ccard) draw_path_obstacles(c)
 end 
 
 -- particles
 for p in all(ptext) do
  printo(p.str,p.x,p.y,7,1)
 end

 -- ui
 camera()
 
 -- next gate
 if (next_gate!=nil and mode!=3) then
  local ngx=max(0,min(95,7+16*next_gate.x-camx))
  local ngy=min(127,8+16*next_gate.y-camy)
  if (ngx==95 or ngx==0 or ngy==127) then
   circ(ngx,ngy,12-flr(t/2)%12,8)
  end
 end
 
 if (punch.active) draw_punch()

 -- game over
 if (mode==3) then
  
  if (end_ui_delay<=0) then
   end_t+=1
   end_ui_y+=(60-end_ui_y)*0.4
  else
   end_ui_delay-=1
  end
  local ey=end_ui_y
  
  for i=0,35 do
   line(15+i/4-5,end_ui_y+i,82+i/4-5,end_ui_y+i,13)
   line(15+i/4-5,end_ui_y+i-2,82+i/4-5,end_ui_y+i-2,14)
  end

  draw_letters_2(1,5,min(15,-100+end_t*8),60+0)
  draw_letters_2(6,8,max(45,196-end_t*8),60+16)
  
  local ty=max(0,100-end_t*4)
  local sc1=7
  if (broke_high) then
   sc1=flr(t/4)%4<2 and 12 or 14
   if (ty==0 and not broke_high_sfx) then
    broke_high_sfx=true
    sfx(56)
   end
  end
  
  local dstr=""..3*(pl.y-1)
  printo("   score "..pl.score,25,ty+100,sc1,1)
  printo("distance "..dstr,25,ty+108,7,1)
  spr(177,62+4*#dstr,ty+106)
  printo("   moves "..pl.actions,25,ty+116,7,1)

  if (end_t%32>17) printo("—",2,121,13,7)  
 end
 
 camera(min((t-16)*3-40,0),0)
 -- card tray
 rectfill(96,0,127,127,14)
 line(95,0,95,127,12)
 local dir=1
 local x=121
 for y=0,127 do
  line(x,y,127,y,2)
  x+=dir
  if (x>124 or x<119) dir=-dir
 end
 
 -- score
 print("score",98,2,2)
 local d1=flr(pl.score/100)
 local d2=flr((pl.score-d1*100)/10)
 local d3=pl.score-d2*10-d1*100
 pal(12,1)
 spr(115+d1,99,9)
 spr(115+d2,99+8,9)
 spr(115+d3,99+16,9)
 pal(12,broke_high and (t%16<8 and 7 or 10) or 15)
 spr(115+d1,98,8)
 spr(115+d2,98+8,8)
 spr(115+d3,98+16,8)
 pal()
 
 -- gates
 print("gates",98,22,2)
 local y=28
 for x=1,3 do
  local id=160
  if (ui_gates>=x) then
   id+=1
   if (ui_gates==3 and flr((t-x*4)/8)%3==1) id+=1
  end
  spr(id,91+6*x,y)
 end
 
 -- deck
 if (max_deck<#deck) then
  if (t%3==0) max_deck+=1
 end
 for i=1,min(max_deck,#deck) do
  spr(96,
      100+0.5*sin(i/2.5)+0.5*cos(i/3.5),
      112-i*1,3,2)
 end
 printo(""..min(max_deck,#deck),117,120,7,2)
 
 -- misc
 if (debug==true) then
  print("diff: "..difficulty+x_diff,97,110,7)
 end
 
 -- keys
 local tt=t
 if (mode!=4 and mode!=3) then
  if (pl.y>10 or mode!=1) tt=30
  print("”",99,95,tt%60>50 and 7 or 12)
  print("ƒ",107,95,(tt-5)%60>50 and 7 or 12)
  print("—",118,95,(tt-10)%60>50 and 7 or 12)
 end
 
 -- hand
 print("cards",98,41,2)
 y=47
 for c in all(hand) do
  if (c.delay<=0) then
   c.x+=(98-c.x)*0.2
   c.y+=(y-c.y)*0.2

   if (abs(c.y-y)<2) c.hidden=false
   draw_card(c,c.x,c.y)
   y+=12
  else
   c.delay-=1
  end
 end
 

 
 -- upgrades
 if (mode==4) then
  if (pup_ui_delay<=0) then
   pup_ui_y+=(80-pup_ui_y)*0.3
  else
   pup_ui_delay-=1
   if (pup_ui_delay==1) then
    sfx(57)
   end
  end
  local py=pup_ui_y
  local u
  
  -- panel bg
  
  rectfill(2,py+10,93,127,1)
  rectfill(3,py+ch+1,92,127,12)
  rectfill(2+cpup*30,py-2,5+cw+cpup*30,py+ch-1,1)
  rectfill(3+cpup*30,py-1,4+cw+cpup*30,py+ch,12)
  
  -- cards    
  for i=0,2 do
   u=upgrade[cpicks[i+1]]
   pal(8,7)
   clip(0,0,127,py+ch)
   local yy=py+2
   if (i!=cpup) then
    pal(8,6)
    yy+=2
    rectfill(3+i*30,yy-1,4+i*30+cw,127,1)
    rectfill(4+i*30,yy,3+i*30+cw,127,13)
    yy+=2
   end
   local xx=10+i*30
   if (u.icon==126) yy+=flr(t/8)%3
   if (u.icon==110) xx+=flr(t/8)%2
   if (u.icon==76) yy+=((t%8<2) and 1 or 0)
   if (u.icon==94) yy+=flr(t/8)%2
   if (u.icon==92) then
    clip(0,yy,127,i==cpup and 8 or 4)
    spr(u.icon,xx,yy+flr(t/2)%8,2,1)
    spr(u.icon,xx,yy-8+flr(t/2)%8,2,1)
   elseif (u.icon==78) then
    local tt=flr(t/8)%4
    local xxx=0
    local yyy=0
    if (tt==0) then
     xxx-=1
     yy+=1
    end
    spr(u.icon,xx+xxx,yy)
    spr(u.icon+1,xx+8-xxx,yy)
   else
    spr(u.icon,xx,yy,2,1)
   end
  end
  clip()
  pal()
    
  u=upgrade[cpicks[1+cpup]]

  print(u.name,6,py+15,7)
  local ix=87-u.amt*3
  for i=1,u.amt do
   spr(176,6+4*#u.name+i*3,py+13)  
  end
  for ux=1,2*u.df do
   spr(178,84-ux*6+6,py+13)
  end
  
  -- break str into lines
  local str=u.desc
  local lines={}
  local words={}
  local done=false
  while not done do
   local id=indexof(str," ")
   if (id==0) then 
    done=true
    id=#str+1
   end
   add(words,sub(str,1,id-1))
   str=sub(str,id+1)
  end
  -- render lines
  local lc=0
  local x=6
  for w in all (words) do
   if (x+(#w+1)*4>90) then
    lc+=1
    x=6
   end
   print(w,x,py+23+lc*6,1)
   x+=(#w+1)*4
  end
  
  -- help
  local hdr="3 gates = new cards"
  local hy=max(py-11,59)
  printo(hdr,48-#hdr*2,hy,7,1)
  local lpy=max(py+42,122)
  local hdr="‹‘browse  —select   "
  print(hdr,48-#hdr*2,lpy,6)
  
 end
 
 camera()
 
 
 -- tutorial
 if (mode==-1) then
  local ty1=max(50,140-t*8)
  if (t>100) ty1=50-8*(t-100)
  textbox("play cards to ski",ty1,1)
 
  local ty2=max(86,140+800-t*8)
  if (t>200) ty2=86-8*(t-200)
  textbox("pass gates to score",ty2,2)
 
  local ty3=max(40,140+1600-t*8)
  if (t>300) ty3=40-8*(t-300)
  textbox("don't crash!",ty3,3)
 end
  
 -- wipe
 if (wipe>0) then
  for y=0,128,4 do
   rectfill((16-wipe)*10-y/4,y,
            256,y+3,10)
           
  end
 end
 
 
 -- debug
 if (debug) then
  local mx=113-pl.x
  local my=100-pl.y
  
  for o in all(obstacles) do
   pset(mx+o.x,my+o.y,8) 
  end
  pset(mx+pl.x,my+pl.y,7)
 end
 
end

function draw_card_bg(x,y,col)
 rectfill(x+1,y+1,x+cw,y+ch,1)
 rectfill(x,y,x+cw-1,y+ch-1,col)
end

function draw_card(c,x,y)
 if (c.hidden) then
  spr(96,x+2,y-4,3,2)
  return 
 end
 
 if (c==ccard) then
  c.ex=-8 
 else
  c.ex*=0.7
 end

 local col=(c==ccard and 10 or 12)
 if (pl.speed==0 and c.id==4) then
  col=8
 end
 draw_card_bg(x+c.ex,y,col)
 local iw=1
 if (c.id>=9) iw=2
 pal(12,col==10 and 12 or 7)
 spr(c.spr,x+1+c.ex,y+1,iw,1)
 
 local show_bonus=pl.speed

 if (ccard != nil and ccard!=c and ccard.id==5) show_bonus+=1
 if (ccard != nil and ccard!=c and ccard.id==4) show_bonus-=1
 if (c.id==6) show_bonus=0
 if (c.id==7) show_bonus=0
 if (c.id==8) show_bonus=0
 if (c.id==9) show_bonus=0
 if (c.id==10) show_bonus=0
 
 if (show_bonus>0) then
  print("+"..show_bonus,x+20+c.ex,y+4,12)
 end

 if (c.speed>0) then
--  spr(115+c.speed+show_bonus,x+13+c.ex,y+1)
  spr(115+c.speed,x+13+c.ex,y+1)
 end

 
 pal()
end


function draw_path(c)
 local x=pl.x+c.dx
 local y=pl.y+c.dy
 if (c.dy==0) y+=1
 for i=1,ccard.speed+ccard.sm*pl.speed do
  
  -- draw path
  local ox=-c.dx*16
  local cx=-1+c.dx
  for a=0,15,8 do
   local j=(a+t%8)
   local col=12
   circfill(ox+8+x*16+j*c.dx+cx,
            -8+y*16+j*c.dy,
            min(i,3),
            col)
  end
  if (i==ccard.speed+ccard.sm*pl.speed) then
   circ(ox+7+x*16+16*c.dx,
        -9+y*16+16*c.dy,
        2+flr(t/2)%6,
        12)
  end

  x+=c.dx
  y+=c.dy
 end
 
 -- eraser
 if (c.id==10) then
  local ecol={15,15,14,8,14,15}
  local et=flr(t/4)%#ecol+1
  col=ecol[et]
  rect(16*x-10-et,16*y-26-et,
       16*x+24+et,16*y+8+et,col)
 end
end


function draw_path_obstacles(c)
 local x=pl.x+c.dx
 local y=pl.y+c.dy

 for i=1,ccard.speed+ccard.sm*pl.speed do
  
  -- check for obstacles
  for i=1,#obstacles do
   o=obstacles[i]
   if (o.y>pl.y+12) i=999
  
   if (not o.sink and o.x==x and o.y==y and fx[o.spr]!=0) then
    local skip=false
    if (o.spr==42 or o.spr==46) skip=true
   -- if (fx[o.spr]==134 and ccard.dx==0) skip=true
    
    if (not skip) then
     local sx=8*(fx[o.spr]-128)
     local sy=64
     local st=flr((t+i*2)/2)%8
     local s=16--8+st
     local cdx=ccard.dx
     if (cdx==0 and (o.spr==10 or o.spr==6)) cdx=1
     if (cdx==0 and (o.spr==14 or o.spr==8)) cdx=-1
     sspr(sx,sy,16,16,
          x*16+cdx*st/2,
          y*16-st-4,
          s,s)         
    end
   end
  end

  x+=c.dx
  y+=c.dy
 end
end

-- bad last minute
-- cut n paste
function draw_letters_2(a,b,sx,sy)
 local x=0
 
 for j=a,b do
  local l=letters[j]
  for i=0,15 do
   pal(i,1)
  end
  sspro(l[1],96+l[2],l[3],16,sx+x,sy)
  pal()
  local dx=l[3]
  sspr(l[1],96+l[2],l[3],16,sx+x+l[3]/2-dx/2,sy,dx,16)
  x+=l[3]+1
 end
end

play_state = {
 name = "play",
 init = init_play,
 update = update_play,
 draw = draw_play
}



-->8
--------------------------------
-- core functions 
--------------------------------
debug_str=""

--------------------------------
-- state swapping 
--------------------------------
state, next_state, change_state = {}, {}, false

function swap_state(s)
 next_state, change_state = s, true
end

--------------------------------
-- base functions 
--------------------------------
function _update()
 if (change_state) then
  state, change_state = next_state, false
  state.init()
 end

 state.update() 
end

function _draw()
 state.draw()
 
 -- debug, 175 tokens
 if (debug) then
  camera()
  
  local str = state.name .. " "
    
  if (btn(0)) str = str .. "‹"
  if (btn(1)) str = str .. "‘"
  if (btn(2)) str = str .. "”"
  if (btn(3)) str = str .. "ƒ"
  if (btn(4)) str = str .. "Ž"
  if (btn(5)) str = str .. "—"  

  str = str .. " " .. debug_str
  
  local mr = stat(0)/1024

  local ypos = 121
  if (debug_at_top) ypos=0
  rectfill(0,ypos,127,ypos+6,8)
  
  line(1, ypos+2, 8, ypos+2, 1)
  line(1, ypos+2, 1+min(7*stat(1),7), ypos+2, (stat(1)>1 and 8 or 12))
  
  line(1, ypos+4, 8, ypos+4, 2)
  line(1, ypos+4, 1+min(7*mr,7), ypos+4, (mr>1 and 8 or 14))
  print(str,10,ypos+1,15)

  debug_str = ""
 end
 
end
-->8
--------------------------------
-- utilities
--------------------------------

function textbox(str,y,extra)
 rectfill(2,y,92,y+9,13)
 rect(2,y+1,92,y+10,1)
 rect(2,y,92,y+9,12)
 print(str,4,y+3,7)
 
 if (extra==1) then
  rectfill(79,y-1,88,y+11,1)
  rectfill(79,y-1,88,y+10,12)
  local ar=flr(t/16)%4
  if (ar==3) ar=1
  pal(12,5)
  spr(183+ar,80,y+2)
  pal(12,7)
  spr(183+ar,80,y+1)
  pal()
 end

 if (extra==2) then
  rectfill(81,y-5,89,y+14,1)
  rectfill(81,y-5,89,y+13,12)
  for i=0,15 do pal(i,5) end
  spr(10,81,y-3,1,2)
  pal()
  spr(10,81,y-4,1,2)
 end

 if (extra==3) then
  rectfill(69,y-5,86,y+13,1)
  rectfill(69,y-5,86,y+12,12)
  pal(13,12)
  pal(6,12)
  spr(34,70,y-3,2,2)
  pal()
 end

end

function ssprt(sx,sy,sw,sh,dx,dy,dw,dh,tf)
 for y=0,sh-1 do
  sspr(sx,sy+y,sw,1,dx+(dw-y*tf),dy+y,dw,1)
 end
end

function bp()
 if (btnp(—)) return true
 if (btnp(Ž)) return true
end

function sign(x)
 if (x<0) return -1
 if (x>0) return 1
 return 0
end

function indexof(str,c) 
 for i=1,#str do
  if (sub(str,i,i)==" ") return i
 end
 return 0
end

function printc(str,cx,y,c)
 print(str,cx-#str*2,y,c)
end

function prints(str,x,y,c1,c2)
 print(str,x,y+1,c2)
 print(str,x,y,c1)
end

function printo(str,x,y,c1,c2)
 for i=-1,1 do
  for j=-1,1 do
--   print(str,x+1,y,c2)
--   print(str,x,y+1,c2)
--   print(str,x-1,y,c2)
--   print(str,x,y-1,c2)
 print(str,x+i,y+j,c2)
  end
 end
 print(str,x,y,c1)
end
-->8
--------------------------------
-- title screen
--------------------------------
first=true
function init_title()
 letters={
  {0,12}, --a
  {12,12}, --l
  {24,12}, --p
  {36,6}, --i
  {42,12}, --n
  {54,12}, --e
  {0,12}, --a
  {12,12}, --l
  {24,12}, --p
  {0,12}, --a
  {66,12}, --c
  {0,12}, --a
 }
 
 trees={}
 trails={}
 
 wipe=0
 
 t=-10
 
 music(0)
end

function update_title()
 t+=1
 
 if (bp() and wipe==0) then
  wipe=1
  sfx(61)
  music(4)
 end
 
 if (wipe>0) then
  wipe+=1
  if (wipe>16) swap_state(play_state)
 end
 
 local sprs={2,2,4,34,32,6,8,32,34}
 if (rnd()<0.03) then
  add(trees,{
   x=-16+rnd(32),
   y=128,
   spr=sprs[flr(rnd(#sprs)+1)]
  })
 end
 if (rnd()<0.03) then
  add(trees,{
   x=96+rnd(48),
   y=128,
   spr=sprs[flr(rnd(#sprs)+1)]
  })
 end
 
 for tt in all(trees) do
  tt.y-=1
  if (tt.y<-16) del(trees,tt)
 end
end

function draw_title()
 cls(7)
 
 -- grid
 for x=0,8 do
  for y=0,8 do
   spr(0,x*16-8,y*16-t%16,2,2)
  end
 end
 
 -- trees
 for tt in all(trees) do
  spr(tt.spr,tt.x,tt.y,2,2)
 end 
 
 for tt in all(trails) do
  rect(tt.x,tt.y,tt.x+1,tt.y+1,12)
  tt.y-=1
  if (tt.y<-1) del(trails,tt)
 end
 
 local ay=min(70,t-16)
 local dx=10*sin(t/100)+10*cos(t/80)
 local odx=10*sin((t-1)/100)+10*cos((t-1)/80)
 local ss=max(-1,min(1,2*(dx-odx)))
 if (abs(ss)!=1) ss=0
 spr(66+2*ss,58+dx,ay,2,2) 
 
 add(trails,{
  x=62+dx,
  y=ay+9
 })
 add(trails,{
  x=68+dx,
  y=ay+9
 })
 
 
 
 local lt=min(t*8,128)
 local llt=min((t-6)*8,128)
 
 for y=0.5,19.5 do
  line(lt-128,y+17,96-y/2-128+lt,y+17,13)
  line(lt-128,y+14,96-y/2-128+lt,y+14,12)
  line(32-y/2-lt+128,y+41,127-lt+128,y+41,13)
  line(32-y/2-lt+128,y+38,127-lt+128,y+38,14)
 end
 
 draw_letters(1,6,llt-128+15,16)
 draw_letters(7,12,31-llt+128,40)
 
 local tt=min((t+40)*2,128)
 local tt2=min((t+36)*2,128)
 print("created by @johanpeitz",3,113-tt+129,6)
 print("created by @johanpeitz",3,113-tt+128,13)
 print("audio by @gruber_music",3,120-tt2+129,6)
 print("audio by @gruber_music",3,120-tt2+128,13)

 if (t>0) then
  local c=t%16>4 and 12 or 14
  print("— to start ",min(3,t-90),103,c)
 end 
 
 -- best
 local str="best: "..best
 printo(str,128-#str*4-1,min(2,-50+t),7,14)

 -- head
 spr(204,
     max(95,190-t*2)+3.5*cos(t/100),
     99-abs(3*sin(t/100)),
     4,4)
 
 -- exit wipe
 if (wipe>0) then
  for y=0,128,4 do
   rectfill(-256,y,wipe*10-y/4+4,y+3,12)
   rectfill(-256,y,wipe*10-y/4,y+3,10)
  end
 end
 
 -- entry wipe
 if (t<32)then
  rectfill(0,0+(t+10)*8,
   128,128,12)
  rectfill(0,10+(t+10)*8,
   128,128,first and 7 or 10)
 end
end

function draw_letters(a,b,sx,sy)
 local x=0
 
 for j=a,b do
  local l=letters[j]
  for i=0,15 do
   pal(i,1)
  end
  sspro(l[1],96,l[2],16,sx+x,sy)
  pal()
  local dx=l[2]--*sin((t+j*2)/30)
  sspr(l[1],96,l[2],16,sx+x+l[2]/2-dx/2,sy,dx,16)
  x+=l[2]+1
 end
end

function sspro(sx,sy,sw,sh,dx,dy)
 for x=-1,1 do
  for y=-1,1 do
   if (abs(x)!=abs(y)) then
    sspr(sx,sy,sw,sh,dx+x,dy+y)
   end
  end
 end
end


title_state = {
 name = "title",
 init = init_title,
 update = update_title,
 draw = draw_title
}
-->8
--------------------------------
-- wipe screen
--------------------------------

function init_wipe()
 t=-1
end

function update_wipe()
 t+=1

 if (t>14) swap_state(title_state)
end

function draw_wipe()
 for i=0,15 do
  line(0,t*16+i+4,t*16+i+4,0,12)
  line(0,t*16+i,t*16+i,0,10)
 end
end


wipe_state = {
 name = "wipe",
 init = init_wipe,
 update = update_wipe,
 draw = draw_wipe
}