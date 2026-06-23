--wizardish
--by eduardolicious

cartdata("wizardish")
high=dget(00)
floor={}
floornum=0
startx=3
starty=3
endx=7
endy=2
posx=startx
posy=starty
dirdraw=2
facing="s"
message1a="-you see a"
message1b="ladder that"
message1c="leads up."
message2a=" "
message2b=" "
message2c=" "
message3a=" "
message3b=" "
message3c=" "
steps=0
totalsteps=0
potions=3
gold=0
sclock=0
mclock=0
hclock=0
justclimbed=0
scroll=390
animloop=0
palette=0

function _init()
 sfx(10)
 titleinit()
end

function titleinit()
 mode=0
end

function gameinit()
 mode=1
 buildmap()
end

function chargeninit()
 mode=3
end

function confirminit()
 mode=4
end

function gameoverinit()
 mode=5
end

function endinginit()
 mode=6
end

function buildmap()
 for x=-2,17 do
 floor[x]={}
  for y=0,15 do
   floor[x][y]=sget((floornum*16)+x,y+8)
   sset(110+x,64+y,15)
  end
 end
palette=flr(rnd(12))
if palette==1 then
 pal1=13
 pal2=12
elseif palette==2 then
 pal1=1
 pal2=13
elseif palette==3 then
 pal1=2
 pal2=14
elseif palette==4 then
 pal1=2
 pal2=8
elseif palette==5 then
 pal1=5
 pal2=6
elseif palette==6 then
 pal1=6
 pal2=7
elseif palette==7 then
 pal1=9
 pal2=15
elseif palette==8 then
 pal1=9
 pal2=10
elseif palette==9 then
 pal1=4
 pal2=15
else
 pal1=3
 pal2=11
end
pal(3,pal1)
pal(11,pal2)
end

function move()
if btnp(0) and floor[posx][posy]!=5 then
 dirdraw-=1
end
if dirdraw<0 then
 dirdraw=3
end
if btnp(1) and floor[posx][posy]!=5 then
 dirdraw+=1
end
if dirdraw>3 then
 dirdraw=0
end
if btnp(2) and floor[posx][posy]!=5 then
 if dirdraw==0 and floor[posx][posy-1]!=0 then
  posy-=1
 elseif dirdraw==1 and floor[posx+1][posy]!=0 then
  posx+=1
 elseif dirdraw==2 and floor[posx][posy+1]!=0 then
  posy+=1
 elseif dirdraw==3 and floor[posx-1][posy]!=0 then
  posx-=1
 end
messages()
end
if btnp(4) and potions>=1 then
 use_potion()
end
if btnp(5) and floor[posx][posy]==2 and justclimbed==0 then
 go_up()
end
if btnp(5) and floor[posx][posy]==3 and justclimbed==0 then
 go_down()
end
if btnp(5) and floor[posx][posy]==4 then
 open_chest()
end
if btnp(5) and floor[posx][posy]==5 then
 attack()
end
 sset((112+posx),(posy+64),0)
end

function attack()
 rotatemessages()
 message1a="-you attack"
 message1b="the monster"
 hitchance=flr(rnd(6))
 if hitchance<=1 then
  sfx(12)
  message1c="but miss!"
 else
  sfx(11)
  message1c="and hit it!"
  enemy.health-=flr((str/2)+(flr(rnd(str/2))))+1
 end
 if enemy.health<=0 then
  enemy.health=0
  kill()
 else
  gamedraw()
  if btnp(5,1) then
  for delay=1,3000 do
   drawenemy()
  end
  end
  enemyattack()
 end
end

function kill()
 gamedraw()
 if btnp(5,1) then
 for delay=1,3000 do
   drawenemy()
 end
 end
 sfx(13)
 rotatemessages()
 message1a="-you have"
 message1b="defeated the"
 message1c="monster!"
 gold+=flr(rnd(10))
 floor[posx][posy]=1
 sset(((floornum*16)+posx),(posy+8),1)
end

