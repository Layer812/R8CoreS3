--wolfenstein 3d
--lovely!
------------------------------
-- all the constants
------------------------------

-- player stats
score=0
health=100
ammo=8

-- start position/rotation of player
posx=29.55 posy=57.5
angle=0

-- player movement speed
movespeed=0.05
rotspeed=0.0075
colwidth=0.2

-- camera field of view
fov=90

-- camera direction/plane vectors
fovsize=-sin((fov/2)/360)
dirx=1 diry=0
planex=0 planey=-fovsize

-- player gun variables
testgun=0
gunframe=0
machinegun=0
shootdelay=25
shoottimer=0
btn4held=0
btn5held=0

-- wall rendering constants
screenwidth=128
wallscale=96
texwidth=32

-- map dimensions
mapwidth=64
mapheight=64

-- door animation stats
doordelay=120

-- information about each object in the world
objectstate={}
objecttimer={}
objectextra={}

-- a table of active objects in the world
objectactive={}
-- a table of objects last seen
objectsseen={}

-- effect timers
damageeffect=0
deadtimer=0

-- soldier info
-- states
soldierstateidle=0
soldierstatealert=1
soldierstateshoot=2
soldierstatehit=3
soldierstatedying=4
soldierstatedead=5
soldierstatedeadammo=6
-- sprites for each state
soldierstatesprites={38,35,35,37,37,36,36}

-- x/y/w/h in the sprite sheet
spritedata = 
{
 76,45,5,5, --ammo
 88,0,12,16, --barrel
 56,0,16,17, --barrel2
 107,14,9,7, --chest
 95,47,7,9, --cross
 102,45,9,7, --crown
 107,57,6,7, --cup
 120,0,7,30, --flag
 74,24,14,5, --food
 61,30,15,16, --head1
 94,16,13,5, --health
 61,46,15,5, --hudammo
 27,59,20,5, --hudhealth
 43,30,18,21, --lamp
 0,32,27,31, --light
 0,0,31,32, --light2
 87,58,20,6, --machinegun
 85,29,3,5, -- numbers0
 85,34,3,5, -- numbers1
 85,39,3,5, -- numbers2
 113,9,3,5, -- numbers3
 102,52,3,5, --numbers4
 105,52,3,5, --numbers5
 108,52,3,5, --numbers6
 116,9,3,5, -- numbers7
 116,14,3,5, --numbers8
 111,49,3,5, --numbers9
 113,0,7,9, --pistolidle
 100,0,13,14, --pistolshoot
 27,32,16,27, --plant
 47,59,23,4, --puddle
 43,51,30,8, --rags
 70,59,17,5, --score
 81,45,5,5, --shot
 74,17,20,7, --skeleton
 88,24,12,23, --soldieraim
 73,51,22,7, --soldierdead
 72,0,16,17, --soldierdying3
 100,21,11,24, --soldierstand
 31,17,22,13, --table
 31,0,25,17, --tablechairs
 111,21,9,28, --vase
 76,29,9,16, --vase2
 53,17,21,13, --well
}

-- dereference table from map
-- data into the sprite data
objecttable=
{
 0,16,3,4,6,8,10,0,5,0,
 0,0,0,0,0,0,0,0,0,0,
 38,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,
 1,34,0,14,30,40,13,15,0,29,
 0,41,42,39,0,42,0,0,31,0,
 43,43,0,7,2,36,0,0,0,0,
}

