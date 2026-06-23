tempo=29
gs=36
dir={1,0,0,1,-1,0,0,-1}
dir8={1,0,1,1,0,1,-1,1,-1,0,-1,-1,0,-1,1,-1}
btdi={1,3,0,2}

function _init()
 t=0
 tweens={}
 anims={}
 delays={}
 difficulty=0
 
 init_menu()
 --init_dungeon()
end

function init_menu()
 --music(0)
 draw=nil
 loop=upd_menu
 mstep=0
	sel=0
	t=0
 phase=function()
  if t%16<8 then
   print("press z to start !",28,120,7)
  end
  if btnp(4) then
   phase=disp_menu
   sfx(53)
  end
 end
 
end

function upd_menu()

 cls()
 
 for x=0,15 do
  for y=6,15 do
  
   if rnd(2)<1 then apal(2) end
    spr( mid(97,85+rand(4)+y,104) ,x*8,y*8)
   pal()
   
  end 
 end
 
 h=32
 for i=0,4 do
  c=4-i
  le=min(t,32)*c
  line( 64-le,h,64+le,h,sget(i,8))
 end
 
 clip(0,h-32,127,32)
 y=max(17,h+32-t)
 sspr(64,96,59,16,36,y)
 
 c=mid(0,(t-32)/4,8) 
 if c<8 then apal( sget(c,13) ) end
 clip(0,h+2,127,h+32)
 sspr(64,112,44,16,44,h+2)
 clip()
 pal()
 
 phase()

end

