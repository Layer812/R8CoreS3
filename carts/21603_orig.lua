-- mistigri
-- 2016 benjamin soule
start_lvl=0
alph="cdeimnstxy"
--alphabet="abcdefghijklmnopqrstuvwxyz"
xtra_base={2000,8000,20000}
words="extendmystic"
bounty={10,20,30,50,100,500,100,200}
nf=function() end

time_limit=512

function _init()
 --logs={}
 ents={}
 t=0
 cartdata("mistigri")
 --init_hints()
 --init_hiscores()
 --init_game()
 init_menu()
end

hints="paleo...10altus...20ogre....30megano..50heavy..100ghost..500sunny..100vampi..200apple...50banana.100sberry.150orange.200grape..250wmelon.300cherry.350coco...400storm rod earrings  match     gong      bomb      magic belldoomcollarcornucopia+1 extra ball       +100% ball duration +50% ball speed     +1 big ball         +50% launch speed   +100% stun duration"


--
function init_hints()
 t=0
 function list(bfr,n,le,md,title)
  print(title,36,py,7)
  py+=8
  for i=0,7 do
   px=bx+flr(i/md)*56
   local y=py+(i%md)*10
   spr(bfr+i,px,y)
   print(sub(hints,k,k+le-1),px+10,y+3,8+(i+flr(t/4))%8)
   k+=le
  end
  py+=52
 end

 mdraw = function ()
  camera(0,t/8-16) --8
  py=0  
  print("extra lives at",40,0,8)
  for n in all(xtra_base) do
   py+=8
   print(n.." pts",48,py,7)
  end
  py=48
  bx=12
  k=1
  list(64,0,10,4, "---monsters---")
  list(48,1,10,4, "----fruits----")
  list(56,2,10,4, "----items-----")
  bx=28
  list(228,3,20,6,"---potions----")

  if t==1700 or btnp(5) then
   fadeto(init_menu,true)
  end
 end 
end
--]]

--[[
function init_hiscores()
 hi={} 
 n=0
 for i=0,9 do
  name=""
  score=dget(n+3)
  for h in all(heroes) do
   if h.score> dget(n+3) then
    
   end
  end
  n+=4
 end
 mdraw=draw_hiscores
end
function draw_hiscores()
 n=0
 for i=0,9 do
  name=""
  for k=0,2 do
   ch=dget(n)+1
   name=name..sub(alphabet,ch,ch)
   n+=1
  end
  
  score=dget(n)..""
  while #score<5 do
   score="0"..score
  end
  n+=1
  y=32+i*8
  print(i..">",14,y,6)
  print(name,24,y,7)
  print(".............",36,y,13)
  print(score,88,y,8+(i+t/4)%8)
 end
end
]]

function init_menu()
 
 reload()
 camera()
 x=0
 t=0
 if go!=0 then
  music(0)
 end
 go=0
 mdraw=draw_menu
 
end

function draw_menu()
 if go>0 then go+=1 end
 x=(x-0.25)%128
 for i=0,1 do
  map(96,32,x+i*128-128,8+go*go,16,14)
 end
 print("mistigri",0,120,1)
 for x=0,31 do for y=0,4 do		
		dx=max(40-(t-y)*3,0)*(x-15.5)
		if pget(x,y+120)==1 then
   sspr((t+x+y)%60<4 and 4 or 0,4,4,4,2+x*4+dx,1+y*4-go*go)
  end
 end end
 rectfill(0,120,127,127,0)

 pr=t%24<16
 if go>0 then pr=t%2<1 and go<39 end
 if pr then
  print("press x to start",32,121,7)
 end
  
 dy=max(go*go/32,0)
 spr(194,56,32+dy+cos(t%64/64)*4,2,2)

  
 if btn(5) and go==0 and not fade_n then
  sfx(61)
  music(-1)
  go=1
 end 
 
 if t==512 and go==0 then
  fadeto(init_hints,true)
 end
 
 if go==64 then
  init_game()
 end
end

function init_game()
 
 fadeto(pal,nil)
 monsters={}
 balls={}
 heroes={} 
 ents={}
 xtra=xtra_base

 blid=0
 lvb=0
 bnum=0
 big_fruit=48
 lives=3
 cornucopia=nil
 boss=nil
 
 -- letters
 letters={} 
 for n=1,12 do
  letters[n]={let=sub(words,n,n),act=false}
 end
 --for n=1,15 do add_let(n/2) end

 -- shuffle artefacts
 a={}
 apool={}
 for i=0,21 do
  add(a,mget(i,15))
 end
 while #a>0 do
  add(apool,steal(a))
 end 

 -- heroes
 act=1
 for i=0,1 do
  h=mke(34,0,0)
  del(ents,h)
  h.act=i==0   
  h.score=0
  h.hid=i
  if i==1 then 
   h.rmp=3
  end
  h.powerballs={}
  for i=0,5 do h["ball"..i]=1 end
  add(heroes,h)
 end
 
 goto_level(start_lvl)
 --nxl=0
 init_level()
 mdraw=draw_lvl
end


function init_level()
 clean=false
 lt=0--log(lvl)
 music(lvl==22 and 23 or 3)
 
 -- spawn
 for h in all(heroes) do
  if h.act then spawn_hero(h) end
 end

 -- items
 items={4}
 it=apool[1]
 del(apool,it)
 add(items,rand(128)==0 and 127 or it)
 --add(items,57)
 if cornucopia then
  cornucopia+=1
  dl(40,corn)  
 end

 --
 loop=upd_lvl
end