titledata=
{
"112502601119501601501105d02101501146",
"111201502d0160150110520140110f501602701d02101501d01501601701601501145",
"110401504d01701601501102201501d0250110a501d02601503d01501d02503d01e01501145",
"10f201d07602101401501d02602501109501601d02501d02402d03501d0240111c501129",
"10f401d03501d04f01101401d05601501108201d03101201401202d0340311c201d0110b401d0111c",
"10f601d02501101601d03e01501d08108201d03502102201d0360111d201d0210a401501d0211b",
"10f601d02201101d04401501d02501d05108201501d02502102201d0410150111a501401d0160110ad0150110150111b",
"10fd01601201102d04e01d03501d04401102504102201501d02502101501401d04501d01501102502103502102503105501601503101401d02601502102503102502104502102503113",
"10f501701201102d01603e01501601201501d01602d01201101201d02601701601503602503d02603d03101501d02701501101401d01702601501602701d01201401801d01601701602401605503d02601102201d01702501201d01601701601501d01601701d01111",
"110d01401501101501603401101d01401501d01603202d01606501101602d01501d01607201401d01603701501401603d02604401d02604501d01604501401d01604d01501401604401604501604501110",
"111d01501101501603401102502d01603201603402603401101602503d01501603d01101401606701201603d01604402602501d02401501d01603502607d01401603401201603501604401111",
"114501603201103502603201603201401603401101602503101501604101d01607401608402602501002501101d01603502608201603401201608401111",
"115703001d03502702601401703101401601701601d01101702502102501601701602101501703101601701601401601702601501702601d01101702d01101501102d01601701601502d01702d02702601401703402601702601501601702d01111",
"114501d01602101501602501101602701401d01602501201101601701d01001d01601d01501104603101d02602d01101601d02501602d01101d01602d01001d01604501101d01501d01701502101603502601d01501d01602501d01101d01602501101602d01111",
"114501007501003d01401003d01101002101d01003d01501102501101001101601101601003d01001d01501601003502002101d02005d01501601101001101d01501101002101501101d01101d01003d02003502002101d01111",
"11450100bd02003601501201002d01003d01501102501201002601101d01004d01501101d01003101501003502d01201003201501601201002d01501201003201601102601201002601d01201002501d01003d01111",
"11450120a401502203601501203601001202601d01101502203601101501204d01102d01203502203501102501203401d02203502204502102601203d01501203502203d01111",
"114501804001804401d01101501803601501803d01101802401601d01201d01401802601102803601504803501101802401501101d03802401d01501401802502201802401601102d02803502401802d01501401802501111",
"014501804101804d01103803d01803401501201805401d01803601102803401601501401501803601101803502401801201803d01501803601501401803f01d01401502803601501803601501803d01501110",
"101004102002102002101001102001101502803401101803401102001101803401802401501101501805d01501803601101501805401d01501803401101803401501804401502101401802401501401805401d01501803e0150140180240110140180240150110220210c",
"10100310100d101d01504101504103001101503102501d01102501d03e01d01502e03601101503d01e03d01501101401e01503d02503101f01502102502e01601501101503e03d01502201801e01d01501101501e01503d02501111",
"101012503103501105001107501105505d01e01f02d01102502d01501101502103d01104d01101501102d01107d01102502d02501101501104601104501104d01112",
"00310300310100110100310200510100410100210200210d501e02501601f02d01149",
"00310400110200110100310200a10100310200110d501f01701f0270160150112b50211c",
"00310600310200910100310200410dd01e02f01702e0120111cd0150260150110a201501601d01501201601501117",
"10100210500510300110100910200210100210c601501101201e0160111d201d02502602501109503401502603501114",
"00310600310100110200110100210100110200310200110200310b50110350211e201d05601d01105501401d08501d01602501112",
"10100210700210200110100410100210100310100110300312f201801501001d04105401d0d601d01111",
"003107002103001101003101002102003102001102002130202001d04104501401d03501d0a601111",
"101002102001101003101005101006101004102005133d03501104201401d02101501d0a601111",
"00310300410100910100210100b133602d01501104202601d01502d01602d01502d01603d01111",
"00310400210100210200610100210200b132602d01501104501101601d01101501d01602d01501101501603501111",
"00310400210100310101612fd01401101601d01101501401e01d03602d01101501601702601501101501702601501111",
"003101001104004103002101506003102002133501d02701d02403d02602501601101201d01702601201102703501111",
"101002101002103007101506403101001101003132502004d01201004502101501101201002101501201101003502111",
"003101002101001101002101004506101501402501001102002131501601501004501201004502103201004201101003101d01111",
"003103004101004102504004502101004131601504202001d01201102501104d01101001201002502001202001d01111",
"00810100610550310200110400210d001122501401502101d01403d01108401501201402201501d01404501111",
"00f10450340250200610200112d501401801503803501108401d01401802401601804401501111",
"00f10250110150110150100150140200110200310100212d501401802502803501108402803402803401113",
"00510100110200710350410100150100110100410100210d00111f501d01e02401501e03501107501401e09d01113",
"00410100110500510250240450140150110100410200112e501f03d01f02502107501e01f08601114",
"004101001105004101001503406501101004132501703d01502108501d02502101501103d01114",
"004101001101001103003101501002504402502101001101003132502701601501107502102d0150311a",
"004104005101501101002501405502102004134501109302120",
"004104002102001502002102406501101001101003129502d0260150110eb0330111a304101",
"00410300210200110150100210440610100110100310100111b303109503d0350110c301b01601f01d01b01114001102001101301c03501",
"00410300210100110150110100210540500210100310100211a303109503d0260150110c301b01d02b01301114001102001101301c01302101",
"00410500110250100110500110100110700611a303109501d03602501120001105001102001101301c01602501",
"10100310200310250100110c50210300411b30310a501402501101d01118001101001105001102001101002102001101c01602c01501",
"00910300150110350d10100111d303109501402e02502115001101002101002104001103003102001101301602c01501",
"009103501101401104504d01501d0450210300111a301c01301109001403e01501111302103004101004102007102001101301c01601c01501",
"009101001502106508d0350110100311a301c01301103001106404501101501b01301107001105c0160110100110100a103001102001103001101301c01601c01101",
"00a101502401501401105503101504d01502101003119301c01301103001301106503101301c02303006101003101601c01001102001101003101001101003105002102001101301c02301101",
"004103003101503101401104501101502103501d0350110100211a301c01301103001301102001103402102501301c01303108001102c02103002104001105003101002101002101302c01301101",
"003105002101504401103001501102501103502d0250110100211a301601301104301502001101001101002d01101501d01401303105001105c0130110300310a002101002102001101301c02301101",
"003101001101001101002501101501403101002101501101502001101501d0450110100211a301c01301001103503002501401502402e01401e01d01302105001102001102302103001102001101004104005102001101302c01301101",
"004102001101002102502402502102002102001101502d0350110100211a301c01301104503101001408e01401302103001101001102001102302103001101002101003103001101002101002102001101302c01301101",
"004102005101502101d05501102001102501d0450100311a301601301103001504001d01401501401501402501401e01d01301108002101302102002101001102001101002101005101002102001101302c01301101",
"00c103d01501d04501104501d0450100311a301601301001103504102502404501401e01d01301104002102002101302102001102001102001104003101004102001101302c01301101",
"004101006101002503d03501d02501001102502d0250100110100111a301601301104501102501401101001101404501402e01501108001102302102001105001109003101002101302c01301101",
"00a102002101505d03504d04103001112001107d01601301103502102502401101001101403101501402d0b503106001101001101003105002105304101",
"009102004102503d07501d0250100111dd01c01301103503001101503101002502101403d0e503105001109002105304101",
"008102007501001101501d0950110100211bd01c01301103501401501004501d02101002101403d12502102001109001106304101",
"008101009102502d01502d01501d0310200311ac02301102502401501001101002501d02101002501401e01401d15504106002106304101",
"01510150710200411a601c01301101d02501402101501405502101403501d1b50210a304101",
"01610450110150100110400111ac01302501d03402501405502402e02401d21502105304101",
"01810150110200110200210100111a503d04402501404502403e01f01d24505304501",
"01510100510150110100210100210a00110fd08501406503403d0660ed1a",
"01510550210100310100211ad08501405501101502402d2f",
"01110200310250110350110200111dd09405503403d11501101401105501d15",
"00d10100210b502101003108001113d08501405501101501403d11501101901005501d15",
"00c101002102505102503d02501101002101001119d09501405501101501403d0e201501201501101901504001501201501202501202501202502d01202502d04",
"00e102501104505d03501101004102001114502d09405e01501101501403d0e201501201501101902101501901101501d01501202d01501201501203501d01202502d04",
"00c109502d05502101005116501d0a407101501403d0e201501201501101902101001401502201d01501201d01501201502203d01202501201501d03",
"00c107504d02502103006115501d0b502402501401103502401d11501101902101001401502d01502d01501d01506d01502d06",
"00e103508101504001101003116d0c501001503001501001103d12501101902101501901101501d01204501205502202501d05",
"00d103506102507101003115501d0d101004501003101d12501101504101001501d01501203501203501201502202501d05",
"00f10d503101003114501d0e501003101501003501d12501007501d01502201502201502201504201501d05",
"00a107002102505d01505003114d10003101501003501d13508d15",
"00a102505101001102504101502d02502101002113d10501003101501003101d30",
"009101002101504102001106503d02501101002112d0f503004101004d12501114501d08",
"00a102505103001104505d02101002111501d0b506101003103001102d1250100310e003101d08",
"00a102505103002104505d01501001112d0c505102003102503d13501003e03401e04401e04101003101d08",
"00a101507102003103507111501d0b510d14501002101801401801402203402101401101004101d08",
"00b102505102004101504d0150110150100210fd0c50dd17501002202802402201801001101801402002101002101d08",
"00a102505103003101501102502d0150210200110e501d0d509d09201502201502207d01201501201501002401201802401101402101402201401101001401002101d08",
"00a101507102002105502d0250110200110ed20201502202501201501205d01201501201501001101801401801401501402201401201401201401202f01101001101d08",
"00a101507102003104502d0250110100110ed21201501202501207501d01201501201501001101401101402202408901701401201101d08",
"009102507102005102503d0210100210cd33501001403e01803401007101201002101d08",
"009102507102006101503d0210100210bd34501001201805009102002101d08",
"009103506102006102502d0210100210a501d34501010101003101d08",
"00a103504102006103502d02102001109501d35501115d08",
"00b10800510200110150410cd37515d08",
"00c10600810350310bd55"
}