function enemyattack()
 rotatemessages()
 for delay=1,30 do
 if btn(5,1) then
  line(0,0,0,60,7)
  flip()
 else
  if btnp(3) then
  drawenemy()
  end
  flip()
 end
 end
 message1a="-the monster"
 message1b="attacks you"
 misschance=flr(rnd(6))
 if misschance<=1 or (character=="ranger" and misschance<=2) then
  sfx(12)
  message1c="but misses!"
 else
  message1c="and hits!"
  for delay=1,7 do
  line(20,20,delay*4+20,delay*4+20,8)
  line(25,15,delay*4+25,delay*4+15,8)
  line(15,25,delay*4+15,delay*4+25,8)
  flip()
  end
  if hp<10 then
   print("0",61,79,8)
   print(hp,65,79,8)
  else
   print(hp,61,79,8)
  end
  sfx(11)
  damage=flr((enemy.attack/3)+(flr(rnd(enemy.attack/2))))-(dex/5)
  if damage <=0 then
   hp-=1
  else
   hp-=damage
  end
 end
end

function use_potion()
 sfx(16)
 potions-=1
 rotatemessages()
 message1a="-you drink"
 message1b="a health"
 message1c="potion."
  for delay=1,30000 do
  if hp<10 then
   print("0",61,79,12)
   print(hp,65,79,12)
  else
   print(hp,61,79,12)
  end
  end
 hp+=10
 if character=="cleric" then
  rotatemessages()
  message1a="-the gods"
  message1b="bless your"
  message1c="potion!"
  hp+=(flr(rnd(4))+1)
 end
 if hp>hpmax then
  hp=hpmax
 end
end

function go_down()
 sfx(14)
 floornum+=1
 if floornum>7 then
  mode=6
 else
 rotatemessages()
 message1a="-you climb"
 message1b="down to the"
 message1c="next floor."
 justclimbed=1
 pal()
 buildmap()
 end
end

function go_up()
  rotatemessages()
  message1a="-you can't"
  message1b="escape back"
  message1c="that way!"
end

function open_chest()
 local trapchance=rnd(100)
 if character=="ranger" then
  if trapchance<=25 then
   rotatemessages()
   message1a="-you find"
   message1b="and disarm"
   message1c="a trap!"
   sfx(12)
   for delay=1,15 do
    flip()
   end
   gamedraw()
   for delay=1,10 do
    flip()
   end
  end
  trapchance=100
 end
 rotatemessages()
 if trapchance<=25 then
  sfx(11)
  message1a="-you just"
  message1b="triggered a"
  message1c="trap!"
  for delay=1,10 do
  print("*",31,40,8)
  flip()
  end
   gamedraw()
   for delay=1,10 do
    flip()
   end
  print("*",31,40,0)
  hp-=(flr(rnd(7)))+1
  rotatemessages()
 end
 sfx(13)
  for delay=1,15 do
  print("*",27,28,10)
  spr(6,32,32)
  flip()
  end
 local loot=rnd(3)
 if loot<=1 and potions <=9 then
  message1a="-you find"
  message1b="a potion in"
  message1c="the chest."
  potions+=1
 else
 message1a="-you find"
 message1b="some gold in"
 message1c="the chest."
 gold+=((flr(rnd(10)))+10)
 end
 floor[posx][posy]=1
 sset(((floornum*16)+posx),(posy+8),1)
end

function drawwalls()
if dirdraw==0 then
 if floor[posx][posy-1]==0 then
  drawfrontwall()
  if floor[posx-1][posy-1]!=0 then
   drawfakeleft()
  end
  if floor[posx+1][posy-1]!=0 then
   drawfakeright()
  end
 else
 if floor[posx-1][posy-1]==0 then
  drawupleftwall()
 else
  drawupleftblank()
 end
 if floor[posx+1][posy-1]==0 then
  drawuprightwall()
 else
  drawuprightblank()
 end
 end
 if floor[posx-1][posy]==0 then
  drawleftwall()
 elseif floor[posx-1][posy-1]==0 then
  drawleftblank()
 end
 if floor[posx+1][posy]==0 then
  drawrightwall()
 elseif floor[posx+1][posy-1]==0 then
  drawrightblank()
 end 
 if floor[posx][posy-3]==0 and floor[posx][posy-2]!=0 and floor[posx][posy-1]!=0 then
  draw2frontwall()
 end
 if floor[posx][posy-2]==0 and floor[posx][posy-1]!=0 then
  drawupfrontwall()
 elseif floor[posx][posy-1]!=0 then
 if floor[posx-1][posy-2]==0 then
  draw2leftwall()
 end
 if floor[posx+1][posy-2]==0 then
  draw2rightwall()
 end
 end