function goto_level(n)
 lvl=n
 
 --scan
 bop={}
 ggpos={}
 for x=0,14 do for y=0,13 do
  fr=lget(x,y)
  gfr=lget(x,(y+1)%14)
  px=x*8+4
  py=y*8+4
  if not fget(fr,0) and not fget(fr,1)
     and (fget(gfr,0) or fget(gfr,1) ) then
   add(ggpos,{x=px,y=py})
  end  
  
  if fr==34 or fr==35 then  
   h=heroes[fr-33]
   h.spx=px
   h.spy=py   
  elseif fr>=64 and fr<72 then
   mkm(fr-64,px,py)   
  elseif fr==4 then
   add(bop,{x=px,y=py})   
  end  
  
  if fget(fr,4) then
   lset(x,y,lget(0,14) )
  end
  
 end end
 
 --
 if lvl==22 then
  local e=mke(194,64,132)
  e.dp=2
  e.lp=false 
  e.size=16
  e.hp=3
  e.stp=0
  add(monsters,e)
  e.bad=true
  e.hit=function() end
  e.xpl=function(from)
   kill(from)
   if e.rainbow then return end
   e.hp-=1
   e.rainbow=24
   sfx(59)
   if e.hp==0 then
    for e in all(ents) do
     if e != boss and e.bad then 
      kill(e)
     end
    end 
    boss.upd=nil
    boss.twc=nil   
    dl(20,kill_boss)
   end
  end  
  tw(e,64,36,64,60,intro_boss)--64
  boss=e
 end
end

function kill_boss()
 --
 kill(boss)

 flash_bg=0
 tt=7
 shk=16
 
 -- mask part
 for i=0,3 do
  dx=i%2
  dy=flr(i/2)
  p=mke(194+dx+dy*16,boss.x+dx*8-4,boss.y+dy*8-4)
  p.vx=dx*2-1
  p.vy=dy*2-1
  p.life=80
  p.blink=40
  p.frict=0.92
  p.lp=false
 end
 
 -- parts
 for i=0,64 do
  f=function()
   p=spop(boss,2+rand(8))
   an=i/64
   impulse(p,an,8) 
   p.frict=0.85+rnd(0.14)  
  end  
  dl(rand(8),f)
 end
 sfx(60)
 
 --
 f=function()
  boss=nil
  congrats=true
  music(19)
  loop=upd_congrats
 end
 flowers={}
 dl(60,f)
 
end

function upd_congrats()
 foreach(ents,upe)  
 if #ggpos==0 then
  if #flowers>0 and t%2==0 then
   f=flowers[1]
   del(flowers,f)
   kill(f)
   b=mkbonus(48+rand(8),f)
  end 
 elseif rand(16)==0 then
  p=steal(ggpos)
  e=mke(244,p.x,p.y)
  e.rmpo={8,8+rand(8)}
  sfx(54)
  add(flowers,e)
 end    
end

function impulse(e,an,spd)
 e.vx=cos(an)*spd
 e.vy=sin(an)*spd
end


function corn()
 sfx(57)
 flash_bg=1
 tt=5
 spawn_item(cornucopia)
 if cornucopia==55 then 
  cornucopia=nil
 end 
end

block_max=12

function intro_boss() 
 boss.ban=0 
 boss.upd=upd_boss 
 blocks={}
 dl(40,add_block) --40
 --bnext()
end


function upd_boss(e) 
 e.ofy=cos(e.t%64/64-0.2)*6
 
 -- turning blocks
 e.ban-=0.01
 r=18
 k=0
 for b in all(blocks) do
  an=k/block_max+e.ban
  k+=1
  b.x=e.x+cos(an)*r
  b.y=e.y+e.ofy+sin(an)*r
  b.vis=true
 end
 

 if e.stp==0 then return end
 
 -- atk
 k=e.t%128
 boss.rmpo={1,sget(max(6-k/2,0),0)}
 if k==0 then
		boss_atk()
 end
  
end

function boss_atk()

 -- shoot
 if rand((gms()-1)*2)>0 then
  sfx(44)
  local e=badshot(104,boss)
  h=hcl(boss)
  an=sgda(h,boss)
  e.raymod=2
  impulse(e,an,1)
  e.frict=1.05
  e.turn=1
  e.upd=burning
  e.rmp=1
  return
 end

 -- spawn_monster
 sfx(49)
 p=steal(ggpos)
 add(ggpos,p)
 local e=mke(192,p.x,p.y)
 e.rmp=1
 e.life=120
 e.ondeath=function()
  if congrats then return end
  sfx(52)
  mt=rand(4)
  if mt==1 then mt=2 end
  mkm(mt,e.x,e.y)
 end
end

function burning(e)
 p=mka(e.x+rand(3)-1,e.y+rand(3)-1,24,12,4,4,4,2)
 p.rmp=e.rmp
end

function bnext()

 boss.stp=1
 boss.lp=true
 wpx=16+rand(96)
 wpy=16+rand(96)
 tw(boss,wpx,wpy,-0.5,nil,bnext)
 --boss.sm=function(n) return 0.5-cos(n*0.5)*0.5 end
end

function add_block()
 sfx(49)
 local e=mke(224,0,0)
 e.bad=true
 e.blk=0
 e.dp=2
 e.hit=function(ff,dmg)
  dmg = dmg or 1
  sfx(58)
  e.flh=7
  e.blk+=dmg
  e.fr=224+e.blk
  if e.blk>=4 then
   kill(e)
   sfx(53)
   for i=0,4 do
    p=mka(e.x,e.y,8+rand(2)*4,104+rand(2)*4,4,4,1,64)
    impulse(p,rnd(),2)
    p.phys=true
    p.we=0.1
    p.bncy=function(p)
     p.vx*=0.75 
     p.vy*=-0.6 
    end
   end
  end
 end  
 e.xpl=e.hit
 add(monsters,e) 
 e.flh=2
 tt=4
 e.vis=false
 add(blocks,e) 
 if #blocks == block_max then
  bnext()
 else
  --dl(8,add_block)
  dl(12,add_block)
 end
 
 
end

function spawn_hero(h)
 add(ents,h)
 h.vis=true
 h.fr=34
 h.dead=false
 h.x=h.spx
 h.y=h.spy
 h.we=0.5
 h.frict=0.9
 h.upd=upd_hero
 h.phys=true
 h.lp=true 
 h.special=nil 
 
 if lt and lt>=time_limit then
  music(3)
 end
 lt=0
 for m in all(monsters) do
  if m.mad then
   m.mad=false
   m.rmp=nil
   --m.spd-=0.5
  end
 end
 --h.draw=draw_hero
end