showtitle=1
titletimer=0

------------------------------
-- all the init functions
------------------------------

function _init()
 showtitle=1
 titletimer=0
 drawtitle()
end

function hextoint(hex)
 if(hex=="0") return 0
 if(hex=="1") return 1
 if(hex=="2") return 2
 if(hex=="3") return 3
 if(hex=="4") return 4
 if(hex=="5") return 5
 if(hex=="6") return 6
 if(hex=="7") return 7
 if(hex=="8") return 8
 if(hex=="9") return 9
 if(hex=="a") return 10
 if(hex=="b") return 11
 if(hex=="c") return 12
 if(hex=="d") return 13
 if(hex=="e") return 14
 if(hex=="f") return 15
 printh("bad")
 printh(hex)
 return 0
end

function drawtitle()
 clip(0,0,128,128)
 rectfill(0,0,127,127,0) 
 
 -- decode the rld onto screen
 for y=0,94 do
  data=titledata[y+1]
  offset=1 
  x=0
  while offset<#data do
   c=hextoint(sub(data,offset,offset))
   l=hextoint(sub(data,offset+1,offset+1))*16
   l+=hextoint(sub(data,offset+2,offset+2))
   line(x,y,x+l,y,c)
   x+=l
   offset+=3
  end
 end
end

function initgame()
 score=0
 health=100
 ammo=8
 posx=29.55 posy=57.5
 angle=0
 dirx=1 diry=0
 planex=0 planey=-fovsize
 machinegun=0

 inittiles()
 initdrawhud()