elseif dirdraw==1 then
 if floor[posx+1][posy]==0 then
  drawfrontwall()
  if floor[posx+1][posy-1]!=0 then
   drawfakeleft()
  end
  if floor[posx+1][posy+1]!=0 then
   drawfakeright()
  end
 else
 if floor[posx+1][posy-1]==0 then
  drawupleftwall()
 else
  drawupleftblank()
 end
 if floor[posx+1][posy+1]==0 then
  drawuprightwall()
 else
  drawuprightblank()
 end
 end
 if floor[posx][posy-1]==0 then
  drawleftwall()
 elseif floor[posx+1][posy-1]==0 then
  drawleftblank()
 end
 if floor[posx][posy+1]==0 then
  drawrightwall()
 elseif floor[posx+1][posy+1]==0 then
  drawrightblank()
 end
 if floor[posx+3][posy]==0 and floor[posx+2][posy]!=0 and floor[posx+1][posy]!=0 then
  draw2frontwall()
 end
 if floor[posx+2][posy]==0 and floor[posx+1][posy]!=0 then
  drawupfrontwall()
 elseif floor[posx+1][posy]!=0 then
 if floor[posx+2][posy-1]==0 then
  draw2leftwall()
 end
 if floor[posx+2][posy+1]==0 then
  draw2rightwall()
 end
 end
elseif dirdraw==2 then
 if floor[posx][posy+1]==0 then
  drawfrontwall()
  if floor[posx+1][posy+1]!=0 then
   drawfakeleft()
  end
  if floor[posx-1][posy+1]!=0 then
   drawfakeright()
  end
 else
 if floor[posx+1][posy+1]==0 then
  drawupleftwall()
 else
  drawupleftblank()
 end
 if floor[posx-1][posy+1]==0 then
  drawuprightwall()
 else
  drawuprightblank()
 end
 end
 if floor[posx+1][posy]==0 then
  drawleftwall()
 elseif floor[posx+1][posy+1]==0 then
  drawleftblank()
 end
 if floor[posx-1][posy]==0 then
  drawrightwall()
 elseif floor[posx-1][posy+1]==0 then
  drawrightblank()
 end
 if floor[posx][posy+3]==0 and floor[posx][posy+2]!=0 and floor[posx][posy+1]!=0 then
  draw2frontwall()
 end
 if floor[posx][posy+2]==0 and floor[posx][posy+1]!=0 then
  drawupfrontwall()
 elseif floor[posx][posy+1]!=0 then
 if floor[posx+1][posy+2]==0 then
  draw2leftwall()
 end
 if floor[posx-1][posy+2]==0 then
  draw2rightwall()
 end
 end
elseif dirdraw==3 then
 if floor[posx-1][posy]==0 then
  drawfrontwall()
  if floor[posx-1][posy+1]!=0 then
   drawfakeleft()
  end
  if floor[posx-1][posy-1]!=0 then
   drawfakeright()
  end
 else
 if floor[posx-1][posy+1]==0 then
  drawupleftwall()
 else
  drawupleftblank()
 end
 if floor[posx-1][posy-1]==0 then
  drawuprightwall()
 else
  drawuprightblank()
 end
 end
 if floor[posx][posy+1]==0 then
  drawleftwall()
 elseif floor[posx-1][posy+1]==0 then
  drawleftblank()
 end
 if floor[posx][posy-1]==0 then
  drawrightwall()
 elseif floor[posx-1][posy-1]==0 then
  drawrightblank()
 end
 if floor[posx-3][posy]==0 and floor[posx-2][posy]!=0 and floor[posx-1][posy]!=0 then
  draw2frontwall()
 end
 if floor[posx-2][posy]==0 and floor[posx-1][posy]!=0 then
  drawupfrontwall()
 elseif floor[posx-1][posy]!=0 then
 if floor[posx-2][posy+1]==0 then
  draw2leftwall()
 end
 if floor[posx-2][posy-1]==0 then
  draw2rightwall()
 end
 end
end
end

function drawfrontwall()
line(10,10,54,10,6)
line(10,10,10,54,6)
line(54,10,54,54,6)
line(10,54,54,54,6)
end

function drawfakeleft()
line(0,22,10,25,6)
line(0,42,10,39,6)
end

function drawfakeright()
line(64,22,54,25,6)
line(64,42,54,39,6)
end