--[[
function draw_hero(h,x,y)
 for i=1,h.powerballs do
  an= i/h.powerballs + (t%32)/32
  local r=12
  px=x+cos(an)*r
  py=y+sin(an)*r
  spr(47,px,py)
  for m in all(monsters) do
   adx=abs(px+4-m.x)
   ady=abs(py+4-m.y)
   if adx<6 and ady<6 then
    sfx(54)
    m.xpl()
    h.powerballs-=1
   end
  end
 end 
end
--]]

function lget(x,y)
 return mget((lvl%8)*16+x,flr(lvl/8)*16+y)
end
function lset(x,y,n)
 return mset((lvl%8)*16+x,flr(lvl/8)*16+y,n)
end

function mkm(mt,x,y)
 
 local e=mke(64+mt,x,y) 
 e.raymod=2
 add(monsters,e)
 e.phys=true
 e.obj=true
 e.bad=true
 e.dmg=0
 e.res=3
 e.mt=mt
 e.spd=0.5 
 e.hit=hit
 e.shoot_cd=80
 
 e.upd=upd_mon
 e.draw=function(e,x,y)
  if e.stun and not e.stunshk then
		 sspr(24+mod(2,4)*8,8,8,4,x,y-4)
  end
 end 
 
 e.xpl=function(from)
  sfx(56)
  shk=4
		local b=mkb(e.mt,e)
  xpl(b)
  kill(e)
  return b
 end  
 init_mon(e)
end



function mod(md,lp)
 return flr(t/md)%lp
end

function init_mon(e)

 e.bhv=crawl
 e.wfrmax=2
 e.shoot=shoot
 e.bncx=function(e)
  e.flp=-e.flp
 end  
 
 -- birds
 if e.mt==1 then  
  e.wfrmax=4
  e.bhv=nil
		setfly(e,0.75)
 end 
 
 -- ogre
 if e.mt==2 then
  e.test_shoot=function(h)
   return abs(h.y-e.y)<8 and face(e,h)
  end
 end 
  
 -- boomerangs
 if e.mt==3 then
  e.test_shoot=function(h)
   return dst(h,e)<48 and face(e,h) and not e.rmpo
  end
 end
 
 -- heavy
 if e.mt==4 then
  e.turn=1
  e.spd=1
  e.wfrmax=1
 end
 
 -- ghosts
 if e.mt==5 then
  e.bhv=haunt
  e.hit=nil
  e.wfrmax=3
  e.phys=false
  e.spd=0.25
  e.bad=false  
  function f()
   e.bad=true
  end
  function l()
   e.vis=e.t%2==0
  end 
  dl(80,f,l)  
 end 
 
 -- wheel
 if e.mt==6 then
  e.wfrmax=3
  e.test_shoot=function(h)
   return abs(h.x-e.x)<4 or abs(h.y-e.y)<4
  end  
  e.shoot=dash
 end 
 
 -- vampire
 if e.mt==7 then 
  e.res=6
		setfly(e,0.5)
 end  
 
  
end

function gms()
 sum=0
 for m in all(monsters) do
  if not m.blk then sum+=1 end
 end
 for h in all(heroes) do if h.lift then sum+=1 end end
 return sum
end

function setfly(e,spd)
 e.spd=spd
 e.bhv=fly
 e.vx=e.flp*e.spd
 e.vy=-e.spd
 e.bncy=nf
end

function fly(e)
	advf(e)
	--e.fr=64+e.mt+(flr(t/4)%e.wfrmax)*16
 e.we=0
 e.vx=e.flp*e.spd

 if e.t>64+e.y and e.mt==7 then
  e.t=0
  e.cfocus=16
 end
 if e.cfocus==1 then
  h=hcl(e)
  sfx(52)  
  an=sgda(h,e)  
  smax=e.mad and 2 or 0
  for i=0,smax do
   ba=(i-smax/2)*0.1
   f=badshot(94,e)  
   impulse(f,an+ba,2)
   f.raymod=3
   f.upd=function(f)
    f.flh=t%4<2 and 7 or nil
   end
   if ba==0 then    
 		 e.bvx=-f.vx
  		e.bvy=-f.vy
   end   
  end 
 end
 
end

function badshot(fr,e)
 local f=mke(fr,e.x,e.y)  
 f.bad=true
 f.shot=true
 f.bncx=function(b)
  kill(b)
 end
 f.lp=false
 return f
end



function haunt(e)
 advf(e)
 h=hcl(e)
 
 local dx=mdx(h.x-e.x,60)
 local dy=mdy(h.y-e.y,56)
 local an=atan2(dx,dy) 
 spd=e.spd*(1+cos(t/40)*0.5)
 impulse(e,an,spd)
 e.spd+=0.001
 e.shot=true
 e.flp = sgn(mdx(h.x-e.x,64))
 if gms()==1 or lt<time_limit then 
  vanish(e)
 end
 
end


function face(e,h)
 return e.flp==sgn(h.x-e.x) or e.mad 
end


function advf(e)
 e.fr=64+e.mt+mod(4,e.wfrmax)*16
end

function upd_mon(e)

 -- heal
 if e.dmg>=e.res then
  e.stuncd-=1
  if e.stuncd <= 0 then
   if e.stun then
    e.vy-=2
    init_mon(e)
    gomad(e) 
   end
   e.dmg=0
  end 
 end
 
 -- stun
 e.stun=e.dmg>=e.res
 if e.stun then
  e.we=0.25
  e.stunshk = e.stuncd<20 and t%2==0
  return
 end


 -- bhv
 if e.bhv then 
  e.bhv(e)
 end
 
 -- heavy
 if e.mt==4 then
  e.turn=e.flp
 end
 
end

function gomad(e)
 if e.mad then return end
 e.mad=true
 e.rmp=2  
 --e.spd+=0.5
end

function hmod(n,md)
 n+=md
 n=n%(md*2)
 n-=md
 return n
end