end

-- create a table containing a
-- value that represents each
-- object's state
function inittiles()
 objectactive={}
 objectsseen={}
 objectstate={}
 objecttimer={}
 objectextra={}
 
 -- look for all the objects in the map
 for y=0,mapheight do
  for x=0,mapwidth do
   index=y*mapheight+x
   tile=peek(0x2000+index)-2
   --is this tile solid
   if(tile<8)then
   else
    --this must be an object
    objectstate[index]=0
	objecttimer[index]=0	
    objectextra[index]=0
	-- give soldiers some health
	if(tile==59)objectextra[index]=2
   end
  end
 end
end
 
-- draw some initial stuff for
-- the hud that never changes
-- so we don't have to do it at
-- run time
function initdrawhud()
 clip(0,128-15,128,15)
 palt(0,false)
 rectfill(0,128-15,127,127,1)
 
 drawsprite(9,58,128-15)
 print("score",5,128-14,12)
 print("health",30,128-14,12)
 print("ammo",80,128-14,12)
 
 drawscore()
 drawhealth()
 drawammo()
end

------------------------------
-- all the update functions
------------------------------

function _update60()
 if(showtitle==1)then
  rectfill(0,95,127,127,0)
  titletimer+=1
  if(titletimer%30<20)then
   print("press z to start!", 32, 114,12) 
  end
  -- z to start
  if(btn(4))then
   btn4held=1
   showtitle=0
   initgame()
  end
 else
  checkbuttons()
  checkcollection()
  updategun()
  updateobjects()
  updatedead()
 end
end

-- is a tile at the given tile x/y 
-- solid to the player?
function gettilesolid(x,y)
 -- get the tile
 index=flr(y)*mapwidth+flr(x)
 tile=peek(0x2000+index)-2
 
 -- is this a solid tile
 if(tile>=0 and tile<8) return true
 
 -- is this a door tile
 if(tile==8 or tile==9)then
  if(objectstate[index]==0) return true
 end
 
 return false
end

