pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
local n="start_screen"u=nil r=true local e=false q=nil f=nil function _init()ef()Z()f=nil cartdata"maxosirus_pegball_data"local e={[0]=0,[1]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0,[9]=0,[10]=0,[11]=0,[12]=0}for e,n in pairs(e)do if dget(e)==0then dset(e,n)end end end function _update60()if n=="start_screen"then ee()if btnp(⬆)then r=not r elseif btnp(➡)then music(-1)e=false ef()Z()eb()er()i=0if r then n="power_choice"else n="classic"end u="classic"elseif btnp(⬅)then music(-1)e=false ef()Z()eb()er()i=0if r then n="power_choice"else n="time_trial"end u="time_trial"elseif btnp(⬇)then n="how_to_1"elseif btnp(❎)and btnp(🅾)then n="easter_egg"end elseif n=="power_choice"then if en>0then sfx(0)eH()en=en-1else if btnp(⬆)then v=1z=p.x n=u elseif btnp(➡)then v=2z=p.y n=u elseif btnp(⬅)then v=3z=p.j n=u elseif btnp(❎)then v=4z=p.D n=u elseif btnp(🅾)then v=5z=p.E n=u elseif btnp(⬇)then v=6z=p.F n=u end end elseif n=="how_to_1"then if btnp(⬆)then n="how_to_2"end elseif n=="how_to_2"then if btnp(➡)then n="how_to_3"elseif btnp(⬅)then n="how_to_1"end elseif n=="how_to_3"then if btnp(⬅)then n="how_to_2"elseif btnp(❎)then n="start_screen"end elseif n=="classic"or n=="time_trial"then e6()eI()eJ()el=0e9()eK()if f and f.o=="gravity_flip"then if o.r then if E>0then E=E-1else n="pause"end end end if f and f.o=="reshoot"then if F>0then F=F-1else n="pause"end end if f and f.o=="ball_start"and not o.r then G=G+1if G>=15then local e={26,51,77,102}o.l=e[flr(rnd(#e))+1]G=0end end if o.r then if o.a=="multiball"then for e in all(b)do e_(e,s)end em(o)else e_(o,s)em(o)end end if n=="classic"or n=="time_trial"then u=n end if d<=0and h<20and not o.r then n=u=="classic"and"game_over"or"trial_lost"elseif h==20then if f then if f.o=="multiball"then local e=true for n in all(b)do if not n.q then e=false break end end if e and(o.e>128or o.h>=120)then l=true n="pause"end elseif f.o=="expansion"then if not H and(o.e>128or o.h>=120)or o.t>=20then l=true H=false n="pause"end elseif f.o=="gravity_flip"then if o.r then if E<=0then l=true n="pause"elseif o.e>128then l=true n="pause"elseif o.h>=120then l=true n="pause"elseif(o.e>128or o.h>=120)and btn(❎)and abs(o.i)<.1then l=true n="pause"end end elseif f.o=="reshoot"then if F<=0then l=true n="pause"elseif o.e>128or o.h>=120then l=true n="pause"end elseif f.o=="rock_drop"then if o.r then local e=abs(o.d)<.01and abs(o.i-.08)<.01if o.e>128then l=true n="pause"elseif o.h>=120and e then l=true n="pause"end end elseif f.o=="magnet"then if o.e>128or o.h>=120then l=true n="pause"end elseif f.o=="boulder"then if o.e>128or o.h>=120then l=true n="pause"end else if o.e>128or o.h>=120then l=true n="pause"end end else if o.e>128or o.h>=120then l=true n="pause"end end end elseif n=="pause"then sfx(-1,et)e6()es=false E=k and 3660or 1830F=k and 3660or 1830eh=flr(rnd(10))+1if not eo then e4()eo=true end ea=ea+1if ea>=90then ea=0A=A+i if c+i<10000then c=c+i else local e=c+i _=_+flr(e/10000)c=e%10000end eL()e9()eM()i=0eo=false if l then l=false n=u=="classic"and"stage_clear"or"time_trial_complete"else n=u or"classic"end end elseif n=="game_over"or n=="trial_lost"then e2()i=0ee()if not L then eg()L=true end if btnp(❎)or btnp(🅾)then m,M,L=nil,nil,false e3()end elseif n=="time_trial_complete"then e2()i=0ee()ew()if not L then eg()L=true end if btnp(❎)or btnp(🅾)then m,M,L=nil,nil,false e3()end elseif n=="stage_clear"then e2()i=0ee()ew()if btnp(🅾)then music(-1)eN()ev()Z()ek()A=0i=0if not f then o.c=6end N=N+1en=90ec=ec+1if ec%3==0and r then n="power_choice"else n=u end end end end function _draw()cls(1)if n=="start_screen"then eO()elseif n=="classic"or n=="time_trial"then eP()ex()ey()if n=="classic"then print("score:"..O.._..P..c,10,0,7) 
elseif n=="time_trial"then print("time:"..ei(),10,0,7) 
end print(i,10,10,7) 
 print("pegballs:"..d,75,0,7) 
if Q>0then print("x2!",27,10,12) 
end if f and f.o=="half_pts"then print("x1/2!",40,10,8) 
end if es then print("power peg!",77,10,11) 
end rectfill(121,10,128,128,0)ej()if f then local e={G=1,H=5,I=2,J=3,K=4,L=6,M=7,N=8,R=17,S=18,T=19,O=20,U=21,V=22,W=23,X=24,P=9,Y=25,Z=26,ee=10}local e=e[f.o]if e then spr(e,120,0)end if f.o=="paddle"then rectfill(x-18,126,x+18,128,7)elseif f.o=="gravity_flip"and o.r and E>0then print("hold ❎   countdown: "..flr(E/60).." sec",11,120,7) 
elseif f.o=="reshoot"and F>0then print("countdown: "..flr(F/60).." sec",12,120,7) 
elseif f.o=="ball_move"and not o.r then print("move left ⬇ ⬆ move right",13,120,7) 
end end eq()ez()eA()eB()elseif n=="how_to_1"then eQ()elseif n=="how_to_2"then eR()elseif n=="how_to_3"then eS()elseif n=="pause"then rectfill(121,10,128,128,0)ej()ey()ez()eA()eB()if u=="classic"then print("score:"..O.._..P..c,10,0,7) 
else print("time:"..ei(),10,0,7) 
end eq()eT()else local e={en=eU,el=eV,et=eW,eo=eX,ea=eY,ei=function() print("easter egg found!",31,20,7) 
 print("-- cheat menu --",20,40,7) 
 print("⬆ start with 16 balls:",5,50,7) 
 print("➡ 'big head' mode:",5,60,7) 
 print("⬅ extended countdown:",5,70,7) 
 print("press ⬇ to exit",31,120,7) 
 print("❎ and ⬇ to reset records",5,80,7) 
if btnp(⬆)then B=not B end print(B and"on!"or"off",100,50,B and 11or 8) 
if btnp(➡)then g=not g end print(g and"on!"or"off",100,60,g and 11or 8) 
if btnp(⬅)then k=not k end print(k and"on!"or"off",100,70,k and 11or 8) 
if btnp(⬇)then n="start_screen"end if btnp(❎)and btnp(⬇)then for e=0,12do dset(e,0)end end end}if e[n]then e[n]()end end end B,g,k,eh=false,false,false,nil function eb()if B==true then d=d+6end end function ef()ev()d,c,N,ec,_=10,0,1,0,0O,P,m,M="00000","0000",nil,nil eZ,es,nd,n1,L=false,false,false,false,false x,C,E,F,en,v=64,2,1830,1830,90,nil end function ev()cls()o.l,o.e,o.d,o.i=64,10,0,0o.r,a=false,.75A,eo,nf,h=0,false,0,0o._,o.m,o.h=o.l,o.e,0R,eC,eu,I,eh=0,nil,false,0,nil local e={G=4,H=14,I=6,J=13,K=10,L=3,M=2,N=0,O=8,P=7}o.c=e[o.a]or 6if o.a=="boulder"then o.t=8elseif g then o.t=5else o.t=2end end function e3()er()i,n,u=0,"start_screen",nil end function eO()cls(2) print("pegball",50,5,7) 
 print("by maxosirus and dinoboy",18,15,6) 
 print("➡ peg-a-thon",65,60,7) 
 print("peg rush ⬅",15,60,7) 
local e=r and"enabled"or"disabled" print("power-ups?",43,30,7) 
 print("⬆",58,50,7) 
 print(e,47,40,r and 11or 8) 
 print("how to?",49,80,7) 
 print("⬇",58,70,7) 
local e=r and{0,1,3,4,5,11}or{6,7,8,9,10,12}local e,n,l,t,a,i,o=dget(e[1]),dget(e[2]),dget(e[3]),dget(e[4]),dget(e[5]),dget(e[6]),function(e)return(e<1000and"0"or"")..(e<100and"0"or"")..(e<10and"0"or"")..e end print("hi score",89,90,7) 
 print(e+n==0and"no record"or o(e)..o(n),89,100,7) 
 print("best time",4,90,7) 
 print((l>0or t>0)and"  "..l.."m "..t.."s"or"no record",4,100,7) 
 print("stages:",16,115,7) 
 print("100% cleared= "..a,48,110,7) 
 print("hi reached= "..i,48,120,7) 
if B or g or k then print("cheats",50,90,12) 
 print("active",50,100,12) 
end end function eU()cls(2) print("high risk/reward press ⬆",10,2,7) 
e5(p.x,18,10) print("medium risk/reward press ➡",10,21,7) 
e5(p.y,18,29) print("low risk/reward press ⬅",10,40,7) 
e5(p.j,18,48) print("overdrive press ❎",10,59,7) 
 print("all power-ups only",20,69,7) 
 print("gauntlet press 🅾",10,79,7) 
 print("all curses only",20,89,7) 
 print("potluck press ⬇",10,99,7) 
 print("all powers/curses active",20,109,7) 
 print("select again every 3 stages",11,120,7) 
end function e5(e,n,l)for e,t in ipairs(e)do spr(ne(t),n+(e-1)*20,l)end end function ne(e)local n={[1]=1,[2]=5,[3]=2,[4]=3,[5]=4,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=17,[12]=18,[13]=19,[14]=20,[15]=21,[16]=22,[17]=23,[18]=24,[19]=25,[20]=26}return n[e]or 0end function eV()cls(2) print("game over",46,10,8) 
 print("press 🅾 or ❎ to restart",15,120,7) 
 print("stage reached: "..N,32,55,7) 
 print("time elapsed: "..ei(),25,65,7) 
 print("total points: "..O.._..P..c,20,85,7) 
local e=95if m then for n=1,#m do print(m[n],34,e,10) 
e=e+10end end if M then print(M,29,e,10) 
end end function eY()cls(2) print("peg rush completed!",27,10,7) 
 print("press ❎ or 🅾 to restart",15,120,7) 
 print("time elapsed: "..ei(),23,65,7) 
 print("total points: "..O.._..P..c,19,85,7) 
local e=34if m then for n=1,#m do local n=m[n]local l=#n*4 local l=(128-l)/2 print(n,l,e,10) 
e=e+10end end end function eX()cls(2) print("peg rush lost!",35,10,8) 
 print("try again",44,20,8) 
 print("press 🅾 or ❎ to restart",15,120,7) 
end function eW()cls(2) print("stage "..N.." clear!",39,10,11) 
 print("new stage generating...",23,20,7) 
 print("total score = "..O.._..P..c,21,35,7) 
 print("points this stage = "..A,15,45,7) 
 print("balls at end of stage: "..d,12,55,7) 
 print("pegballs earned = "..flr(A/1500),25,65,7) 
 print("press 🅾 to begin next stage",9,85,7) 
if flr(A/1500)+d>=16then print("balls for next stage: 16 (max!)",2,75,7) 
else print("balls for next stage: "..flr(A/1500)+d,15,75,7) 
end if eh==8then print("hint: easter egg on start screen",0,95,12) 
end if I==29then print("stage 100% cleared!",28,110,7) 
 print("+1 ball has already been added",4,120,7) 
end end function ez()rectfill(0,0,8,128,0)spr(48,0,2)for e=8,112,8do spr(49,0,e)end spr(49,0,115)spr(50,0,119)end function ej()rectfill(7,-1,8,130,0)rectfill(120,-1,121,130,0)rectfill(-1,-2,129,-1,0)for e=8,18,9do rectfill(120,e,129,e+1,0)end for e=0,19do local n=127-e*5.45rectfill(126,flr(n),128,flr(n-3.45),e<h and 9or 7)end end function e9()O=_<10and"000"or _<100and"00"or _<1000and"0"or""P=c<10and"000"or c<100and"00"or c<1000and"0"or""end function eQ()cls(1) print("⬅ aim left   aim right ➡",15,50,7) 
 print("hold 🅾 for precise aim",20,60,7) 
 print("❎ to fire",44,70,7) 
 print("obj: clear all goal pegs",10,80,7) 
spr(55,110,78) print("hit   to earn double points!",8,90,7) 
spr(57,21,88) print("hit   to for powers/curses!",10,100,7) 
spr(58,23,98) print("hit   for some points too",12,110,7) 
spr(56,25,108) print("press ⬆ for next page",18,120,7) 
if not o.r then o.e,o.d,o.i,o.r=10,0,0,false eD()ex()nn()if btnp(❎)then o.r=true o.d=cos(a)*2o.i=sin(a)*2end else o.i=o.i+.1o.l=o.l+o.d o.e=o.e+o.i if o.e>128or o.l<0or o.l>128then o.r=false o.l=64o.e=10end end circfill(o.l,o.e,o.t or 2,o.c or 7)end function eR()cls(1)local e={{2,0,"low tier power-ups:"},{12,9,"sniper, high velocity shot",5},{12,19,"threepeat, ball falls thrice",6},{12,29,"move the ball left or right",10},{2,37,"mid tier power-ups:"},{12,46,"boulder, smashes thru pegs",1},{12,56,"paddle, keep the ball in play",2},{12,66,"multiball, 3 balls shoot out",4},{12,76,"expansion, grows and consumes",7},{2,84,"high tier power-ups:"},{12,93,"magnet, seeks out goal pegs",3},{12,103,"gravity flip, hold ❎ to flip",8},{12,113,"reshoot, launch from each peg",9}}for n,e in pairs(e)do print(e[3],e[1],e[2],7) 
if e[4]then spr(e[4],3,e[2]-2)end end print("prevous page ⬅ ➡ next page",8,120,7) 
end function eS()cls(1)local e={{2,0,"curses:"},{12,9,"no reticle, but can still aim",17},{12,19,"random aim, timing is key",18},{12,29,"partial aim increments",21},{12,39,"wobbly, but can still aim",26},{12,54,"half points this shot",19},{12,64,"ball moves randomly",24},{12,74,"drop like a rock, no bounce",20},{12,89,"all pegs look the same",22},{12,99,"a mirage of pegs",25},{12,109,"all pegs shuffle to new spots",23}}for n,e in pairs(e)do print(e[3],e[1],e[2],7) 
if e[4]then spr(e[4],3,e[2]-2)end end print("prevous page ⬅ ❎ start screen",3,120,7) 
end o={l=64,e=10,d=0,i=0,p=2,r=false,t=2,c=6}G=0 function eK()if not o.r then local e=btn(🅾)and.001or.008if f and f.o=="random_aim"then if not y then y=1end local e=.03*y a=a+e if a>=1.25then a=1.25y=-1elseif a<=.25then a=.25y=1end elseif f and f.o=="partial_aim"then local n={.25,.35,.45,.65,.85,1.05,1.15,1.25}if not U then a=.65U=true end local e=1for n,l in ipairs(n)do if abs(a-l)<.05then e=n break end end if btnp(⬅)and e>1then e=e-1elseif btnp(➡)and e<#n then e=e+1end a=n[e]elseif f and f.o=="wobble_aim"then if not e0 then e0=0end e0=e0+.05 local e=0if btn(⬅)then e=e-.008elseif btn(➡)then e=e+.008end local n=sin(e0)*.02a=a+(e+n)elseif f and f.o=="ball_move"and o.r==false then if btn(⬇)then sfx(12)o.l=o.l-1elseif btn(⬆)then sfx(12)o.l=o.l+1end if o.l<=12then o.l=12elseif o.l>=116then o.l=116end if btn(⬅)then a=a-e elseif btn(➡)then a=a+e end else U=false if btn(⬅)then a=a-e elseif btn(➡)then a=a+e end end a=mid(.25,a,1.25)if btnp(❎)then sfx(13)if o.a=="multiball"then local e,l={-.15,0,.15},{2,3,4}b={}for n=1,#e do add(b,{l=o.l,e=o.e,d=cos(a+e[n])*o.p,i=sin(a+e[n])*o.p,t=l[n],r=true,_=o.l,m=o.e,h=0})end o.r=true else o.d=cos(a)*o.p o.i=sin(a)*o.p o.r=true end end end end function eP()if f and f.o=="no_aim"then return elseif not o.r then eD()end end function nn()local e=btn(🅾)and.001or.008if f and f.o=="random_aim"then if not y then y=1end a=a+.03*y if a>=1.25then a=1.25y=-1elseif a<=.25then a=.25y=1end elseif f and f.o=="partial_aim"then local n={.25,.35,.45,.65,.85,1.05,1.15,1.25}if not U then a=.65U=true end local e=1for n,l in ipairs(n)do if abs(a-l)<.05then e=n break end end if btnp(⬅)and e>1then e=e-1elseif btnp(➡)and e<#n then e=e+1end a=n[e]else U=false if btn(⬅)then a=a-e elseif btn(➡)then a=a+e end end a=mid(.25,a,1.25)end function nr()if btnp(❎)then o.d=cos(a)*o.p o.i=sin(a)*o.p o.r=true end end function ex()if o.a=="multiball"then if not o.r then circfill(o.l,o.e,o.t,o.c)else for e in all(b)do circfill(e.l,e.e,e.t,o.c)end end else circfill(o.l,o.e,o.t,o.c)end end function eD()local e,n,l,t=o.l,o.e,cos(a)*o.p,sin(a)*o.p for o=1,150do l=l t=t+.008e=e+l*.1n=n+t*.1pset(e,n,2)end end function ns()if o.e>128then if d>0then n="pause"else o.r=false end end end function eL()local e={{19500,12},{18000,11},{16500,10},{15000,9},{13500,8},{12000,7},{10500,6},{9000,5},{7500,4},{6000,3},{4500,2},{3000,1}}if i<1500then d=d-1else for n,e in ipairs(e)do if i>=e[1]then d=d+e[2]break end end end d=min(d,16)if h==20and I==29then d=d+1end end function eM()b={}o.r,o.a,o.c,o.d,o.i,C,nh=false,nil,6,0,0,2,0o.t=g and 5or 2S={}e4()if h==20then l=true if not o.r and(o.e>128or o.h>=120)then n="pause"end end if R<4then R=R+1end if R==4and r then if D and D.f=="dead"then J(1,w.w.u,"power")for e in all(s)do if e.s=="power"then D=e break end end elseif D and D.f=="active"then del(s,D)J(1,w.w.u,"power")for e in all(s)do if e.s=="power"then D=e break end end end R=0end local e={}for n in all(s)do if n.f=="active"then add(e,n)end end s=e if f then ed()end if q then nl(q)q=nil else o.c=6end if d<=0then n="game_over"return end if f and f.o=="ball_start"then local e={26,51,77,102}G=(G+1)%45if G==0then o.l=e[flr(rnd(#e))+1]end else o.l=64end o.e,o.d,o.i,o.r=10,0,0,false nt()ek()T,V,H,e1=nil,nil,false,false end function eA()for e=1,d-1do local e=128-e*8circfill(3,e,2,6)end end s={}w={z={b=29,u=5},A={b=20,u=9},g={b=1,u=12},w={b=1,u=11}}S={}function ep(e,n)for l in all(s)do local e=sqrt((l.l-e)^2+(l.e-n)^2)if e<6then return false end end for l in all(S)do local e=sqrt((l.l-e)^2+(l.e-n)^2)if e<6then return false end end return true end function Z()s={}J(w.z.b,w.z.u,"basic")J(w.A.b,w.A.u,"goal")J(w.g.b,w.g.u,"bonus")if r then J(1,w.w.u,"power")for e in all(s)do if e.s=="power"then D=e break end end else D=nil end if o.a=="peg_shuffle"then eE()end end function J(n,o,a)local e=0for n=1,n do local n,l,t=false while(not n)l=flr(rnd(107))+11t=flr(rnd(96))+20n=ep(l,t)e=e+1if e>1000then break end
if n then add(s,{l=l,e=t,u=o,s=a,f="active",t=2})end end end function nt()for e in all(s)do if e.s=="bonus"and e.f=="active"then del(s,e)break end end J(w.g.b,w.g.u,"bonus")end function ey()if o.a=="blind_peg"then for e in all(s)do if e.f=="active"then circfill(e.l,e.e,e.t,7)elseif e.f=="dead"then circ(e.l,e.e,e.t,7)end end else for e in all(s)do if e.f=="active"then circfill(e.l,e.e,e.t,e.u)elseif e.f=="dead"then circ(e.l,e.e,e.t,7)end end if o.a=="peg_mirage"then for e in all(S)do circfill(e.l,e.e,e.t,e.u)end end end end function eE()local e=0for n in all(s)do if n.f=="active"then local l,t,o=false while(not l)t=flr(rnd(107))+11o=flr(rnd(96))+20l=ep(t,o)e=e+1if e>1000then break end
if l then n.l=t n.e=o end end end end j,e7,I=0,0,0e8,h,Q,eF=0,0,0,0ea,eo,i,el,n2=0,false,0,0,0 local e=false function ek()e7,e8,Q,i=0,0,0,0end function er()j,I,h,nc,c=0,0,0,0,0ed()end function eJ()if j==nil then j=0end if W==nil then W=0end W=W+1if W>=60then j=j+1W=0end end function ei()local e,n=flr(j/60),j%60return e.."m "..n.."s"end function no()if h<=6then return 100,25elseif h<=11then return 200,50elseif h<=15then return 400,100else return 800,200end end function K(e)local n,l=no()if e=="basic"then e7=e7+1I=I+1i=i+l elseif e=="goal"then e8=e8+1h=h+1i=i+n elseif e=="bonus"then Q=Q+1eF=eF+1elseif e=="power"then eZ=true R=0if z then q=z[flr(rnd(#z))+1]elseif v==4then q=flr(rnd(10))+1elseif v==5then q=flr(rnd(10))+11elseif v==6then q=flr(rnd(20))+1end es=true end end function na(e,n)for l,e in pairs(e)do if e==n then return true end end return false end p={}function eH()local e={4,8,9}local e,n=e[flr(rnd(#e))+1],X({11,12,13,14,15,16,17,18,19,20},4)p.x={e,unpack(n)}local e={1,3,5,7}local e,n=X(e,2),X({11,12,13,14,15,16,17,18,19,20},3)p.y={e[1],e[2],unpack(n)}local n,e={2,6,10},{1,3,5,7}local n,e,l=X(n,2),e[flr(rnd(#e))+1],X({11,12,13,14,15,16,17,18,19,20},2)p.j={n[1],n[2],e,unpack(l)}p.D={1,2,3,4,5,6,7,8,9,10}p.E={11,12,13,14,15,16,17,18,19,20}p.F={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}end function X(n,l)local e={}while(#e<l)local n=n[flr(rnd(#n))+1]if not na(e,n)then add(e,n)end
return e end function e4()if Q>0then i=i*2end if f and f.o=="half_pts"then if i%2==0then i=i*.5else i=flr(i*.5)+1end end Q=0end function eN()el=flr(A/1500)if el+d>=16then d=16else d=d+el end end function eq()local e=min(flr(i/1500*107),107)if i>0then local n=i<=499and 9or i<=999and 10or i<1500and 11or(flr(time()*4)%2==0and 3or 7)rectfill(121,127,124,max(127-e,20),n)end end e=false function e6()if i>=1500then if not e then sfx(14)e=true end else if e then sfx(-1)e=false end end end function ee()if eC~=1then music(1)eC=1end end function e2()if e then sfx(-1)e=false end end function eT()local e="points this shot: "..i local n=(128-#e*4)/2 print(e,n,10,10) 
local e={{24000,"15 balls earned!"},{22500,"14 balls earned!"},{21000,"13 balls earned!"},{19500,"12 balls earned!"},{18000,"11 balls earned!"},{16500,"10 balls earned!"},{15000," 9 balls earned!"},{13500," 8 balls earned!"},{12000," 7 balls earned!"},{10500," 6 balls earned!"},{9000," 5 balls earned!"},{7500," 4 balls earned!"},{6000," 3 balls earned!"},{4500," 2 balls earned!"},{3000," 1 ball earned!"},{1500,"   ball saved!"}}for l,e in ipairs(e)do if i>=e[1]then print(e[2],n+12,20,10) 
break end end if flr(i/1500)+(d-1)>=16and i>=1500then print("max balls earned! (16 total)",10,30,10) 
end end function eB()local e=h>=16and"x8"or h>=12and"x4"or h>=7and"x2"or"x1" print(e,121,11,7) 
end function eg()if B or g or k then return end m={}M=nil local e,l,t,o,a=r and 0or 6,r and 1or 7,r and 3or 8,r and 4or 9,r and 11or 12if _>dget(e)or _==dget(e)and c>dget(l)then dset(e,_)dset(l,c)add(m,"new high score!")end if n=="time_trial_complete"then local e,l,n,a=dget(t),dget(o),flr(j/60),j%60if e==0and l==0or n<e or n==e and a<l then dset(t,n)dset(o,a)add(m,"new fastest time!")end end if N>dget(a)then dset(a,N)M="new highest stage!"end end eu=false function ew()if B or g or k then return end if eu or I~=29then return end local n=r and 5or 10 local e=dget(n)e=e+1dset(n,e)eu=true end T,V,H,e1,et=nil,nil,false,false,2 function e_(l,t)local o=.08if l.a=="gravity_flip"then if btn(❎)then o=-.08if not Y then sfx(16,et)Y=true end else o=.08if Y then sfx(-1,et)Y=false end end else if Y then sfx(-1,et)Y=false end end local e=l.a=="multiball"and b or{l}for e in all(e)do if e.r then e.i=e.i+o local i,d=e.d/5,e.i/5for a=1,5do local a=false e.l=e.l+i e.e=e.e+d if e.a=="boulder"then for n in all(t)do if n.f=="active"then local l,t=e.l-n.l,e.e-n.e local l,e=sqrt(l^2+t^2),e.t+n.t if l<e then n.f="dead"K(n.s)if n.s=="bonus"then sfx(10)elseif n.s=="power"then sfx(9)else sfx(0)end a=false end end end elseif e.a=="reshoot"then for l in all(t)do if l.f=="active"then local t,o=e.l-l.l,e.e-l.e local t,o=sqrt(t^2+o^2),e.t+l.t if t<o then l.f="dead"K(l.s)if l.s=="bonus"then sfx(10)elseif l.s=="power"then sfx(9)else sfx(0)end e.r=false if h==20and(e.e>128or e.h>=120)then n="pause"end end end end elseif e.a=="expansion"then if not H then T=nil V=nil e.t=l.t H=true eG=false end for n in all(t)do local l,o=e.l-n.l,e.e-n.e local l,o=sqrt(l^2+o^2),e.t+n.t if l<o then if not T then T=n.l V=n.e end e.l=T e.e=V e.d=0e.i=0e.e=e.e-.08if n.f=="active"then n.f="dead"K(n.s)if n.s=="bonus"then sfx(10)elseif n.s=="power"then sfx(9)else sfx(0)end end if e.i==0and H then e.t=e.t+.16if not eG then sfx(15,3)eG=true end for n in all(t)do if n.f=="active"then local l,t=e.l-n.l,e.e-n.e local l,e=sqrt(l^2+t^2),e.t+n.t if l<e then n.f="dead"K(n.s)if n.s=="bonus"then sfx(10)elseif n.s=="power"then sfx(9)else sfx(0)end end end end end return end end if e.t>=20then e.a=nil T=nil V=nil H=false sfx(-1,3)end elseif e.a=="rock_drop"then if not e1 then e1=false e.B=false end if not e.B then for n in all(t)do if n.f=="active"or n.f=="dead"then local t,a=e.l-n.l,e.e-n.e local l,i=sqrt(t^2+a^2),e.t+n.t if l<i then e.B=true e1=true local t,a,l=t/l,a/l,i-l e.l=e.l+t*l e.e=e.e+a*l e.d=0e.i=o if n.f=="active"then n.f="dead"K(n.s)if n.s=="bonus"then sfx(10)elseif n.s=="power"then sfx(9)else sfx(0)end end break end end end else e.d=0e.i=e.i+o for n in all(t)do if n.f=="active"or n.f=="dead"then local t,a=e.l-n.l,e.e-n.e local l,i=sqrt(t^2+a^2),e.t+n.t if l<i then local t,a,l=t/l,a/l,i-l e.l=e.l+t*l e.e=e.e+a*l e.d=0e.i=o if n.f=="active"then n.f="dead"K(n.s)if n.s=="bonus"then sfx(10)elseif n.s=="power"then sfx(9)else sfx(0)end end break end end end end elseif e.a=="magnet"then local n=ni(e,t)if n then local l,t=n.l-e.l,n.e-e.e local n=sqrt(l^2+t^2)if n>0and n<40then local l,n=l/n,t/n e.d=e.d+l*.115e.i=e.i+n*.115end end e.d=e.d*.98+rnd()*.1-.05e.i=e.i*.98+rnd()*.1-.05 local n=sqrt(e.d^2+e.i^2)if n>3.5then e.d=e.d/n*3.5e.i=e.i/n*3.5end end if e.a~="boulder"then for n in all(t)do if n and(n.f=="active"or n.f=="dead")then local t,o=e.l-n.l,e.e-n.e local l,i=sqrt(t^2+o^2),e.t+n.t if l<i then local t,o,l=t/l,o/l,i-l e.l=e.l+t*l e.e=e.e+o*l local l=e.d*t+e.i*o e.d=(e.d-2*l*t)*.84e.i=(e.i-2*l*o)*.84if n.f=="active"then n.f="dead"K(n.s)if n.s=="bonus"then sfx(10)elseif n.s=="power"then sfx(9)else sfx(0)end end a=true break end end end end if f and f.o=="threepeat"then if l.e>126and C>0then l.e=1C=C-1elseif l.e>126and C==0then end if C==2then l.c=3elseif C==1then l.c=11elseif C==0then l.c=6end end if f and f.o=="paddle"then if e.e+e.t>=126and e.e+e.t<=128and e.l>=x-19and e.l<=x+19then sfx(11)e.i=-abs(e.i)*1.05 local n=(e.l-x)/18e.d=e.d+n*.5e.e=126-e.t end end if e.l-e.t<=8then e.l=8+e.t e.d=-e.d*.9elseif e.l+e.t>=120then e.l=120-e.t e.d=-e.d*.9end if e.e-e.t<=0then e.e=e.t e.i=-e.i*.84end if e.e>128then e.q=true end if a then break end end end end if l.a=="multiball"then local e=true for n in all(b)do if not n.q then e=false break end end if e then b={}l.a=nil l.r=false n="pause"end end for e in all(t)do if e.v and e.v>0then e.v=e.v-1end end end function ni(n,e)local l,t=nil,9999for e in all(e)do if e.s=="goal"and e.f=="active"then local o,n=n.l-e.l,n.e-e.e local n=sqrt(o^2+n^2)if n<t then t=n l=e end end end return l end function em(e)local l=g and 5or 3if e.a=="multiball"then for e in all(b)do if not e.h then e.h=0end if e.e>128then del(b,e)elseif abs(e.l-e._)<l and abs(e.e-e.m)<l then e.h=e.h+1if e.h>=120then del(b,e)end else e.h=0e._=e.l e.m=e.e end end if#b==0then e.a=nil e.r=false n="pause"end else if abs(e.l-e._)<l and abs(e.e-e.m)<l then e.h=e.h+1else e.h=0e._=e.l e.m=e.e end if e.h>=120or e.e>128then e.h=0if d>0then n="pause"else n="game_over"end end end end q,f,nu=nil,nil,""b={}n0={[1]={o="boulder",t=8,c=4,a="boulder"},[2]={o="sniper",p=6,c=14},[3]={o="paddle",a="paddle",Q=64},[4]={o="magnet",a="magnet",c=13},[5]={o="multiball",a="multiball",c=10},[6]={o="threepeat",a="threepeat",c=3},[7]={o="expansion",a="expansion",c=2},[8]={o="gravity_flip",a="gravity_flip",c=0},[9]={o="reshoot",a="reshoot",c=7},[10]={o="ball_move",a="ball_move"},[11]={o="no_aim",a="no_aim"},[12]={o="random_aim",a="random_aim"},[13]={o="half_pts",a="half_pts"},[14]={o="rock_drop",a="rock_drop",c=8},[15]={o="partial_aim",a="partial_aim"},[16]={o="blind_peg",a="blind_peg"},[17]={o="peg_shuffle",a="peg_shuffle",k=eE},[18]={o="ball_start",a="ball_start"},[19]={o="peg_mirage",a="peg_mirage",k=function()S={}for e=1,50do local l,e,n=false while(not l)e=flr(rnd(107))+10n=flr(rnd(96))+20l=ep(e,n)
add(S,{l=e,e=n,t=2,u=flr(rnd(3))==0and 5or(rnd()<.5and 9or 12)})end end,C=function()S={}end},[20]={o="wobble_aim",a="wobble_aim"}}function nl(e)if f then ed()end local e=n0[e]if not e then return end o.a=e.a or o.a o.c=e.c or o.c o.t=e.t or o.t o.p=e.p or o.p x=e.Q or x if e.k then e.k()end f=e end function ed()if not f then return end o.a,o.c,o.t,o.p=nil,6,g and 5or 2,2if f.C then f.C()end f=nil end function n5()if f then ed()end end function eI()x=mid(27,x+(btn(➡)and 2.2or 0)-(btn(⬅)and 2.2or 0),101)end
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
__meta:title__
pegball--
by maxosirus and dinoboy