function crawl(e) 

 h=heroes[1]
 hdy=hmod(h.y-e.y,60)
 
 --if seek then log(hdy) end
 if e.ground then
  if e.fall then
   e.vy=0
   e.fall=false
   if e.mt==4 then
    h=hcl(e)
    if h then
     e.flp=sgn(h.x-e.x)
    end
    if not e.mad then
     e.flp=rand(2)*2-1
    end
   end
   
  end
  

  fall=e.mt==4 or (e.mad and hdy>2) 

  --uturn= (not seek or hdy<2) and e.mt!=4
  
  if col(e,e.flp*8,1)==0 and not fall then
   e.flp=-e.flp
  end
  e.vx = e.flp*e.spd
  advf(e)

  -- try jump
  if seek and hdy<-2 and rand(2)==0 then
   px=flr(e.x/8)
   py=flr(e.y/8) 
   ok=false
   for i=1,2 do
    fr=lget(px,(py-i)%15)
    if fget(fr,1) then
     ok=true
    end
   end
   if ok then
    e.bhv=mon_jmp
    e.t=0
    e.vx=0
    e.fr=64+e.mt
   end  
  end 
  
  -- try shoot
  scd=e.bad and e.shoot_cd or 8
  if e.t>scd and e.test_shoot and rand(4)==0 then
   h=hcl(e)
   if e.test_shoot(h) then
    e.t=0
    e.shoot(e,h)
   end
  end
  
 else
  -- fall
  e.vx=0
  e.vy=2
  e.fall=true
 end 
end

function shoot(e,h)
 e.trg=h
 e.flp=sgn(h.x-e.x)
 e.bhv=mon_fire 
 e.vx=0  
 e.fr=96+e.mt
end

function dash(e,h)
 sfx(63)

 local an=flr(sgda(h,e)*4+0.5)/4
 still(e) 
 e.cgh=36
 local f=function(sh)
  dl(24,function() init_mon(e) end)
  shk=8
  sfx(62)
  e.bhv=nil
  e.fr=74
  still(e)
  e.bncy=nf
 end 

 local acc=0.2
 local spd=0
 e.bhv=function()
  spd+=acc
  impulse(e,an,spd)
  if not e.cgh then   
   spd*=0.85
   acc=0
			if spd<0.1 then
			 init_mon(e)
			end
  end
 end
 e.bncx=f
 e.bncy=f 
end

function hcl(e) 
 best=nil
 bdist=999
 for h in all(heroes) do
  dd=dst(h,e)
  if dd<bdist and h.act then
   best=h
   bdist=dd
  end
 end
 if not best then
  return heroes[1]
 end
 return best
end

function dst(a,b)
 local dx=a.x-b.x
 local dy=a.y-b.y
	return sqrt(dx*dx+dy*dy)
end

function mon_fire(e)
 
 if e.t==12 then 
  
  e.fr=112+e.mt
  local b=badshot(104,e)
  b.turn=1

  
  if e.mt==3 then
   e.rmpo={9,0}
   b.lp=false
   b.rmp=e.rmp
   b.fr=119  
   b.raymod=2
   an=sgda(e.trg,b)
   impulse(b,an,b.mad and 5 or 3)
   b.frict=0.95
   local spd=0
   b.upd=function()
    if b.t%4==0 then
     sfx(50)
    end
    if e.dead then
     b.frict=1.05
    elseif b.t>24 then
     spd+=0.15
     an=sgda(e,b)
     impulse(b,an,spd)
     if dst(e,b)<4 then
      sfx(49)
      kill(b)
      e.rmpo=nil     
     end
    end
   end
  else
   b.vx=e.flp*2
   b.phys=true  
   sfx(44)
  end
 end
 
 if e.t==20 then
  e.bhv=crawl
 end 
 
end


function sgda(a,b)
 local dx=a.x-b.x
 local dy=a.y-b.y
 return atan2(dx,dy)
end

function mon_jmp(e)

 lim=e.mad and 6 or 32
 if e.t<lim then
  e.flp =(flr(e.t/8)%2)*2-1
 elseif e.we==0 then
  e.fr=80+e.mt
  e.vy=-3.6
  e.we=0.25
  e.bncy=function(e)
   still(e)
   e.bhv=crawl
  end
 end
end

function hit(e,n,sd) 
 e.flh=7
 tt=2
 e.dmg+=n
 if e.dmg>=e.res then
  stun(e,sd)
 else
  sfx(36)
 end 
end

function stun(e,sd)
 sfx(37)
 e.stuncd=sd
 e.vx=0 
 e.fr=64+e.mt
 e.we=0.25
 e.bncy=function(e) e.vy=0 end
end



function upd_hero(h)
 
 if boss and boss.stp==0 then return end

 -- walking
 h.vx=0
 function walk(n)
  h.flp=n
  h.vx=n*1.5
 end  
 
 if btn(0,h.hid) then walk(-1) end
 if btn(1,h.hid) then walk(1) end
 
 -- jumping / anim
 if h.ground then 
  if btnp(4,h.hid) then
   sfx(35)
   h.vy=-7.5
   if btn(3,h.hid) then
    h.vy=2
    h.cgh=1
   end
  end
  h.fr=34
  if t%8<4 and h.vx!=0 then 
   h.fr=35 
  end
  if h.cdb then
   h.fr=38
   if h.cdb>2 then
    h.fr=39
   end   
  end
  
 else
  h.fr=35 
  if h.vy > 1 then
   h.fr=37
  end
  if h.vy < -1 then
   h.fr=36
  end  
 end

 -- autograb
 m=moncol(h)
 if m and m.stun and not h.lift then
  kill(m)
  h.lift=m
  sfx(38)
 end
 -- shooting / grab / drop
	if btn(5,h.hid) then
	 
	 if h.lift then	 
	  if h.ground and btn(3,h.hid) then
	   drop(h)   
	  else
	   launch(h)
	  end
	 --elseif #balls<h.ball0+3 then
  elseif not h.cdb then
   shoot_ball(h)
  end
 end
 
 -- invincible 
 h.vis=not h.cinv or h.cinv%2==1   
 
 -- special
 if h.special then
  if h.special==0 and t%4==0 and h.ground and h.vx!=0 then
   sfx(55)
   e=mke(-1,h.x,h.y)
   e.life=64
   e.t=rand(8)
   e.killmon=true   
   local flp=rand(2)==0
   e.draw=function(e,x,y)
    fr=flr(e.t/2)%4
    hh=min(e.t,min(8,e.life))
    sspr(fr*4,96,4,8,x+2,y+8-hh,4,hh,flp)
   end
  end
  if h.special==1 and t%2==0 then
   h.flh=8+flr(t/8)%8
   p=spop(h,4)
   p.lp=true
   p.vx=h.vx*rnd(0.5)
   p.vy=max(h.vy,-1.5)*rnd(0.5)
   p.blid=mod(2,4)
  end  
 end