-- process player input
function checkbuttons()
 -- move forward
 if(btn(2))then
  posx+=dirx*movespeed
  if(gettilesolid(posx-colwidth,posy)) posx=flr(posx-colwidth)+1+colwidth
  if(gettilesolid(posx+colwidth,posy)) posx=flr(posx+colwidth)-colwidth
  posy+=diry*movespeed
  if(gettilesolid(posx,posy-colwidth)) posy=flr(posy-colwidth)+1+colwidth
  if(gettilesolid(posx,posy+colwidth)) posy=flr(posy+colwidth)-colwidth
 end
 -- move back
 if(btn(3))then
  posx-=dirx*movespeed
  if(gettilesolid(posx-colwidth,posy)) posx=flr(posx-colwidth)+1+colwidth
  if(gettilesolid(posx+colwidth,posy)) posx=flr(posx+colwidth)-colwidth
  posy-=diry*movespeed
  if(gettilesolid(posx,posy-colwidth)) posy=flr(posy-colwidth)+1+colwidth
  if(gettilesolid(posx,posy+colwidth)) posy=flr(posy+colwidth)-colwidth
 end
 -- turn left
 if(btn(1))then
  angle-=rotspeed
  dirx=cos(angle)
  diry=sin(angle)
  planex=cos(angle+0.25)*fovsize
  planey=sin(angle+0.25)*fovsize
 end
 -- turn right
 if(btn(0))then
  angle+=rotspeed
  dirx=cos(angle)
  diry=sin(angle)
  planex=cos(angle+0.25)*fovsize
  planey=sin(angle+0.25)*fovsize
 end

 -- is button4 still held
 if(btn4held==1 and machinegun==0)then
  if(not btn(4))btn4held=0
 else
  -- shoot
  if(btn(4) and ammo>0 and shoottimer==0)then
   if(machinegun==1)then
    shoottimer=10
   else
    shoottimer=shootdelay
   end
   gunframe=1
   btn4held=1
   testgun=1
   ammo-=1
   drawammo()
   sfx(0,0,0)
  end
 end

 -- is button5 still held
 if(btn5held==1)then
  if(not btn(5))btn5held=0
 else
  -- open door
  if(btn(5))then
   testdoor()
   btn5held=1
  end
 end
end

-- look ahead for a door and
-- activate it if possible
function testdoor()

 -- look ahead to next tile
 x=flr(posx)
 y=flr(posy)
 if(abs(dirx)>abs(diry))then
  if(dirx>0)then
   x+=1
  else
   x-=1
  end
 else
  if(diry>0)then
   y+=1
  else
   y-=1
  end
 end

 -- get the tile 
 index=y*mapwidth+x
 tile=peek(0x2000+index)-2
 
 -- is this a door
 if(tile==8 or tile==9)then
  timer=objectstate[index]
  -- is the door full closed
  if(timer==0) then
   objectstate[index]=doordelay
   objectactive[index]=1
   sfx(2,0,0)
  else
   -- is the door closing
   if(timer<20) then
    objectstate[index]=doordelay-timer
    sfx(2,0,0)
   end
  end
 end
end

-- check if the player has
-- collected something
function checkcollection()
 index=flr(posy)*mapwidth+flr(posx)
 
 tile=peek(0x2000+index)-1
 -- is this a soldier
 if(tile==60)then
  -- does the soldier still have ammo
  if(objectstate[index]==soldierstatedeadammo)then
    if(ammo==99) return
    sfx(1,0,0)
    objectstate[index]=soldierstatedead
    ammo+=4
    if(ammo>99) ammo=99
    drawammo()
  end
 end
 
 -- is this a collectable
 if(tile>=40 and tile<50) then
  -- has the object already been collected
  if(objectstate[index]==0) then
   -- ammo?
   if(tile==40)then
    if(ammo==99) return
    ammo+=4
    if(ammo>99) ammo=99
    drawammo()
   end
   -- machine gun?
   if(tile==41)then
    machinegun=1
   end
   -- treasure?
   if(tile==42)then
    score+=1000
    drawscore()
   end
   -- cross?
   if(tile==43)then
    score+=100
    drawscore()
   end
   -- cup?
   if(tile==44)then
    score+=500
    drawscore()
   end
   -- food?
   if(tile==45)then
    if(health==100)return
    health+=10
    if(health>100) health=100
    drawhealth()
   end
   -- health?
   if(tile==46)then
    if(health==100)return
    health+=20
    if(health>100) health=100
    drawhealth()
   end
   -- crown?
   if(tile==48)then
    score+=1000
    drawscore()
   end

   sfx(1,0,0)
   -- mark object as collected
   objectstate[index]=1
  end
 end
end

-- update gun animation
function updategun() 
 if(shoottimer>0)then
  shoottimer-=1
  if(machinegun==1)then
   if(shoottimer==5)then
    gunframe=0
   end
  else
   if(shoottimer==shootdelay-10)then
    gunframe=0
   end
  end
 end
end