function drawupfrontwall()
line(20,20,20,44,6)
line(44,20,44,44,6)
line(20,20,44,20,6)
line(20,44,44,44,6)
end

function draw2frontwall()
line(28,28,28,36,6)
line(36,28,36,36,6)
line(20,28,44,28,6)
line(20,36,44,36,6)
end

function drawleftwall()
line(0,22,10,25,0)
line(0,42,10,39,0)
line(0,0,10,10,6)
line(0,64,10,54,6)
line(10,10,10,54,6)
end

function drawleftblank()
line(10,10,10,54,6)
line(10,10,0,10,6)
line(10,54,0,54,6)
end

function drawupleftwall()
line(10,10,10,54,6)
line(10,10,20,20,6)
line(10,54,20,44,6)
line(20,20,20,44,6)
end

function draw2leftwall()
line(20,20,20,44,6)
line(20,20,28,28,6)
line(20,44,28,36,6)
line(28,28,28,36,6)
line(21,28,27,28,0)
line(21,36,27,36,0)
end

function drawupleftblank()
line(20,20,20,44,6)
line(20,20,10,20,6)
line(20,44,10,44,6)
end

function drawrightwall()
line(64,22,54,25,0)
line(64,42,54,39,0)
line(64,0,54,10,6)
line(64,64,54,54,6)
line(54,10,54,54,6)
end

function drawrightblank()
line(54,10,54,54,6)
line(54,10,64,10,6)
line(54,54,64,54,6)
end

function drawuprightwall()
line(54,10,54,54,6)
line(54,10,44,20,6)
line(54,54,44,44,6)
line(44,20,44,44,6)
end

function draw2rightwall()
line(44,20,44,44,6)
line(44,20,36,28,6)
line(44,44,36,36,6)
line(36,28,36,36,6)
line(37,28,43,28,0)
line(37,36,43,36,0)
end

function drawuprightblank()
line(44,20,44,44,6)
line(44,20,54,20,6)
line(44,44,54,44,6)
end

function drawprops()
if floor[posx][posy]==2 then
 drawladderup()
elseif floor[posx][posy]==3 then
 drawladderdown()
end
if floor[posx][posy]==4 then
 drawchest()
end
if floor[posx][posy]==5 then
 drawenemy()
end
end

function drawenemy()
 if animloop<10 then
  spr(48,16,27,4,1)
  spr(52,16,35,4,1)
 elseif (animloop>=10 and animloop<20) or (animloop>=40 and animloop<50) then
  spr(240,16,27,4,1)
  spr(244,16,35,4,1) 
 elseif (animloop>=20 and animloop<40) then
  spr(248,16,27,4,1)
  spr(252,16,35,4,1)
 end 
 spr(56,16,43,4,1)
 spr(60,16,51,4,1)
 if enemy.health>0 then
  line((64-enemy.maxhealth)/2,23,((64-enemy.maxhealth)/2)+enemy.health,23,8)
 end
 if enemy.health<enemy.maxhealth then
  line(((64-enemy.maxhealth)/2)+enemy.health+1,23,((64-enemy.maxhealth)/2)+enemy.maxhealth,23,0)
 end
 rect(((64-enemy.maxhealth)/2)-1,22,((64-enemy.maxhealth)/2)+enemy.maxhealth+1,24,7)
end

function generateenemy()
 enemy={}
 enemy.health=flr(rnd(15))+(floornum*7)+1
 if enemy.health>=60 then
  enemy.health=60
 end
 enemy.maxhealth=enemy.health
 enemy.attack=flr(rnd(floornum*2))+1
 animloop=0
end

function drawladderup()
line(26,3,38,3,5)
line(22,4,42,4,5)
line(26,5,38,5,5)
line(27,3,27,17,4)
line(37,3,37,17,4)
line(27,5,37,5,4)
line(27,10,37,10,4)
line(27,15,37,15,4)
end

function drawladderdown()
line(26,59,38,59,5)
line(22,60,42,60,5)
line(26,61,38,61,5)
line(27,61,27,47,4)
line(37,61,37,47,4)
line(27,59,37,59,4)
line(27,54,37,54,4)
line(27,49,37,49,4)
end