end

function drop(h)
 e=h.lift
 h.lift=nil
 add(monsters,e)
 add(ents,e)
 e.x=h.x+h.flp*8
 e.y=h.y	   
end

function die(h)
 kill(h)
 if h.lift then
  drop(h)
 end
 
 sfx(43)
 e=mke(40,h.x,h.y)
 e.size=7
 e.we=1
 e.phys=true
 e.vy=-5
 e.flp=h.flp
 e.bncy=function(e) 
  e.vy*=-0.75 
  if e.t>20 then 
   e.we=0
   e.vy=0
  end
 end
 e.life=40
 e.blink=12   
 if lives>0 then
  lives-=1
  life_lost=30
  e.ondeath=function()
   spawn_hero(h)
   h.cinv=64
  end
 else
  h.act=false
  act-=1 	
 end
 
 shk=6
 flash_bg=0
 tt=3 
 for i=0,15 do
  --e=mke(74,h.x,h.y)
  e=mka(h.x,h.y,40,12,4,4,4,2+rand(4))
  impulse(e,(i+rnd())/15,4)
  e.frict=0.75+rnd(0.15)
  e.blid=h.hid
  e.phys=true
  e.we=0.1
  e.size=0.5
  
  e.bncy=function(e) e.vy*=-0.75 end
 end
 
end

function gameover()
 pal()
 t=0
 mdraw=function()
  rectfill(0,0,127,127,0)
  print("game over",46,62,sget(-sin(t/192)*7,1))
  if t==96 then
   init_menu()
  end
 end
 rectfill(0,0,127,127,0)
 

end


function shoot_ball(h)

 h.cdb=10/h.ball4
 sfx(34)
 
 
 for e in all(ents) do
  if e.blid==blid then
   kill(e)
  end
 end
 
 pw=h.ball3>blid+1 and 2 or 1

 --pw=h.ball3
 b=mke(4+pw,h.x,h.y)
 b.pow=pw
 b.raymod=-2
 b.vx=h.flp*(0.5+h.ball2/2)
 b.vy=-2.3
 b.we=0.25 
 b.phys=true
 b.size=3+pw
 b.life=h.ball1*60
 b.blid=blid
 blid=(blid+1)%(3+h.ball0)
 b.bncx=function(b) 
  sfx(32)
 end
 b.bncy=function(b)
  b.vy=max(b.vy,-2.5)
  sfx(32)
 end 
 
 b.upd=function(b)
  for e in all(ents) do
   if e.hit and ecol(e,b) then
    e.hit(e,b.pow,160*h.ball5)
    an=sgda(e,b)
    e.bvx=cos(an)*1
    e.bvy=sin(an)*1
    kill(b)
   end
  end
 end 
 b.ondeath=function(b)
  sfx(33)
  mke(32,b.x,b.y)
 end
 add(balls,b)
end


function fadeto(nxt,rev)
 fade_rev=rev
 fade_nxt=nxt
 fade_n=0
end

function mkb(mt,from)
 local e=mke(64+mt,from.x,from.y)
 e.mt=mt
 e.rmp=1
 e.obj=true
 e.phys=true
 e.proj=true
 e.vx=8
 e.lvb=lvb
 lvb+=1
 bnum+=1
 e.ondeath=function()bnum-=1 end
 e.bncx=function(e)
  sfx(41)
  if e.proj then
   xpl(e)
   sfx(56)
   shk=4  
  end
 end 
 
 local lim=32+rnd(48)
 e.bncy=function(e)
  sfx(41)
  if e.ground then
   e.t+=2
   if e.t>lim and not e.proj then
    b=mkbonus(48+e.lvb,e)
    kill(e)
   end
  end
 end  
 
 e.rot=0
 e.turn=1
 e.upd=function(e)  
  m=moncol(e)
  if e.t>40 then 
	 	xpl(e)
   e.vy=0
  elseif m and not e.cdt then
   e.vx*=-1
   e.cdt=4
   b=m.xpl(e)
   if b then
    b.vx=-e.vx
   end
  end
 end
 return e
end
 
function xpl(e)
 --

 if e.proj then
  add_score(heroes[1],bounty[e.mt+1],e.x,e.y)
  e.t=0
  e.proj=false
  e.lp=true
  e.vy=-8
  e.upd=nil
  e.frict=0.97
  e.we=0.25  
 end
end

function launch(h)
 sfx(39)
 e=mkb(h.lift.mt,h) 
 e.vx=h.flp*8
 h.lift=nil
end