-- update all the active objects
function updateobjects()
 removeobject=0
 -- run through all active objects
 for key,value in pairs(objectactive) do
  -- get the object type
  tile=peek(0x2000+key)-2
  
  -- is this a door
  if(tile==8 or tile==9)then
   -- make sure the player isn't inside 
   -- the door when it's closing
   ok=true
   if(objectstate[key]==20)then
    x=key%mapwidth
	y=flr(key/mapwidth)
	if(x==flr(posx) and y==flr(posy)) ok=false
   end
   
   if(ok)then
    if(objectstate[key]==20) sfx(3,0,0)
    -- reduce timer
    objectstate[key]-=1
    -- end of animation?
    if(objectstate[key]==0)then
     objectactive[key]=2
	 removeobject=1
    end
   end
  end
  
  -- is this a soldier
  if(tile==59)then
   -- is idle
   if(objectstate[key]==soldierstateidle)then
    objecttimer[key]+=1
    if(objecttimer[key]==30)then
	 objecttimer[key]=30
	 objectstate[key]=soldierstatealert
	end
   else   
    -- update the state timer
    objecttimer[key]-=1
    if(objecttimer[key]==0)then
     -- end the current state
	 if(objectstate[key]==soldierstatehit)then
	  objectstate[key]=soldierstateidle
	  objectactive[key]=2
 	  removeobject=1
	 elseif(objectstate[key]==soldierstatedying)then
	  objectstate[key]=soldierstatedeadammo
	  objectactive[key]=2
 	  removeobject=1
	 elseif(objectstate[key]==soldierstatealert)then
	  -- is the soldier still on screen (and player still alive)
	  if(objectsseen[key] and health>0)then
	   -- shoot
	   objectstate[key]=soldierstateshoot
	   objecttimer[key]=30	  
       sfx(4,0,0)
	   damageeffect=5
	   -- lose some health
       health-=5
       if(health<=0)then
	    health=0
	   end
       drawhealth()
	  else
	   -- go back to idle
	   objectstate[key]=soldierstateidle
	   objectactive[key]=2
 	   removeobject=1
	  end
	 elseif(objectstate[key]==soldierstateshoot)then
	   objectstate[key]=soldierstatealert
 	   objecttimer[key]=30
	 end
    end
   end
  end
 end

 -- do any objects need to be removed from the list 
 while removeobject==1 do
  removeobject=0
  -- run through all active objects
  for key,value in pairs(objectactive) do
   if(objectactive[key]==2)then
	 objectactive[key]=nil
	 removeobject=1
	 break
   end
  end 
 end
end

function updatedead()
 if(health==0)then
  deadtimer+=1
  if(deadtimer==120)then
   _init()
  end
 end
end

------------------------------
-- all the render functions
------------------------------

function _draw()
 if(showtitle==1)then
 else
  clip(0,0,128,128-15)
  clearscreen()
  drawwalls()
  drawgun()
  draweffects()
 end
end

function clearscreen()
 rectfill(0,0,127,55,5)
 rectfill(0,56,127,127,13)
end

rayposx=0
rayposy=0
raydirx=0
raydiry=0
mapx=0
mapy=0
stepx=0
stepy=0
tile=0
perpwalldist=0
wallx=0
index=0

function renderdoor()
 timer=objectstate[index]
 
 -- calc distance to wall
 if (side==0) then
  perpwalldist=(mapx-rayposx+(1-stepx)/2)/raydirx
 else
  perpwalldist=(mapy-rayposy+(1-stepy)/2)/raydiry
 end

 -- work out the wall x fraction
 if(side==0)then
  wallx=rayposy+perpwalldist*raydiry
 else
  wallx=rayposx+perpwalldist*raydirx
 end
 wallx-=flr(wallx)
 
 -- work out percent the door is open
 dooropenpercent=0
 if(timer>0)then
  dooropenpercent=1
  if(timer>doordelay-20) dooropenpercent=1-(timer-(doordelay-20))/20
  if(timer<20) dooropenpercent=timer/20
 end
 wallx+=dooropenpercent
 
 solid=false
 if(wallx<1) solid=true

 -- flip door for other side 
 if(tile==8 and mapy<posy) wallx=1-wallx
 if(tile==9 and mapx>posx) wallx=1-wallx
 
 return solid
end
 