function disp_menu()
 if t<100 then t=100 end
 
 cy=64
 function pr(s,c)
  print(s,(127-#s*4)/2,cy,c)
  cy+=8
 end
 
 pr("difficulty setup",7)
 
 dif={"easy","medium","insane"}
 for i=1,3 do 
  col=13
  if i==sel+1 then 
   col =sget(sel*2+t%2,15)
  end
  pr(dif[i],col)
 end

 for i=0,1 do
  if btnp(2+i) then 
   sel=max(0,sel+i*2-1)
   sfx(52)
  end
 end

 if btnp(4) then
  difficulty=sel
  init_dungeon()
 end
 
end




function swap_monster()
 sfx(6)
 nxt=nil
 ok=false
 for e in all(ents) do
  if e.mt then
   if not nxt then nxt=e end
   if ok then
    nxt=e
    break
   end
   if e==monster then
    ok=true 
   end
  end
 end
 set_monster(nxt)
 
end



function init_dungeon()
 turn=0
 danger=0
 step=0
 orbs=0
 
 res={1,0,0}
 gold=0
 specials={}
 party={}
 --spawns={}
 corpses={}
 item_spots={}
 traps={}
 upgrades={0,0,0,0,0,0,0}
 expansion=0
 item_count=0
 
 nxt=212
 ents={}
 low={}
 heroes={}

 --
 cam=mke(144,144)
 cam.slide=0.4

 -- init dirt
 squares={}
 for i=0,gs*gs-1 do
  sq={}
  sq.life=10
  sq.x=i%gs
  sq.y=flr(i/gs)
  sq.t=1
  sq.gold=0
  sq.item_score=0
  
  proba=5+difficulty*5
  --log="        "..proba  
  for i=0,1 do
   if rnd(proba)<1 then sq.gold+=1 end
  end
  
  add(squares,sq)
 end
 
 --orbs
 k=8-difficulty*2 kk=flr(k*1.4)
 --k=14
 a={
  gsq(gs/2,k),
  gsq(kk,gs-kk),
  gsq(gs-kk,gs-kk) }
 for sq in all(a) do
  sq.orb=1
 end
 
 -- init boss
 boss=mke(gs*4-8,gs*4-16)
 boss.boss=1
 boss.atk=0
 boss.dmg=0
 boss.life=10
 boss.spell=0
 boss.fr=78
 boss.sz=2
 
   
 -- first dungeon
 for x=0,7 do
  for y=0,7 do
   sq=gsq(x+gs/2-4,y+gs/2-4)
   sq.t=mget(x,y)
   if sq.t==2 then wallify(sq) end
   if sq.t>32 then 
    sq.t=4
    sq.e=boss
    boss.sq=sq
   end
   if sq.t!=1 then sq.gold=0 end
   if sq.t==3 then
    sq.door=0
   end
  end
 end
 

 --
 build_boss_path()
 reset_shop()
 cen=gsq(gs/2,gs/2)
 for i=0,1 do 
  cen=gsq(gs/2+i-1,gs/2)
  m=make_monster(i*2,cen) 
  set_monster(m)
 end

 --make_hero(2,gsq(gs/2+3,gs/2))
 
 --
 gen_event()
 ini_play() 
 draw=draw_game 
 
end


function view(x,y,move)
 if not move then
  cam.x=x
  cam.y=y
  return
 end
end

function ini_play()
 
 if boss.life<=boss.dmg then
  gameover()
  return
 end

 -- check no monster
 k=0
 for e in all(ents) do
  if e.mt then k+=1 end
 end
 if k==0 then
  tick(1)
 else 
  loop=play
 end
 
end

function play()

 if orbs==3 then
  ending()
  return
 end

 if monster.dead then 
  swap_monster()
 else
  control_monster()
 end
end

function ending()
 
 balls={}
 for i=0,3 do
  e=mke(0,0)
  e.fr=57
  add(balls,e)
 end


 loop=function()
  r=4+t*0.2
  for i=0,3 do
   an=i/3+t*0.01
   e=balls[i+1]
   e.x=136+cos(an)*r*2
   e.y=136-t/4+sin(an)*r
   
   p=pop(e)
   
  end
 end
 
 
 t=0
 delay(init_menu,120)
 boss.fr=72
  
end


function control_monster()
  
 scan=monster
 msq=monster.sq 
 cam.focus=monster
 

 if not ready and btn()==0 then ready=true end
 if not ready then return end
 
 -- remove gold
 if t%4==0  and msq.bdist<=1 and monster.gold>0 then
  sfx(37)
  monster.gold-=1
  gold+=1
  monster.fr=106+min(5,monster.gold)
  anim(boss,{72,78},8,1)
 end
 
 -- remove orb
 if monster.orb and msq.bdist<=1 then
  monster.orb=nil
  orbs+=1
  sfx(51)
 end
 
 -- move
 f=function(extra)
  tick(5-monster.spd) 
 end

 
 for di=0,3 do 
  if btn( btdi[di+1] ) then 
   nsq=gnei(monster.sq,di) 
   
   function go(nsq)
    moveto(monster,nsq,f)
    sfx(16+monster.mt)
    ba=64+monster.mt
    if monster.grab_gold then
     ba=106+min(5,monster.gold)
     if monster.orb then ba=105 end
    end 
    anm={ba+16,ba}
    anim(monster,anm,4,1)

    
    loop=nil     
   end  
   
   if di==0 and monster.flip then monster.flip=nil end
   if di==2 and not monster.flip then monster.flip=1 end
   if is_free(nsq) then
    go(nsq)
    return
   else
        
    -- hit hero
    if nsq.e!=nil and nsq.e.ht then
     atk(monster,nsq)
     rip=function() atk(nsq.e,monster.sq) end
     delay(rip,10)
     delay(f,18)
     loop=nil
     return
    end
    
    -- ghost
    if monster.mt==4  then
     nxt=gnei(nsq,di)
     if is_free(nxt) then
      go(nxt)
      return
     end
    end
    
    -- swap
    if nsq.e!=nil and nsq.e.mt and not nsq.e.boss then
     set_monster(nsq.e)
    end
    
    -- dig
    if nsq.t==1 then
     loop=nil
     sfx(32)
     delay( function() tick(1) end,4)
     impact(nsq,monster.dig)
    end
    
    -- reload trap
    if nsq.trap==0 then
     nsq.trap=1
     tick(3)
     sfx(50)
    end         
  
   end    
  end
 end

 -- shop
 if btnp(4) then open_shop() end

 -- debug
 if btnp(5) then 
  swap_monster() 
 end
  
end

------------
--- shop ---
------------
function open_shop()
 sfx(42)
 shop_orb=orb
 loop=loop_shop
 focus=0
 shop_slide=12
 shop_exit=nil
 
end


function draw_shop()

 ec=8
 sw=30
 sh=30
 mw=(128-sw*3-ec*2)/2
  
 for i=0,8 do
  x=mw+(sw+ec)*(i%3)
  y=12+(sh+ec)*flr(i/3)
  if shop_slide then y+= shop_slide^2 end
  sl=slots[i+1]
  
  colors={7,0,1}
  if sl.locked then colors[3]=2 end
  mx=1  
  for kk=0,2 do
   if focus==i or kk>0 then
    k=2-kk
    rectfill(x-k,y-k,x+sw+k,y+sh+k,colors[kk+1])  
   end
  end
  
  if not sl.locked then
   apal(0)
   camera(-1,-1)
   for dr=0,1 do
    k=shop_content[i+1]
    fr=k+64 
    if k>=10 then fr=k+230 end
    spr(fr,x+(sw-8)/2,y+12)    
    sspr(35,8,5,5,x+1,y+1)
    print(sl.cost,x+7,y+1,7)
    print(sl.name,x+(sw-#sl.name*4)*0.5,y+24,7)
    pal()
    camera()
   end
  end
  
  if not shop_exit then
  
   if i==focus then
    col=7
    if shop_error and t<shop_error then
      if t%4<2 then col=8 end
    else
     shop_error=nil
    end
    rect(x-2,y-2,x+sw+2,y+sh+2,col)
   end
  end
 end
end

function loop_shop()
 
 
 if shop_exit then 
  shop_slide+=1
  if shop_slide > 10 then
   ini_play()
   shop_slide=nil
   return
  end
 else
  shop_slide=max(shop_slide-1,0)
 
 end
 
 
 -- leave
 if btnp(4) and not shop_exit then 
  shop_exit=1
  sfx(43)
 end 
 
 -- move focus
 x=focus%3
 y=flr(focus/3)
 for di=0,3 do
  if btnp(btdi[di+1]) and not shop_error then
   x=mid(0,x+dir[di*2+1],2)
   y=mid(0,y+dir[di*2+2],2)
   focus=x+y*3
   sfx(33)
  end 
 end
 
 -- select
 sl=slots[focus+1]
 if btnp(5) then
  ok=pay(sl.cost) and not sl.locked
  if sl.k==11 and #get_door_spots()==0 then ok=false end
  
  if ok then
   sfx(35)
   buy_slot(sl)
  else
   sfx(34)
   shop_error=t+20
   pay(sl.cost,1)
  end
 end
end

function rand(k)
 return flr(rnd(k))
end

function buy_slot(sl)
 
 sl.locked=1
 slots[5].cost=max(slots[5].cost-1,0)
  
 if sl.k>=10 and sl.k<13 then
  upgrades[sl.k-9]=upgrades[sl.k-9]+1
  
  -- traps
  if sl.k==10 then
   a=get_trap_spots()
   sq=a[1+rand(#a)]
   sq.trap=1
   add(traps,sq)   
  end

  -- door
  if sl.k==11 then
   a=get_door_spots()
   sq=a[1+rand(#a)]
   sq.t=3
   sq.door=0
  end
  
  -- healing
  if sl.k==12 then
   
   for e in all(ents) do
    if e.mt then e.dmg=0 end
   end
  end 

    
 end
 
 if sl.k==13 then
  reset_shop()
  return
 end
 
 if sl.k<10 then
  make_monster(sl.k,get_free_boss_sq())
 end

 
end

function get_trap_spots()
 a={}
 for sq in all(squares) do
  if sq.t==2 and not sq.trap then
   b=gneis(sq)
   for nsq in all(b) do
    if nsq.t==0 then
     add(a,sq)
     break
    end
   end
  end
 end 
 return a
end

function get_door_spots()
 a={}
 for sq in all(squares) do
  if sq.t==0 then
   wall=nil
   sum=0
   v=nil
   for di=0,1 do
    k=gnei(sq,di).t     
    ct= di==0 and (k==0 or k==2) 
    if (k==v or ct) and gnei(sq,(di+2)%4).t==k then
      sum+=1
    end
    v=2-k
   end
   if sum==2 then add(a,sq) end
  end
 end
 return a
end

function pay(cost,rst)
 inc=-1
 if rst then inc*=-1 end
 gold+=inc*cost
 return gold>=0 
end


function anim(e,a,r,lp) 
 local anm={}
 tl={}
 for i=1,lp do 
  for f in all(a) do
   for k=1,r do add(tl,f) end
  end
 end
 anm.a=tl
 anm.e=e
 anm.t=0
 add(anims,anm)
 return anm
end




function set_monster(e)
 monster=e 
 ready=false
 e.flh=4
 delay(function()e.flh=4 end,10)
end




function tick(k)
 step+=k

 if step>tempo then
  step-=tempo 
  newturn()
 end
 
 for e in all(heroes) do
   e.clock+=k
 end
 
 for c in all(corpses) do
  c.regen+=1
  if c.regen>=4+c.lock*4 and is_free(c.sq) then
   sfx(25)
   c.dead=nil
   c.dmg=0
   egoto(c,c.sq)
   add(ents,c)
   del(corpses,c)
  end  
 end
 
 for sq in all(item_spots) do
  e=sq.item
  if e.sleep then
   e.sleep-=1
   if e.sleep== 0 then 
    e.sleep=nil
    build_item_path()
   end
  end
 end 
 
 resolve_heroes()

end

function resolve_heroes()

 -- trap interrupt
 for tr in all(traps) do
  function chk(trg)
   return trg.ht
  end
  trg,di=seek_target(tr,chk,0)
  if trg and tr.trap==1 then
   tr.trap=0
   shoot(tr.x*8,tr.y*8,trg,di,0)
   delay(resolve_heroes,10)
   return
  end
 end

 --
 check_death()
 k=0
 ripostes=0
 dt=8
 for h in all(heroes) do
  if h.clock>=6-h.spd then
   h.clock-=6-h.spd
   run_hero(h)
   k+=1
  end
 end
 if k>0 then  
  if ripostes>0 then dt+=10 end
  delay(resolve_heroes,dt)
 else
  ini_play()
 end 
end

function check_death()
 for e in all(ents) do
  if e.dmg!=nil then
   if e.dmg >= e.life then
    kill(e)
   end
  end
 end 
end

function run_hero(h)

 local a=gneis(h.sq)
 
 -- hit_boss
 for nsq in all(a) do
  if nsq.t==4 then
   atk(h,nsq)
   return
  end
 end
 
 -- hit_monster
 for nsq in all(a) do
  if nsq.e !=nil and nsq.e.mt!=nil then
   atk(h,nsq)
   function rip() atk(nsq.e,h.sq) end
		 delay(rip,10)
		 ripostes+=1
		 return
  end
 end 
 
 -- check proj
 if h.spell>0 or h.arrow>0 then 
  
  function chk(t) return t.mt and t.mt!=4 end
  trg,di=seek_target(h.sq,chk,1)
  
  if trg then
			dt+=16
   if h.spell>0 then
    h.spell-=1
    st=1
   else
    h.arrow-=1
    st=0
 		end      
   shoot(h.x,h.y,trg,di,st)      
   return
  end
  
 end
 

 -- move to item
 for nsq in all(a) do
  if is_free(nsq) and h.sq.idist and nsq.idist then 
   if nsq.idist<h.sq.idist and nsq.idist<8 then
    if nsq.item and not nsq.item.sleep then
     grab_item(h,nsq.item)
    else
     moveto(h,nsq)
    end
    return
   end
  end
  
 end 
 
 -- move to boss 
 for nsq in all(a) do
  if is_free(nsq) and nsq.bdist<h.sq.bdist then
   moveto(h,nsq)
   return
  end
 end
end


function seek_target(from,chk,dmin)

 for di=0,3 do
  bsq=gnei(from,di)
  for k=0,10 do
   if not is_free(bsq) or bsq.door==0 then
    trg=bsq.e
    if trg and not chk(trg) then 
     trg=nil
    end
    if k>=dmin and trg then
     return trg,di
    end      
    break
   end
   bsq=gnei(bsq,di)
  end
 end 
 return nil 
end

function shoot(sx,sy,trg,di,st)

 
 local e=mke(sx,sy)
 e.fr=44

 
 local pmax=16
 local dmg=1
 
 if st==1 then  
  sfx(44)
  e.upd=pop
  dmg=2
 else
  e.fr+=16+di
  pmax=0
 end
 
 function boom()
  kill(e)
  damage(trg,dmg) 
  for i=0,pmax do   
   p=pop(e)
   p.vx*=2
   p.vy*=2
  end
 end
 
 mktw(e,trg.x,trg.y,10,boom)
end

function pop(e)
 p=mke(e.x,e.y)
 p.fr=169
 p.burn=7
 p.vx=rnd(1)-0.5
 p.vy=rnd(1)-0.5
 p.frict=0.95
 p.timer=10+rnd(12)
 return p
end

function yoyo(c) 
 return sin(0.5+c*0.5)*0.5
end

function atk(e,tsq)
 tw=mktw(e,tsq.x*8,tsq.y*8,8)
 tw.gc=yoyo
 
 vic=tsq.e
 if vic==nil then return end
 damage(vic,e.atk)

end

function damage(vic,n)
 vic.dmg+=n
 sfxk=38
 
 -- boss
 if vic.boss then 
  sfxk+=1 
  if vic.dmg>=vic.life then 
   sfxk+=1 
   vic.fr=74
  else
   anim(vic,{76,74,74,76,78},2,1) 
  end
 end
 
 delay( function() sfx(sfxk) 
  if not vic.boss then vic.hit=5 end
 end,4)


end

function kill(e)
 e.dead=1
 del(ents,e)
 if e.mt then
  add(corpses,e)
  e.regen=0
 end 
 if e.ht then
  e.sq.gold=1
  del(heroes,e) 
 end
 if e.sq then e.sq.e=nil end

 
end

function gameover()

 loop=loop_gameover
 
 cam.focus=boss
 cam.slide=0.1
 
 sh=mke(boss.x,boss.y)
 sh.fr=boss.fr
 sh.sz=boss.sz
 t=0
end

function loop_gameover()
 sh.vis=t%8<4
 
 
 if t==40 then
  sfx(41)
  kill(sh)  
  for i=0,63 do
   an=i/64
   sp=0.2+rnd(8)
   local e=mke(sh.x+4,sh.y+4)
   e.vx=cos(an)*sp
   e.vy=sin(an)*sp
   e.frict=0.9+rnd(0.1)
   e.timer=20+rnd(40)
   
   if i%3==0 then
    e.fr=139
    anm=anim(e,{138,139,140,139},2,8)
    anm.t=rand(4)
   else
    if i%3==1 then
     anm=anim(e,{153,154},2,32)
     anm.t=rand(4)
     e.frict*=0.9
     e.timer*=0.25
    else
     e.fr=137
     e.frict=0.98
    end
   end
  end
 end
 
 if t==80 then
  edr=function()
   rectfill(0,60,127,68,0)
   print("game over",46,62,7)
  end  
 end
 
 if btnp(4) then
  edr=nil
  init_menu()
 end

 
end



function reset_shop()
 shop_content={0}
 others={1,2,3,4,5,10,11,12}
 
 for spc in all(specials) do
  del(others,spc)
 end
 
 while(#shop_content<9) do
  if #shop_content==4 then 
   k=13
  else
   k=others[1+rand(9)]
  end
  if k!=nil then
   del(others,k)
   add(shop_content,k)
  end
 end
 
 slots={} 
 for i=0,8 do
  sl={}
  add(slots,sl)
  k=shop_content[i+1]
  sl.cost=10
  sl.name="option"
  if k<10 then
   sl.cost=(mget(21,1+k)-192)*4
   sl.name=mon_names[k+1]
  else
   sl.cost=2+upgrades[k-9]
   sl.name=aug_names[k-9]
   if k==13 then sl.cost=4 end
   
  end
  sl.k=k
 end
 
 --for sl in all(slots) do
 -- if sl.locked then sl.cost-=1 end
 --end
 
 
end


function gen_event()
 event=nil
 if (#party)^2 > rnd(turn) then  
  event=0
 else 
  if (expansion-16)/12>item_count then
   event=10+rand(6)
  else
   mx=turn/2
   event=20+min(4,rand(mx))
   --
  end  
 end 
end

function apply_event()
 
 -- raid
 if event==0 then
  for hid in all(party) do  
   h=make_hero(hid,get_far_sq())
  end
  party={}
  return
 end
 
 --
 if event<20 then
  add_item(event-10)
  return
 end
 
 --
 if event<30 then
  add(party,event-20)

  return
 end
 
end


function newturn()
 turn+=1
 
 
 apply_event()
 gen_event()
 
 -- repair doors
 for sq in all(squares) do
  if sq.door==1 and sq.life<10 then
   sq.life=min(sq.life+4,10)
   if sq.life==10 then close_door(sq) end
  end 
 end
 
  
end

function add_item(nn)
 item_count+=1
 bsq=nil
 bsco=0
 
 for sq in all(squares) do
 
  if sq.t==0 and not sq.item then
   sco=sq.item_score-sq.bdist*0.01
   if sq.bdist>4 and (not bsq or bsco<sco) then
    bsq=sq
    bsco=sco
   end
  end
  
 end
 
 e=mke()
 egoto(e,bsq)
 e.fr=37+nn
 
 bsq.gold=0
 bsq.e=nil
 bsq.item=e
 add(item_spots,bsq)
 del(ents,e)
 add(low,e)
	build_item_path()
 
end

function grab_item(h,item)
 e=mke(item.x,item.y)
 e.fr=item.fr
 function f()
  kill(e)
  apply_item(h,item)
 end
 mktw(e,h.x,h.y,8,f) 
 item.sleep=48
 build_item_path()
end

function apply_item(h,item)
 if item.fr==37 then
  h.life+=1
 end
 if item.fr==38 then
  h.atk+=1
 end
 if item.fr==39 then
  h.spell+=1
 end
 if item.fr==40 then
  gold=max(gold-3,0)
 end
 if item.fr==41 then
  h.spd=min(h.spd+2,4)
 end 
 
end

function build_item_path()
 local a={}
 for sq in all(item_spots) do
  if not sq.item.sleep then
   add(a,sq)
  end
 end
 xpd(a,is_path)
 for sq in all(squares) do
  sq.idist=sq.dist
 end
end



------------
--- ents ---
------------

function mke(x,y)
 local e={}
 e.x=x e.y=y e.sz=1 e.vis=true
 add(ents,e)
 return e
end

function make_monster(mt,sq)
 local e=mke()
 if sq!=nil then egoto(e,sq) end
 e.mt=mt 
 e.fr=64+mt
 e.dmg=0
 e.gold=0
 e.spell=0
 
 if mt==4 then e.arrow=3 end
 e.sns=1
 f=function(k) 
  return mget(17+k,1+mt)-192
 end
 e.atk=f(0)
 e.life=f(1)
 e.spd=f(2)
 e.lock=f(3) 
 e.dig=f(5) 
 e.grab_gold=mt==0
 return e
end



function make_hero(ht,sq)
 if sq==nill then return end

 local e=mke()
 add(heroes,e)
 egoto(e,sq)
 e.ht=ht
 e.gold=0
 e.key=0
 e.grab_gold=1
 e.dmg=0
 e.fr=128+ht
 f=function(k) 
  return mget(25+k,1+ht)-192
 end 
 e.atk=f(0)
 e.life=f(1)
 e.spd=f(2)
 e.danger=f(3)
 e.spell=f(4)
 e.arrow=f(5)
 e.clock=0
 return e
end

function egoto(e,sq,lock)
 if e.sq!=nill then
 
  if e.sq.door and e.mt and e.sq.life==10 then
   close_door(e.sq) 
  end 
  e.sq.e=nil
 end
 if lock==nil then
  e.x=sq.x*8
  e.y=sq.y*8
 end
 e.sq=sq
 sq.e=e
 
 --grab gold
 if e.grab_gold and sq.gold>0 then
  e.gold+=sq.gold
  sq.gold=0
  sfx(36)
 end
 
 -- grab orb
 if e.grab_gold and sq.orb then
  sq.orb=nil
  e.orb=true
  sfx(36)
 end
 
 -- door
 if sq.door and sq.door==0 then
  open_door(sq) 
 end
 
 
end

function open_door(sq)
 sfx(46)
 sq.door=1
end
function close_door(sq)
 sfx(47)
 sq.door=0
end



function moveto(e,sq,f)

 -- door lock
 if e.ht and sq.door==0 and e.ht!=3 then
  
  if e.key>0 then
		 e.key-=1
   p=mke(sq.x*8,sq.y*8)
   p.fr=42
   p.vx=0
   p.frict=0.85
   p.vy=-1.5
   p.timer=20
  else
   tw=mktw(e,sq.x*8,sq.y*8,8)
   tw.gc=yoyo
   function imp() 
    sfx(48) 
    sq.impact=1
    sq.life-=e.atk
    if sq.life<=0 then sq.door=1 end
   end
   delay(imp,4)  
   return  
  end
 end
 egoto(e,sq,1)
 mktw(e,sq.x*8,sq.y*8,8,f)
end




function mktw(e,ex,ey,tmax,nxt)
 tw={}
 tw.e=e
 tw.sx=e.x
 tw.sy=e.y
 tw.ex=ex
 tw.ey=ey
 tw.t=0
 tw.tmax=tmax
 tw.nxt=nxt
 add(tweens,tw)
 return tw
end

-------------------
--- pathfinding ---
-------------------
function build_boss_path()
 b={} 
 for sq in all(squares) do
  if sq.t==0 then
   a=gneis(sq)
   for nsq in all(a) do
    if nsq.t==4 then 
     add(b,sq)     
    end
   end
  end  
 end
 xpd(b,is_path)
 for sq in all(squares) do
  sq.bdist=sq.dist
 end
 
end

function xpd(a,chk)
 if chk==nil then chk=is_free end
 for sq in all(squares) do sq.dist=nil end
 for sq in all(a) do sq.dist=0 end
 while(#a>0) do
  na={}
  for sq in all(a) do
   del(a,sq)
   b=gneis(sq)
   for nsq in all(b) do
    if nsq.dist==nil and chk(nsq) then
     nsq.dist=sq.dist+1
     add(na,nsq)
    end
   end
  end
  a=na
 end
 
end


---------------
---- tools ----
---------------
function gsq(x,y)
 return squares[1+y*gs+x]
end

function gnei(sq,di)
 nx=sq.x+dir[di*2+1]
 ny=sq.y+dir[di*2+2]
 return gsq(cyc(nx,ny)) 
end

function gneis(sq)
 local a={}
 for di=0,3 do
  add(a,gnei(sq,di))
 end
 return a
end

function cyc(x,y)
 if x<0 then x+=gs end
 if y<0 then y+=gs end
 if x>=gs then x-=gs end
 if y>=gs then y-=gs end
 return x,y 
end

function is_free(sq)
 return sq.e==nil and is_path(sq)
end
function is_path(sq)
 return sq.t==0 or sq.t==3
end

function is_free_spawn(sq)
 return is_free(sq) and not sq.item
end

function get_free_boss_sq()
 bsq=nil
 for sq in all(squares) do
  if is_free(sq) then
   if bsq==nil or bsq.bdist>sq.bdist then
    bsq=sq
   end
  end
 end
 return bsq
end

function get_far_sq()
   
 dmax=min(3+turn/10,12)
 local a={}
 for sq in all(squares) do
  if is_free_spawn(sq) and sq.bdist>=dmax then
   add(a,sq)
  end
 end
 
 if #a==0 then
  return squares[1]
 end
 
 return a[1+rand(#a)]
  
end

function delay(f,t)
 dl={} dl.t=t dl.f=f
 add(delays,dl)
end



function impact(sq,k)
 sq.impact=1
 sq.life-=k
 if sq.life<=0 then 
  open(sq)  
  build_item_path()
 end
end

function open(sq)
 expansion+=1
 
 sq.t=0
 build_boss_path()
 
 a=gneis(sq)
 wsum=0

 -- autowall
 wlim=8+rnd(8)
 for nsq in all(a) do 
  if nsq.t==1 then
   b=gneis(nsq)
   wall=0
   for bsq in all(b) do
    if bsq.t==0 and bsq!=sq and abs(bsq.bdist-sq.bdist)<wlim then
     wall=1
    end
   end
   if wall==1 then
    wallify(nsq)

   end     
  end
  if nsq.t==2 then wsum+=1 end
 end
end

function wallify(sq)
 sq.t=2
 sq.gold=0
 a=gneis(sq)
 for nsq in all(a) do
  nsq.item_score+=1
 end
end


function _update()
 t+=1
 if loop!=nill then loop() end
 
 -- ents
 foreach(ents,upe)
 
 -- tweens
 for t in all(tweens) do
  t.t+=1
  c=t.t/t.tmax
  if t.gc then c=t.gc(c) end
  t.e.x=t.sx+(t.ex-t.sx)*c
  t.e.y=t.sy+(t.ey-t.sy)*c
  if t.t==t.tmax then
   del(tweens,t)
   if t.nxt then t.nxt() end
  end
 end
 
 -- anims

 for a in all(anims) do
  a.t+=1
  fr=a.a[a.t]
  
  if fr then 
   a.e.fr=fr
  else
    del(anims,a)
  end
  
 end
 
 -- delays
 for dl in all(delays) do
  dl.t-=1
  if dl.t<=0 then 
   del(delays,dl)
   dl.f()
  end
 end 
end

function upe(e)

 if e.vx then
  e.vx*=e.frict
  e.vy*=e.frict
  e.x+=e.vx
  e.y+=e.vy
  if e.timer then
   e.timer-=1
   if e.timer <=0 then   
    kill(e)
   end
  end  
 end
 
 if e.upd!=nil then e.upd(e) end
 
 
end


function _draw()
 
 if draw then draw() end
 if edr then edr() end
 
 --
 
 --
 if( log!=nil ) print(log,0,0,7)

end

function draw_game()
 cls()
 
 
 -- camera
 if cam.focus then
  cam.x += (cam.focus.x-cam.x)*cam.slide
  cam.y += (cam.focus.y-cam.y)*cam.slide
 end
 
 
 --
 if shop_slide then
  for i=0,15 do
   pal(i,sget(56+(i%4),8+flr(i/4)))
  end
 end

 --
 -- corpses
 
 if not shop_slide then
 apal(2)
 for c in all(corpses) do
  spr(c.mt+64,c.x+64-cam.x,c.y+64-cam.y)
 end
 pal() 
 end
 
 -- bg
 dx=flr(cam.x/8)-8
 dy=flr(cam.y/8)-8
 ddx=cam.x%8
 ddy=cam.y%8
 
 for x=0,16 do
  for y=0,16 do
   sq=gsq(cyc(dx+x,dy+y))
   px=x*8-ddx
   py=y*8-ddy
   fr=sq.t
   if fr==2 then
    fr=32+(sq.x%2)+(sq.y%2)*16
   end
   if fr==1 then
    fr=56-sq.life/2
   end
   if fr==3 then
    fr=14+sq.door
    if gnei(sq,0).t==2 then fr+=16 end
   end
   
   if sq.impact then
    sq.impact=nil
    apal(7)
    spr(fr,px,py)
    pal()
   else
    spr(fr,px,py)
   end
    
   if sq.gold>0 then
    k=((t+sq.x+sq.y)%12)/6
    spr(sq.gold*16+k-4,px,py)
   end
   
   if sq.orb then
    spr(56+(t%18)/6,px,py)
   end
   
   if sq.trap then  
    spr(225+sq.trap,px,py)
   end   
  end
 end
 

 
 -- ents
 foreach(low,dre)
  
 -- ents
 foreach(ents,dre)
 
 

 
 -- inter
   
 --party
 x=1
 
 y=103
 for hid in all(party) do
  for i=0,1 do
   rectfill(1+i,y+i,x+11-i,y+11-i,i*2)
   shade(function()
    spr(128+hid,2,y+1)
   end,0)
  end
  y-=13
 end
 
 -- next
 rectfill(0,127-3,127,127,0)
 apal(0) 
 sspr(80,0,16,8,20,116)
 pal()
 rectfill(0,116,20,128,0)
 function f()
  print("next",13,118,7)
 end
 shade(f,0)
 fr=46
 if event<20 then 
  fr=event+27
 else 
  fr=event+108 
 end
 if event==0 then fr=46 end
 spr(fr,2,118)
 
 -- tempo
 for i=0,tempo-1 do
  y=16
  if tempo-i<step then y+=2 end
  sspr(32,y,4,2,13+i*4,125)
 end 
 
 --
 if shop_slide then 
  pal()
  draw_shop()
 end
 
 -- ressources
 rectfill(0,0,127,5,0)
 col=7
 if shop_error then
  col=2+6*flr((t%4)/2)
 end
 
 sspr(35,8,5,5,0,0)
 print(gold,8,0,col)


 apal(0)
 spr(6,49,6,4,1)
 pal()
 for i=0,2 do
  if orbs<=i then apal(1) end
  spr(57,52+i*8,-1)
  pal()
 end
 
 
 -- scan
 if scan!=nill then
  rectfill(116,0,127,11,0)
  rect(117,0,127,10,1)
  spr(scan.fr,118,1)
  for i=0,scan.life-1 do
   fr=40
   if scan.dmg>i then fr+=5 end
   sspr(fr,8,5,5,112-i*5,1)
  end
  
  a={}
  for i=1,scan.atk do add(a,0) end
  for i=1,scan.spell do add(a,1) end
  
  local cx=111
  for fr in all(a) do
   rectfill(cx,6,cx+5,11,0)
   sspr(72+5*fr,8,5,5,cx,6)
   cx-=5
  end
  apal(0)
  sspr(50,8,5,6,cx,6)
  pal()
 end
 

end

function shade(f,col)
 apal(col)
 camera(-1,-1)
 f()
 pal()
 camera()
 f()
end



function dre(e)
 if not e.vis then return end
 x=e.x+64-cam.x
 y=e.y+64-cam.y
 
 if e.hit then
  col=sget(32+e.hit,14)
  apal(col)
  e.hit-=1
  if e.hit==-1 then e.hit=nil end
 end
 
 if e.flh then
  apal(sget(e.flh,11))
  e.flh-=1
  if e.flh < 0 then e.flh=nil end
 end
 
 if e.burn then
  apal(sget(e.burn,12))
  e.burn-=1
  if e.burn < 0 then e.burn=nil end
 end
 
 if e.sleep then
  apal(1)
 end
 if e.shade then apal(e.shade) end
 spr(e.fr,x,y,e.sz,e.sz,e.flip)
 pal()
end

function apal(k)
 for i=0,15 do pal(i,k) end
end



mon_names={
 "goblin",
 "skeleto",
 "orc",
 "dragon",
 "ghost",
 "zombi",

}

aug_names={
 "trap",
 "door",
 "healing",
 "recycle",
 
}