function mkbonus(fr,p)
 sfx(48)
 e=mke(fr,p.x,p.y)
 e.obj=true
 e.van=vanish 
 e.dp=0
 e.vy=-2
 e.we=0.25
 e.phys=true 
 
 local let
 if fr==4 then
  let=rand(#alph)
 end 
 e.upd=function(e)
  local h=herocol(e)  
  if h then
   if let then
    sfx(42)
    add_let(let)
   elseif fget(fr,6) then
    nsfx=42
    add_score(h,50*(fr-47),e.x,e.y)
   else
    apply_effect(fr,h)
   end
   kill(e)
  end  
 end
 e.life=240
 e.blink=60
 
 if let then
  e.draw=function(e,x,y)
   for i=0,1 do
    print(glet(let),x+3-i,y+2-i,1+6*i)
    bt=e.t%40
    if bt<4 then
   	 spr(7+bt,x,y)
   	end
   end
  end
  e.hit=function(e)
  	sfx(45)
   let=(let+1)%#alph
   e.t=0
  end  
 end
 return e 
end

function nuke()
 for m in all(monsters) do
  m.xpl()
 end
end

function apply_effect(fr,h)
   
 
 -- rod
 if fr==56 then
  sfx(53)
  music(30)
  flash_bg=0
  tt=7
		nuke()
 end
 
 --- earrings
 if fr==57 then
  for i=0,1 do
   b=mke(47,0,0)
   b.killmon=true
   b.rmp=0
   b.upd=function(b)
    an=i/2+t/40
    b.x=h.x+cos(an)*16
    b.y=h.y+sin(an)*16
    burning(b)
   end
  end
  --h.powerballs=3
 end
 
 -- match
 if fr==58 then
  h.special=0
 end
 
 -- gong
 if fr==59 then
  sfx(40)
 	for m in all(monsters) do
 	 m.dmg=m.res
 	 stun(m,160)
 	 m.vy=-2
 	 shk=8
 	end
 end
 
 -- all potion
 if fr>=228 then
  sfx(29)
  s="ball"..(fr-228)
  h[s]=h[s]+1
 end
 
 -- key
 if fr==127 then
  jump_lvl=22
  leave()
  music(17)
 end

 -- bomb
 if fr==60 then
  sfx(44)
  shk=32
  for i=0,3 do
   e=mke(104,h.x,h.y)
   impulse(e,i/4+0.12,3)
		 e.phys=true
		 e.bncx=nf
		 e.bncy=nf
		 e.killmon=true
		 e.upd=burning
		 e.cgh=512
		 e.turn=1
		end
 end

 -- bell
 if fr==61 then
  for i=0,11 do
   local p=steal(ggpos)
   local bf=big_fruit
   dl(i*4,function() mkbonus(bf,p) end)
  end   
		big_fruit+=1
 end
 
 -- necklace
 if fr==62 then
 	music(31)
 	h.special=1 
 end
 
 -- cornucopia
 if fr==63 then
  sfx(57)
 	cornucopia=48 
 	corn()
 end
 
end


function add_let(n)
 for l in all(letters) do
  if not l.act and glet(n)==l.let then
   l.act=true
   break
  end
 end
 
 for i=0,1 do
  ok=true
  for k=1,6 do
   ok=ok and letters[i*6+k].act
  end
  if ok then   
   success=i
   
   dl(80,function() success=nil end)
   for k=1,6 do 
    letters[i*6+k].act=false
   end 
   if i==0 then
    extra_life()
   else
    jump_lvl=5
   end
   nuke()
   music(-1)
  end  
 end
end

function dl(t,f,l)
 e=mke(-1,0,0)
 e.life=t
 e.ondeath=f
 e.upd=l
end

function glet(n)
 return sub(alph,n+1,n+1)
end

function extra_life()
 lives+=1
 nsfx=10
 flash_bg=2
 tt=7 
end

function add_score(h,sc,x,y)
 h.score+=sc
 if #xtra>0 and h.score>=xtra[1] then
  del(xtra,xtra[1])
  extra_life()
 end
 
 e=mke(-1,x,y-4)
 e.vy=-0.25
 e.life=24
 e.dp=0
 local s=sc..""
 e.draw=function(e,x,y)
  for i=0,1 do
   cl=1
   if i==1 then
    cl=t%4<2 and 7 or 12
   end
   print(s,x+4-#s*2-i,y+2-i,cl)
  end
 end
 
end

function rand(n)
 return flr(rnd(n))
end



function ecol(a,b)
 dx=a.x-b.x
 dy=a.y-b.y
 if a.lp and b.lp then
  dx=mdx(a.x-b.x,60)
  dy=mdy(a.y-b.y,54)
 end
 dx=abs(dx)+a.raymod+b.raymod
 dy=abs(dy)+a.raymod+b.raymod
 local l=(a.size+b.size)/2
 return dx<l and dy<l
end

function moncol(e)
 for m in all(monsters) do
  if ecol(m,e) and m.hit then
		 return m
  end
 end
 return nil
end

function herocol(e)
 for h in all(heroes) do
  if h.act and ecol(h,e) and not h.dead then
		 return h
  end
 end
 return nil
end

function tw(e,tx,ty,n,twj,nxt)
 e.sx=e.x
 e.sy=e.y
 e.tx=tx
 e.ty=ty
 e.twc=0
 e.twj=twj
 e.spc=1/n
 if n<0 then
  local dx=tx-e.x
  local dy=ty-e.y
  local dd=sqrt(dx*dx+dy*dy)
  if twj then dd+=twj*1.4 end
  e.spc=-n/dd
 end
 e.twnxt=nxt
end






function mke(fr,x,y)
 fr=fr and fr or -1
 x=x and x or 0
 y=y and y or 0
 
 e={
  fr=fr,x=x,y=y,t=0,size=8,
  frict=1.0,
  flp=1, lp=true, vis=true,
  raymod=0,ofy=0,dp=1,
  bncx=function(e) e.vx=0 end,
  bncy=function(e) e.vy=0 end,
  van=kill,
 }
 still(e)
 add(ents,e)
 return e
end

function upe(e)
 e.t+=1
 e.ox=e.x
 e.oy=e.y
 
 -- counters
 for v,n in pairs(e) do
  if sub(v,1,1)=="c" then
   n-=1
   if n<=0 then
    e[v]=nil
   else
    e[v]=n
   end
  end
 end

 if e.upd then e.upd(e) end
 if e.obj or e.lift then objs+=1 end
 if e.turn and t%2==0 and not e.stun then
  e.rot=e.rot or 0
  e.rot=(e.rot+e.turn)%4 
 end
 e.vy+=e.we
 e.vx*=e.frict
 e.vy*=e.frict

 --and not col(e)

 local c=e.mad and 2 or 1
 local vvx=e.vx*c
 if e.bhv!=fly then c=1 end
 local vvy=e.vy*c

 if e.bvx then
  vvx+=e.bvx
  vvy+=e.bvy
  e.bvx*=0.85
  e.bvy*=0.85
 end
 
 if e.cfocus then
  vvx=0
  vvy=0
 end

	if e.phys  then
	
	 -- horizontal
	 e.x+=vvx
	 sx=sgn(vvx)	 
	 if col(e)==2 then	  
	  while col(e)==2 do
	   e.x-=sx	  
	  end
	  e.vx*=-1	
	  e.bncx(e) 
	 end 
	 
	 -- vertical
	 pcol=col(e)
	 e.y+=vvy
	 sy=sgn(vvy)
	 function hcol(e)
	  local n=col(e)
	  if n==1 and e.cgh then 
	   n=0 
	  end
	  return n==2 or (n==1 and sy>0 and pcol==0)
	 end	 
	 if hcol(e)  then	  
	  while hcol(e) do
	   e.y-=sy
	  end
	  majground(e)
			e.vy*=-1
			e.bncy(e) 
	 end
	 
	 -- ground test
  majground(e)
	else
	 e.x+=vvx
	 e.y+=vvy
	end
	
	-- tween
 if e.twc then
  tx=e.twt and e.twt.x or e.tx
  ty=e.twt and e.twt.y or e.ty
  e.twc=min(e.twc+e.spc,1)
  c=0.5-cos(e.twc*0.5)*0.5
  e.x=e.sx+(tx-e.sx)*c
  e.y=e.sy+(ty-e.sy)*c
  if e.twj then
   e.y+=sin(c*0.5)*e.twj
  end	
  if e.twc==1 then
   e.twc=nil  
   if e.twnxt then e.twnxt() end
  end
 end
 -- life
 if e.life then
  e.life-=1
  if e.blink and e.life < e.blink then
   e.vis=t%4<2
  end
  if e.life<=0 then
   e.van(e)
  end
 end
 
 -- bad
 if e.bad and not e.stun then
  h=herocol(e)
  if h and not h.cinv then
   if e.shot then kill(e) end
   if h.special==1 then
    if e.xpl then 
     e.xpl()
    end
   else
    die(h)   
   end
  end
 end 

 
 -- killmon
 if e.killmon then
  for m in all(monsters) do
   if ecol(m,e) then
    m.xpl()
   end
  end
 end
 
	-- mod
	if e.lp then
	 e.x=mdx(e.x)
	 e.y=mdy(e.y)
	else 
	 if out(e) and not e.ores then	  
	  kill(e)
	 end
	end
	
	
end

function vanish(e)
 mke(23,e.x,e.y)
 kill(e)
end

function majground(e)
 e.ground=col(e,0,1)>0 and col(e,0,0)==0
end

function out(e)
 return e.x<-4 or e.y<-4 or e.x>132 or e.y>132
end

function kill(e)
 e.dead=true
 del(ents,e)
 del(balls,e)
 del(monsters,e)
 if e.ondeath then 
  e.ondeath(e) 
 end
 

end

function mdx(n,k)
 k=k or 0
 n+=k
 return (n%120)-k
end
function mdy(n,k)
 k=k or 0
 n+=k
 return (n%112)-k
end


function col(e,dx,dy)
 dx=dx or 0
 dy=dy or 0
	local x=mdx(e.x+dx-e.size/2)
	local y=mdy(e.y+dy-e.size/2)
	local ex=mdx(x+e.size-1)
	local ey=mdy(y+e.size-1)
 a={x,y,ex,y,ex,ey,x,ey}
 
 n=0
 for i=0,3 do
  x=a[i*2+1]/8
  y=a[i*2+2]/8
  local fr=lget(flr(x),flr(y))
  if n==0 and fget(fr,1) then
   n=1
  end
  if fget(fr,0) then 
   return 2
  end  
 end 
 return n
 
end

function dre(e)
 if not e.vis or e.dp!=dp then return end
	fr=e.fr
	x=e.x-e.size/2
	y=e.y+e.ofy-e.size/2
	
	
	--[[ focus circ ( need more tokens )
	if e.cfocus then
	 circ(e.x,e.y,e.cfocus,7)
	end
	--]]
	
	-- frame flag
	if fget(fr,0) then
	 y-=1
	end	
	if fget(fr,3) and e.t%4>2 then
	 fr+=1
		if fget(fr,2) then
		 kill(e)
		 return
		end	
		if fget(fr,1) then
			while not fget(fr-1,5) do
			 fr-=1
			end
		end	
	end
	e.fr=fr
	
	-- remap ball
	if e.blid then
	 pal(12,sget(16+e.blid,12))
	end
	-- remap
	if e.rmp then
	 for i=0,15 do
	  pal(i,sget(8+i,e.rmp))
	 end
	end
	if e.rmpo then
	 pal(e.rmpo[1],e.rmpo[2])
	end
	
	-- flh
	if e.flh then
	 for i=0,15 do
	  pal(i,e.flh)
  end
  if not tt then 
   e.flh=nil
  end
	end
	
	--
	if e.rainbow then
	 e.rainbow-=1
	 for i=0,15 do
	  pal(i,8+rand(8))
  end
	 if e.rainbow==0 then
	  e.rainbow=nil
	 end
	end
	
	--
	if e.stunshk then x+=1 end
	
	-- draw
	function dr(x,y) 
	 if e.lift then
   spr(64+e.lift.mt,x,y-6,1,1,e.flp==-1,-1)	
 	end
 	if e.rot then
   for gx=0,7 do for gy=0,7 do
	   px=(fr%16)*8
	   py=flr(fr/16)*8	 
	   p=sget(px+gx,py+gy)
	   if p>0 then
	    dx=gx
	    dy=gy	 
     for i=1,e.rot do
      dx,dy=7-dy,dx
     end
     pset(x+dx,y+dy,p)
    end
	  end	end
 	else
	  spr(fr,x,y,e.size/8,e.size/8,e.flp==-1)
	 end
	 if e.draw then e.draw(e,x,y) end
	end
 dr(x,y) 
 if e.lp then
  if x<8 then dr(x+120,y) end
  if x>120-e.size then dr(x-120,y) end
  if y<8 then dr(x,y+112) end
  if y>112-e.size then dr(x,y-112) end
 end
 
 pal()
 
end



function upd_lvl()


 -- ents
 if bnum==0 then lvb=0 end
	objs=0
 foreach(ents,upe)
 
 -- check gameover
 if act==0 then
  act=-1
  music(32)
  function f()
   loop=nil
   fadeto(gameover,true)
  end  
  dl(40,f) 
 end
 
 --
 if boss or congrats then return end
 
 if objs==0 and not clean then
  finish_lvl()
 end

 -- new player
 h2=heroes[2]
 if lives>0 and btnp(5,1) and not h2.act then
  lives-=1
  h2.act=true
  act+=1  
  spawn_hero(h2)
 end

 -- timer
 run_timer() 

end

function still(e)
 e.we=0
 e.vy=0
 e.vx=0
end

function finish_lvl()

 clean=true
 music(7)
 local kn=0
 for h in all(heroes) do
  if h.act then 
   kn+=1
   h.t=0
   still(h)
   h.lp=false
   h.phys=false
  
   local px=h.x
   local py=h.y
  
   h.upd=function()
    f=mod(2,8)
    h.fr=42+abs(4-f)
    h.flp=-sgn(4-f)
    h.x=px
    if h.flp==-1 then 
     h.x-=1 
    end
    h.y=py
    py+=h.t*0.1-1.5
    h.ondeath=function()
     kn-=1
     if kn==0 then
      leave()
     end
    end
    if t%2==0 and h.vis then
     p=spop(h,2)
     p.we=-rnd(0.2)
    end
   end
   
  end
 end
end

function leave()
 ents={}
 monsters={}
 nxl=0
 loop=nil
 goto_level(lvl+1)
end

function spop(h,spd)
 return mka(h.x+rnd(8)-4,h.y+rnd(8)-4,40,5,3,3,5,spd)
end

function mka(x,y,dx,dy,dw,dh,fmax,spd)
 local e=mke(-1,x,y)
 e.lp=false
 e.size=dw
 e.draw=function(e,x,y)
  f=flr(e.t/spd)
  if f>=fmax then 
   kill(e) 
  else
   sspr(dx+dw*f,dy,dw,dh,x,y)
  end
 end
	return e
end


function _update()
  
 t+=1
 if tt then
  tt-=1
  if tt==0 then
   tt=nil
   flash_bg=nil
  end
 end
 if loop then
  loop() 
 end
 if nsfx then
  sfx(nsfx)
  nsfx=nil
 end
end


function spawn_item(it)
 p=steal(bop)
 if p==nil then return end
 b=mkbonus(it,p)
 b.life=320
end

function run_timer()
 lt+=1
 if gms()==0 then return end
  
 if #items>0 and rand(flr((time_limit-lt)/2))==0 then 
  spawn_item(steal(items))
 end
 
 if lt==time_limit then
  for m in all(monsters) do
   gomad(m)
  end
  local e=mke(-1,52,66)
  e.vy=-0.25
  e.draw=function(e,x,y)
   print("hurry up",x,y,7+(t%2))
  end
  e.life=44
  sfx(47)
  music(5)
 end
 if lt==time_limit+200 then
  sfx(51)
  mkm(5,64,64)
 end
end


function steal(a)
 local p=a[rand(#a)+1]
 del(a,p)
 return p
end


function drmap(lvl,dy)
 local bx=flr(lvl%8)*16
 local by=flr(lvl/8)*16
 map(bx,by,0,dy,15,14) 
 map(bx,by,120,dy,1,14)
 map(bx,by,0,112+dy,15,1)
 map(bx,by,120,112+dy,1,1)
end

function draw_lvl()

 
 -- boss
 if boss and boss.stp>0 then
  for i=0,2 do
  	spr(boss.hp>i and 242 or 243,50+i*9,118)
  end 
 end
 
 -- shake
 ddx=0
 if shk then
  shk=-shk
  shk*=0.75
  if abs(shk)<1 then
   shk=nil
  end
  ddx=shk
 end 
 camera(ddx,-8)
 
 if flash_bg then  
  rectfill(0,0,128,120,sget(tt+flash_bg-1,flash_bg))
 end
 
 
 -- next level
 if nxl then
  nxl+= (jump_lvl or 2)
  drmap(lvl-1,-nxl)
  drmap(lvl,120-nxl)
  if nxl>=120 then
   if jump_lvl and lvl<21 then
    jump_lvl-=1
    if jump_lvl==0 then
     jump_lvl=nil
    end
    leave()
    
   else
    nxl=nil
    init_level() 
   end

  end
 else
  drmap(lvl,0)

  for i=0,2 do
   dp=i
   foreach(ents,dre)
  end
 end

 -- inter
 camera()
 rectfill(0,0,127,7,0)
 
 for i=0,1 do
  h=heroes[i+1]  
  sc=h.score..""
  if not h.act and lives>0 then
   str="    press<a> to join   "
   index=flr(t/8)%#str
   str=str..str
   sc=sub(str,index,index+5)
  end
    
  while #sc<5 do sc="0"..sc end
  print(sc,108*i,1,7)
  
  if not congrats then
   px=23  
   for k=1,12 do
    l=letters[k]
    cl=1
    if l.act then 
     cl=t%24==k and 7 or 12
    end
		 	if success==flr((k-1)/6)then
		 	 cl=8+(t+k)%8
		 	end
    print(l.let,px,1,cl )
    px+=4
    if k==6 then
     px+=36
    end
   end
   lmax=min(lives,5)
   for l=0,lmax-1 do
    sspr(32,96,5,5, 64+l*6-(lmax*3) ,1)
   end
  end
  
 end

 -- congrats
 if congrats then
  str="congratulations"
  am=3+cos(t%80/80)*2
  for i=1,#str do
   print( sub(str,i,i), 32+i*4, 6+cos((t+i)%16/16)*am, 8+i%8)
  end  
 end
 
end

function _draw()
 cls()
 if mdraw then mdraw() end
 --draw_lvl()
 
 -- fade
 if fade_n then

  fade_n+=1
  n=fade_rev and fade_n or 15-fade_n
  for i=0,15 do
   pal(i,sget(8+i,4+flr(n/4)),1) 
  end
  --log(4+flr(n/4))
  if fade_n==15 then
   fade_nxt()
   fade_n=nil
   if fade_rev then
    fadeto(pal,false)
   end
  end 

 end  
 
 --[[ log 
 cursor(0,0)
 color(8+(t%8)) 
 color(8) 
 for l in all(logs) do
  print(l)
 end 
 --]]
end

--[[
function log(str)
 add(logs,str)
 while #logs>20 do
  del(logs,logs[1])
 end
end
--]]