function drawwalls()
 tempobjectsseen={}
 distances={}
  
 palt(0,false)
 for x=0,screenwidth do
  --calculate ray pos/dir
  camerax=2*x/screenwidth-1
  rayposx=posx
  rayposy=posy
  raydirx=dirx+planex*camerax
  raydiry=diry+planey*camerax
  
  -- which map tile
  mapx=flr(rayposx)
  mapy=flr(rayposy)
  
  --length of ray
  rds=raydirx*raydirx
  if(rds>0.0001)then
   deltadistx=sqrt(1+(raydiry*raydiry)/rds)
  else
   deltadistx=1000
  end
  rds=raydiry*raydiry
  if(rds>0.0001)then
	  deltadisty=sqrt(1+(raydirx*raydirx)/rds)
	 else
	  deltadisty=1000
	 end

  if(raydirx<0)then
   stepx=-1
   sidedistx=(rayposx-mapx)*deltadistx
  else
   stepx=1
   sidedistx=(mapx+1-rayposx)*deltadistx
  end  
  if(raydiry<0)then
   stepy=-1
   sidedisty=(rayposy-mapy)*deltadisty
  else
   stepy=1
   sidedisty=(mapy+1-rayposy)*deltadisty
  end  

  --cast the ray until we hit a wall
  while true do
   --move to the next tile edge
   if(sidedistx<sidedisty)then
    sidedistx+=deltadistx
    mapx+=stepx
    side=0
   else
    sidedisty+=deltadisty
    mapy+=stepy
    side=1
   end
   
   --fetch the tile from the map data
   tile=peek(0x2000+mapy*mapwidth+mapx)
   if(tile!=1)then
    tile-=2
    --is this tile solid
    if(tile<8)then
     -- calc distance to wall
     if (side==0) then
      perpwalldist=(mapx-rayposx+(1-stepx)/2)/raydirx
     else
      perpwalldist=(mapy-rayposy+(1-stepy)/2)/raydiry
     end
	 
     -- work out the wall x fraction
     if(side==0)then
      wallx=rayposy+perpwalldist*raydiry
     else
      wallx=rayposx+perpwalldist*raydirx
     end
     wallx-=flr(wallx)

     --stop ray casting
     break
    else
     --is this a door
     if(tile<10)then
      index=mapy*mapwidth+mapx
	  if(renderdoor()) break	  
     else
      index=mapy*mapwidth+mapx
      --this must be an object
      if(tempobjectsseen[index]==nil) then
       -- has the object been collected
       if(tile==59 or objectstate[index]==0) then
        tempobjectsseen[index]=tile
       end
      end
     end
    end
   end
  end
   
  -- remember the distance to the wall
  distances[x]=perpwalldist
 
  -- calc line height
  lh=flr(flr(wallscale/perpwalldist)/2)

  -- calc the texture x coord
  texx=flr(wallx*texwidth)
  if(side==0 and raydirx>0)then
   texx=texwidth-texx-1
  end
  if(side==1 and raydiry<0)then
   texx=texwidth-texx-1
  end

  -- calc sprite coords from tile type
  if(tile==8 or tile==9) tile=6
  texx+=tile*texwidth
  texy=flr(texx/128)*texwidth
  texx=(texx%128)
  -- and draw sprite
  sspr(texx,texy,1,texwidth,127-x,56-lh,1,lh*2)
 end
 
 drawobjects(tempobjectsseen,distances)
end

function soldierhit(key)
 -- reduce health
 objectextra[key]-=1
 
 -- is soldier dead
 if(objectextra[key]==0)then
  objectstate[key]=soldierstatedying
  objecttimer[key]=10
  -- award score
  score+=100
  drawscore()
 else
  objectstate[key]=soldierstatehit
  objecttimer[key]=10
 end 
 -- make sure soldier is active
 if(objectactive[key]==nil) objectactive[key]=1
end

function drawsoldier(key,x,y,size)
 -- make sure soldier is active
 if(objectactive[key]==nil) objectactive[key]=1
 
 -- do we need to test shooting this
 if(testgun==1)then
  -- is soldier in a state to be shot
  state=objectstate[key]
  if(state!=soldierstatedying and state!=soldierstatedead and state!=soldierstatedeadammo) then
   -- calc screen width of soldier
   width=14*size
   if(width<20) width=20
   x1=x-width/2
   x2=x+width/2
   -- does the shot hit the player 
   -- (is soldier in the middle of the screen)
   if(x1<64 and x2>=64)then
    -- no more gun testing
    testgun=0
	soldierhit(key)
   end
  end
 end

 -- get the soldier's state
 state=objectstate[key]
 -- get the sprite for this state
 sprite=soldierstatesprites[state+1]
 drawspriteworld(sprite,x,y,size)
 
 -- is there ammo spawned
 if(state==soldierstatedeadammo)then
  drawspriteworld(0,x,y,size)
 end
 
 -- is there soldier shooting
 if(state==soldierstateshoot and objecttimer[key]>20)then
  drawspriteworld(33,x,y-14*size,size)
 end