function drawchest()
rectfill(22,46,42,60,4)
rect(22,46,42,60,5)
line(23,48,41,48,5)
line(23,50,41,50,5)
line(23,52,41,52,0)
line(23,56,41,56,5)
rectfill(25,51,27,55,10)
rectfill(37,51,39,55,10)
line(22,46,22,46,0)
line(42,46,42,46,0)
line(26,53,26,54,5)
line(38,53,38,54,5)
end

function rotatemessages()
message3c=message2c
message3b=message2b
message3a=message2a
message2c=message1c
message2b=message1b
message2a=message1a
steps=0
end

function messages()
totalsteps+=1
steps+=1
if floor[posx][posy]==2 then
 rotatemessages()
 message1a="-you see a"
 message1b="ladder that"
 message1c="leads up."
end
if floor[posx][posy]==3 then
 rotatemessages()
 message1a="-you see a"
 message1b="ladder that"
 message1c="leads down."
end
if floor[posx][posy]==4 then
 rotatemessages()
 message1a="-you see a"
 message1b="locked chest"
 message1c="before you."
end
if floor[posx][posy]==5 then
 sfx(10)
 rotatemessages()
 message1a="-you are"
 message1b="ambushed by"
 message1c="an enemy!"
 generateenemy()
end
if steps>=1 then
 justclimbed=0
end
if steps>=4 then
 rotatemessages()
 message1a=" "
 message1b=" "
 message1c=" "
end
if steps>=8 then
 rotatemessages()
end
if steps>=12 then
 rotatemessages()
end
end

function titleupdate()
 if btnp(4) then
  music(0)
  chargeninit()
 end
end

function chargenupdate()
 if btnp(0) then
  character="knight"
  str=15
  con=40
  dex=35
 elseif btnp(1) then
  character="wizard"
  str=30
  con=20
  dex=15
 elseif btnp(2) then
  character="cleric"
  str=20
  con=30
  dex=25
 elseif btnp(3) then
  character="ranger"
  str=15
  con=15
  dex=10
 end
 if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
  hp=con
  hpmax=con
  confirminit()
 end
end

function confirmupdate()
 if character=="knight" then
 charspr=64
 elseif character=="wizard" then
 charspr=68
 elseif character=="cleric" then
 charspr=72
 elseif character=="ranger" then
 charspr=76
 end
 if btnp(5) then
  gameinit()
 elseif btnp(4) then
  chargeninit()
 end
end

function gameoverupdate()
 if scroll>=111 then
  scroll-=1
 end 
end

function endingupdate()
 if scroll>=111 then
  scroll-=1
 end 
end

function gameupdate()
animloop+=2
if animloop>=50 then
 animloop=0
end
sclock+=1
if sclock>1800 then
 mclock+=1
 sclock=0
end
if mclock>60 then
 hclock+=1
 mclock=0
end
if dirdraw==0 then
 facing="n"
elseif dirdraw==1 then
 facing="e"
elseif dirdraw==2 then
 facing="s"
elseif dirdraw==3 then
 facing="w"
end
move()
if hp<=0 then
 mode=5
end
end

function _draw()
 if mode==0 then
  titledraw()
 elseif mode==1 then
  gamedraw()
 elseif mode==3 then
  chargendraw()
 elseif mode==4 then
  confirmdraw()
 elseif mode==5 then
  gameoverdraw()
 elseif mode==6 then
  endingdraw()
 end
end

function titledraw()
 cls()
 spr(128,0,0,16,7)
 print("by eduardolicious",30,64,15)
 print("high score:",36,97,15)
 print(high,80,97,10)
 print("push Ž to start",32,103,15)
 print("music by 0xabad1dea git.io/voamb",0,115,15)
 print("enemy art by @tronknotts",16,121,15)
end

function chargendraw()
 cls()
 spr(2,61,44)
 spr(2,61,57,1,1,false,true)
 spr(3,67,51)
 spr(3,54,51,1,1,true,false)
 spr(64,5,38,4,4)
 spr(68,90,38,4,4)
 spr(72,48,0,4,4)
 spr(76,48,76,4,4)
 print("knight",10,71,12)
 print("wizard",95,71,12)
 print("cleric",53,34,12)
 print("ranger",53,109,12)
 print("choose your character",24,120,7)
end