end

function sort(a)
 i=1
 while (i<=#a) do
  local j = i
  i+=2
  while j > 2 and a[j-2] < a[j] do
   a[j],a[j-2] = a[j-2],a[j]
   a[j+1],a[j-2+1] = a[j-2+1],a[j+1]
   j = j - 2
  end
 end
end

function drawobjects(objects,distances)
 palt(0,true)

 -- build a 'sorted by distance' 
 -- table of the objects
 sortedobjects={}
 for key,value in pairs(objects) do
  dx=key%mapwidth+0.5-posx
  dy=flr(key/mapwidth)+0.5-posy
  distance=sqrt(dx*dx+dy*dy)
  add(sortedobjects, distance)
  add(sortedobjects, key)
 end
 sort(sortedobjects)

 invdet=1.0/(planex*diry-dirx*planey)
 
 -- render all the objects we saw
 i=2
 objectsseen={}
 while (i<=#sortedobjects) do
  key=sortedobjects[i]
  -- calc world coords from tile coords
  spritex=key%mapwidth+0.5-posx
  spritey=flr(key/mapwidth)+0.5-posy

  -- xform to camera space
  transx=invdet*(diry*spritex-dirx*spritey)
  transy=invdet*(-planey*spritex+planex*spritey)
  
  -- infront of the camera
  if(transy>0) then  
   -- xform to screen space
   sx=127-flr((screenwidth/2)*(1+transx/transy))
   -- is the object on screen
   if(sx>0 and sx<screenwidth-1) then
    -- is the object closer than the wall
    if(transy < distances[127-sx]) then
     sy=56+(wallscale/2)/transy  
     size=3/transy
 	 
	 -- get the object type
     tile=objects[key]
	 
	 -- add this to the seen table
	 objectsseen[key]=1
	 
	 -- is this a soldier
     if(tile==59)then
	  drawsoldier(key,sx,sy,size)
	 else	 
      -- get sprite from tile  
      index=tile-38
      sprite=objecttable[index]
      drawspriteworld(sprite,sx,sy,size)
	 end
    end
   end
  end
  i+=2
 end
 
 -- don't need to test gun anymore
 testgun=0
end

function drawgun()
 palt(0,true)
 if(gunframe==0)then
  drawspriteworld(27,64,128-15,2)
 else
  drawspriteworld(28,64,128-15,2)
 end
end
 
function drawscore() 
 clip(0,128-15,128,15)
 drawnumber(5,128-7,score,5)
 clip(0,0,128,128-15)
end

function drawhealth()
 clip(0,128-15,128,15)
 drawnumber(34,128-7,health,3)
 clip(0,0,128,128-15)
end

function drawammo()
 clip(0,128-15,128,15)
 drawnumber(84,128-7,ammo,2)
 clip(0,0,128,128-15)
end

function drawnumber(x,y,value,digits)
 spacing=4
 x+=(digits-1)*spacing
 for i=0,digits do
  rectfill(x,y,x+spacing-1,y+5,1)
  if(i>0 and value==0) then
  else
   digit=value%10
   value=flr(value/10)
   print(digit,x,y,7)
  end
  x-=spacing
 end
end

-- draw a sprite on the 2d hud
function drawsprite(index, x, y)
 offset=index*4+1
 sx=spritedata[offset+0]
 sy=spritedata[offset+1]+64
 w=spritedata[offset+2]
 h=spritedata[offset+3]
 sspr(sx,sy,w,h,x,y,w*1,h*1)
end

-- draw a sprite in the 3d world
function drawspriteworld(index, x, y, size)
 offset=index*4+1
 sx=spritedata[offset+0]
 sy=spritedata[offset+1]+64
 w=spritedata[offset+2]
 h=spritedata[offset+3]
 sw=w*size
 sh=h*size
 sspr(sx,sy,w,h,x-sw/2,y-sh,sw,sh)
end

-- draw the collect/damage effect
function draweffects()
 if(damageeffect>0)then
  damageeffect-=1
  rectfill(0,0,127,15,8)
  rectfill(0,15,15,128-15,8)
  rectfill(128-15,15,127,128-15,8)
  rectfill(15,128-30,128-15,128-15,8)
 end
 if(health==0)then
  rectfill(0,0,127,127-15,8)
 end
end