function confirmdraw()
 rectfill(15,15,111,111,10)
 rectfill(16,16,110,110,0)
 print(character,52,19,7)
 spr(charspr,48,25,4,4)
 if character=="knight" then
  print("- high defense",18,65,12)
  print("- high hp",18,71,12)
  print("- low attack",18,77,12)
 elseif character=="wizard" then
  print("- huge magical attack",18,65,12)
  print("- very low defense",18,71,12)
  print("- very low hp",18,77,12)
 elseif character=="ranger" then
  print("- below average stats",18,65,12)
  print("- avoids all traps",18,71,12)
  print("- avoids more attacks",18,77,12)
 elseif character=="cleric" then
  print("- well-rounded stats",18,65,12)
  print("- potions receive a",18,71,12)
  print("healing bonus",26,77,12)
 end
 print("Ž-go back  —-confirm",20,102,10)
end

function gamedraw()
cls()
line(0,72,64,72,7)
local compx=2
while compx<30 do
 line(compx,68,compx,68,7)
 line(compx+34,68,compx+34,68,7)
 compx+=2
end
print(facing,31,66,7)
spr(1,66,0)
spr(1,66,65,1,1,false,true)
line(74,8,74,64,7)
line(70,0,125,0,7)
line(70,72,125,72,7)
line(126,1,126,5,7)
line(126,71,126,67,7)
line(127,6,127,66,7)
rectfill(74,1,126,71,7)
print(message1a,76,6,0)
print(message1b,77,12,0)
print(message1c,78,18,0)
print(message2a,79,28,5)
print(message2b,79,34,5)
print(message2c,79,40,5)
print(message3a,78,50,6)
print(message3b,77,56,6)
print(message3c,76,62,6)
if btn(3) then
rectfill(0,0,64,64,15)
for mapblockx=0,15 do
 for mapblocky=0,15 do
  if sget(mapblockx+floornum*16,mapblocky+8)==1 or sget(mapblockx+floornum*16,mapblocky+8)==5 then
  rectfill(mapblockx*4,mapblocky*4,((mapblockx+1)*4)-1,((mapblocky+1)*4)-1,0)
  if sget(mapblockx+floornum*16,mapblocky+7)==0 then
   line((mapblockx*4),(mapblocky*4),(mapblockx*4)+3,(mapblocky*4),6)
  end
  if sget(mapblockx+floornum*16,mapblocky+9)==0 then
   line((mapblockx*4),(mapblocky*4)+3,(mapblockx*4)+3,(mapblocky*4)+3,6)
  end
  if sget((mapblockx+floornum*16)-1,mapblocky+8)==0 then
   line((mapblockx*4),(mapblocky*4),(mapblockx*4),(mapblocky*4)+3,6)
  end
  if sget((mapblockx+floornum*16)+1,mapblocky+8)==0 then
   line((mapblockx*4)+3,(mapblocky*4),(mapblockx*4)+3,(mapblocky*4)+3,6)
  end
  line(mapblockx*4,mapblocky*4,mapblockx*4,mapblocky*4,6)
  line(mapblockx*4+3,mapblocky*4,mapblockx*4+3,mapblocky*4,6)
	 line(mapblockx*4,mapblocky*4+3,mapblockx*4,mapblocky*4+3,6)
	 line(mapblockx*4+3,mapblocky*4+3,mapblockx*4+3,mapblocky*4+3,6)  
  elseif sget(mapblockx+floornum*16,mapblocky+8)==2 then
  rectfill(mapblockx*4,mapblocky*4,((mapblockx+1)*4)-1,((mapblocky+1)*4)-1,0)
  spr(8,mapblockx*4,mapblocky*4)
  elseif sget(mapblockx+floornum*16,mapblocky+8)==3 then
  rectfill(mapblockx*4,mapblocky*4,((mapblockx+1)*4)-1,((mapblocky+1)*4)-1,0)
  spr(9,mapblockx*4,mapblocky*4)
  elseif sget(mapblockx+floornum*16,mapblocky+8)==4 then
  rectfill(mapblockx*4,mapblocky*4,((mapblockx+1)*4)-1,((mapblocky+1)*4)-1,0)
  spr(10,mapblockx*4,mapblocky*4)  
  end
  end
end 
if dirdraw==1 then
spr(7,posx*4-2,posy*4-2)
elseif dirdraw==3 then
spr(7,posx*4-2,posy*4-2,1,1,true,false)
elseif dirdraw==2 then
spr(11,posx*4-2,posy*4-2)
elseif dirdraw==0 then
spr(12,posx*4-2,posy*4-2)
end
sspr(112,64,15,15,0,0,60,60)
else
drawwalls()
drawprops()
end
line(0,0,64,0,7)
line(0,64,64,64,7)
line(0,0,0,72,7)
line(64,0,64,72,7)
rect(0,74,127,127,7)
print(character,9,109,7)
line(6,116,35,116)
spr(charspr,5,76,4,4)
spr(4,3,119)
print(potions,13,120,7)
spr(5,18,119)
if gold<=9 then
 print("00",28,120)
 print(gold,36,120)
 elseif gold>9 and gold<=99 then
 print("0",28,120)
 print(gold,32,120)
 elseif gold>99 and gold<=999 then
 print(gold,28,120)
 elseif gold>999 then
 print("999",28,120)
end
line(41,75,41,127,7)
line(41,107,127,107,7)
line(84,80,84,105,7)
print("-hold ƒ to view map-",43,121)
if potions>=1 then
 print("push Ž to use potion",43,115)
end
if floor[posx][posy]==2 then
 print(" ",43,109,7)
 elseif floor[posx][posy]==3 then
 print("push — to climb down",43,109,7)
 elseif floor[posx][posy]==4 then
 print("push — to open chest",43,109,7)
 elseif floor[posx][posy]==5 then
 print("push — to attack",51,109,7)
end
print("hp:   /",45,79,7)
print(hpmax,73,79,7)
if hp<10 then
 print("0",61,79,7)
 print(hp,65,79,7)
else
 print(hp,61,79,7)
end
print("atk:",45,85,7)
print(str,73,85,7)
print("def:",45,91,7)
print(dex,73,91,7)
print("floor",50,99,7)
print(floornum+1,74,99,7)
print("steps",96,76,7)
print("taken:",94,82,7)
if totalsteps<10 then
 print(totalsteps,104,88,7)
 elseif totalsteps>=10 and totalsteps<100 then
 print(totalsteps,102,88,7) 
 elseif totalsteps>=100 and totalsteps<1000 then
 print(totalsteps,100,88,7) 
 elseif totalsteps>=1000 and totalsteps<10000 then
 print(totalsteps,98,88,7) 
 elseif totalsteps>=10000 and totalsteps<100000 then
 print(totalsteps,96,88,7) 
 else
 print(totalsteps,94,88,7) 
end
print("time:",96,95,7)
print(":  :",98,101,7)
if hclock>=10 then
 print(hclock,90,101,7)
else
 print("0",90,101,7)
 print(hclock,94,101,7)
end
if mclock>=10 then
 print(mclock,102,101,7)
else
 print("0",102,101,7)
 print(mclock,106,101,7)
end
if flr(sclock/30)>=10 then
 print(flr(sclock/30),114,101,7)
else
 print("0",114,101,7)
 print(flr(sclock/30),118,101,7)
end
end

function gameoverdraw()
 cls()
 print("you have succumbed to your",0,scroll/3,6)
 print("injuries, and fallen in the",0,scroll/3+6,6)
 print("labyrinth. you will make a fine",0,scroll/3+12,6)
 print("meal for its inhabitants...",0,scroll/3+18,6)
 print("you fell on floor:",0,scroll/3+42,6)
 print(floornum+1,76,scroll/3+42,10)
 print("total gold:",0,scroll/3+48,6)
 print(gold,48,scroll/3+48,10)
 if scroll==110 and gold>high then
  print("new high score!",28,121,10)
  dset(00,gold)
 end
end

function endingdraw()
 cls()
 print("you have escaped the labyrinth.",0,scroll/3,6)
 print("with your life, and your new",0,scroll/3+12,6)
 print("fortune intact, you breathe a",0,scroll/3+18,6)
 print("sigh of relief.",0,scroll/3+24,6)
 print("but...where exactly have you",0,scroll/3+42,6)
 print("escaped to?",0,scroll/3+48,6)
 if scroll==110 and gold>high then
  print("new high score!",28,121,10)
  dset(00,gold)
 end
end

function _update()
 if mode==0 then
  titleupdate()
 elseif mode==1 then
  gameupdate()
 elseif mode==3 then
  chargenupdate()
 elseif mode==4 then
  confirmupdate()
 elseif mode==5 then
  gameoverupdate()
 elseif mode==6 then
  endingupdate()
 end
end