pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
local n="start_screen"p=nil h=true local e=false q=nil f=nil function _init()ef()Z()f=nil cartdata"maxosirus_pegball_data"local e={[0]=0,[1]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0,[9]=0,[10]=0,[11]=0,[12]=0}for e,n in pairs(e)do if dget(e)==0do dset(e,n)end end end function _update60()if n=="start_screen"do ee()if btnp(2)do h=not h elseif btnp(1)do music(-1)e=false ef()Z()eb()er()d=0if h do n="power_choice"else n="classic"end p="classic"elseif btnp(0)do music(-1)e=false ef()Z()eb()er()d=0if h do n="power_choice"else n="time_trial"end p="time_trial"elseif btnp(3)do n="how_to_1"elseif btnp(5)and btnp(4)do n="easter_egg"end elseif n=="power_choice"do if en>0do sfx(0)eH()en=en-1else if btnp(2)do v=1z=b.x n=p elseif btnp(1)do v=2z=b.y n=p elseif btnp(0)do v=3z=b.j n=p elseif btnp(5)do v=4z=b.D n=p elseif btnp(4)do v=5z=b.E n=p elseif btnp(3)do v=6z=b.F n=p end end elseif n=="how_to_1"do if btnp(2)do n="how_to_2"end elseif n=="how_to_2"do if btnp(1)do n="how_to_3"elseif btnp(0)do n="how_to_1"end elseif n=="how_to_3"do if btnp(0)do n="how_to_2"elseif btnp(5)do n="start_screen"end elseif n=="classic"or n=="time_trial"do e6()eI()eJ()el=0e4()eK()if f and f.o=="gravity_flip"do if o.r do if F>0do F=F-1else n="pause"end end end if f and f.o=="reshoot"do if G>0do G=G-1else n="pause"end end if f and f.o=="ball_start"and not o.r do H=H+1if H>=15do local e={26,51,77,102}o.l=e[flr(rnd(#e))+1]H=0end end if o.r do if o.a=="multiball"do for e=1,#s do local e=s[e]e9(e,i)end e3(o)else e9(o,i)e3(o)end end if n=="classic"or n=="time_trial"do p=n end if r<=0and c<20and not o.r do n=p=="classic"and"game_over"or"trial_lost"elseif c==20do if f do if f.o=="multiball"do local e=true for n=1,#s do local n=s[n]if not n.q do e=false break end end if e and(o.e>128or o.h>=120)do l=true n="pause"end elseif f.o=="expansion"do if not I and(o.e>128or o.h>=120)or o.t>=20do l=true I=false n="pause"end elseif f.o=="gravity_flip"do if o.r do if F<=0do l=true n="pause"elseif o.e>128do l=true n="pause"elseif o.h>=120do l=true n="pause"elseif(o.e>128or o.h>=120)and btn(5)and abs(o.d)<.1do l=true n="pause"end end elseif f.o=="reshoot"do if G<=0do l=true n="pause"elseif o.e>128or o.h>=120do l=true n="pause"end elseif f.o=="rock_drop"do if o.r do local e=abs(o.i)<.01and abs(o.d-.08)<.01if o.e>128do l=true n="pause"elseif o.h>=120and e do l=true n="pause"end end elseif f.o=="magnet"do if o.e>128or o.h>=120do l=true n="pause"end elseif f.o=="boulder"do if o.e>128or o.h>=120do l=true n="pause"end else if o.e>128or o.h>=120do l=true n="pause"end end else if o.e>128or o.h>=120do l=true n="pause"end end end elseif n=="pause"do sfx(-1,et)e6()es=false F=k and 3660or 1830G=k and 3660or 1830eh=flr(rnd(10))+1if not eo do e_()eo=true end ea=ea+1if ea>=90do ea=0A=A+d if u+d<10000do u=u+d else local e=u+d _=_+flr(e/10000)u=e%10000end eL()e4()eM()d=0eo=false if l do l=false n=p=="classic"and"stage_clear"or"time_trial_complete"else n=p or"classic"end end elseif n=="game_over"or n=="trial_lost"do e2()d=0ee()if not M do em()M=true end if btnp(5)or btnp(4)do m,N,M=nil,nil,false eg()end elseif n=="time_trial_complete"do e2()d=0ee()ew()if not M do em()M=true end if btnp(5)or btnp(4)do m,N,M=nil,nil,false eg()end elseif n=="stage_clear"do e2()d=0ee()ew()if btnp(4)do music(-1)eN()ev()Z()ek()A=0d=0if not f do o.c=6end O=O+1en=90ec=ec+1if ec%3==0and h do n="power_choice"else n=p end end end end function _draw()cls(1)if n=="start_screen"do eO()elseif n=="classic"or n=="time_trial"do eP()ex()ey()if n=="classic"do?"score:"..P.._..Q..u,10,0,7
elseif n=="time_trial"do?"time:"..e1(),10,0,7
end?d,10,10,7
?"pegballs:"..r,75,0,7
if R>0do?"x2!",27,10,12
end if f and f.o=="half_pts"do?"x1/2!",40,10,8
end if es do?"power peg!",77,10,11
end rectfill(121,10,128,128,0)ej()if f do local e={G=1,H=5,I=2,J=3,K=4,L=6,M=7,N=8,R=17,S=18,T=19,O=20,U=21,V=22,W=23,X=24,P=9,Y=25,Z=26,ee=10}local e=e[f.o]if e do spr(e,120,0)end if f.o=="paddle"do rectfill(x-18,126,x+18,128,7)elseif f.o=="gravity_flip"and o.r and F>0do?"hold 5   countdown: "..flr(F/60).." sec",11,120,7
elseif f.o=="reshoot"and G>0do?"countdown: "..flr(G/60).." sec",12,120,7
elseif f.o=="ball_move"and not o.r do?"move left 3 2 move right",13,120,7
end end eq()ez()eA()eB()elseif n=="how_to_1"do eQ()elseif n=="how_to_2"do eR()elseif n=="how_to_3"do eS()elseif n=="pause"do rectfill(121,10,128,128,0)ej()ey()ez()eA()eB()if p=="classic"do?"score:"..P.._..Q..u,10,0,7
else?"time:"..e1(),10,0,7
end eq()eT()else local e={en=eU,el=eV,et=eW,eo=eX,ea=eY,e1=function()?"easter egg found!",31,20,7
?"-- cheat menu --",20,40,7
?"2 start with 16 balls:",5,50,7
?"1 'big head' mode:",5,60,7
?"0 extended countdown:",5,70,7
?"press 3 to exit",31,120,7
?"5 and 3 to reset records",5,80,7
if btnp(2)do B=not B end?B and"on!"or"off",100,50,B and 11or 8
if btnp(1)do g=not g end?g and"on!"or"off",100,60,g and 11or 8
if btnp(0)do k=not k end?k and"on!"or"off",100,70,k and 11or 8
if btnp(3)do n="start_screen"end if btnp(5)and btnp(3)do for e=0,12do dset(e,0)end end end}if e[n]do e[n]()end end end B,g,k,eh=false,false,false,nil function eb()if B==true do r=r+6end end function ef()ev()r,u,O,ec,_=10,0,1,0,0P,Q,m,N="00000","0000",nil,nil eZ,es,nd,ni,M=false,false,false,false,false x,C,F,G,en,v=64,2,1830,1830,90,nil end function ev()cls()o.l,o.e,o.i,o.d=64,10,0,0o.r,a=false,.75A,eo,nf,c=0,false,0,0o._,o.m,o.h=o.l,o.e,0S,eC,eu,J,eh=0,nil,false,0,nil local e={G=4,H=14,I=6,J=13,K=10,L=3,M=2,N=0,O=8,P=7}o.c=e[o.a]or 6if o.a=="boulder"do o.t=8elseif g do o.t=5else o.t=2end end function eg()er()d,n,p=0,"start_screen",nil end function eO()cls(2)?"pegball",50,5,7
?"by maxosirus and dinoboy",18,15,6
?"1 peg-a-thon",65,60,7
?"peg rush 0",15,60,7
local e=h and"enabled"or"disabled"?"power-ups?",43,30,7
?"2",58,50,7
?e,47,40,h and 11or 8
?"how to?",49,80,7
?"3",58,70,7
local e=h and{0,1,3,4,5,11}or{6,7,8,9,10,12}local e,n,l,t,a,d=dget(e[1]),dget(e[2]),dget(e[3]),dget(e[4]),dget(e[5]),dget(e[6])local o=function(e)return(e<1000and"0"or"")..(e<100and"0"or"")..(e<10and"0"or"")..e end?"hi score",89,90,7
?e+n==0and"no record"or o(e)..o(n),89,100,7
?"best time",4,90,7
?(l>0or t>0)and"  "..l.."m "..t.."s"or"no record",4,100,7
?"stages:",16,115,7
?"100% cleared= "..a,48,110,7
?"hi reached= "..d,48,120,7
if B or g or k do?"cheats",50,90,12
?"active",50,100,12
end end function eU()cls(2)?"high risk/reward press 2",10,2,7
e5(b.x,18,10)?"medium risk/reward press 1",10,21,7
e5(b.y,18,29)?"low risk/reward press 0",10,40,7
e5(b.j,18,48)?"overdrive press 5",10,59,7
?"all power-ups only",20,69,7
?"gauntlet press 4",10,79,7
?"all curses only",20,89,7
?"potluck press 3",10,99,7
?"all powers/curses active",20,109,7
?"select again every 3 stages",11,120,7
end function e5(e,n,l)for e,t in ipairs(e)do spr(ne(t),n+(e-1)*20,l)end end function ne(e)local n={[1]=1,[2]=5,[3]=2,[4]=3,[5]=4,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=17,[12]=18,[13]=19,[14]=20,[15]=21,[16]=22,[17]=23,[18]=24,[19]=25,[20]=26}return n[e]or 0end function eV()cls(2)?"game over",46,10,8
?"press 4 or 5 to restart",15,120,7
?"stage reached: "..O,32,55,7
?"time elapsed: "..e1(),25,65,7
?"total points: "..P.._..Q..u,20,85,7
local e=95if m do for n=1,#m do?m[n],34,e,10
e=e+10end end if N do?N,29,e,10
end end function eY()cls(2)?"peg rush completed!",27,10,7
?"press 5 or 4 to restart",15,120,7
?"time elapsed: "..e1(),23,65,7
?"total points: "..P.._..Q..u,19,85,7
local e=34if m do for n=1,#m do local n=m[n]local l=#n*4local l=(128-l)/2?n,l,e,10
e=e+10end end end function eX()cls(2)?"peg rush lost!",35,10,8
?"try again",44,20,8
?"press 4 or 5 to restart",15,120,7
end function eW()cls(2)?"stage "..O.." clear!",39,10,11
?"new stage generating...",23,20,7
?"total score = "..P.._..Q..u,21,35,7
?"points this stage = "..A,15,45,7
?"balls at end of stage: "..r,12,55,7
?"pegballs earned = "..flr(A/1500),25,65,7
?"press 4 to begin next stage",9,85,7
if flr(A/1500)+r>=16do?"balls for next stage: 16 (max!)",2,75,7
else?"balls for next stage: "..flr(A/1500)+r,15,75,7
end if eh==8do?"hint: easter egg on start screen",0,95,12
end if J==29do?"stage 100% cleared!",28,110,7
?"+1 ball has already been added",4,120,7
end end function ez()rectfill(0,0,8,128,0)spr(48,0,2)for e=8,112,8do spr(49,0,e)end spr(49,0,115)spr(50,0,119)end function ej()rectfill(7,-1,8,130,0)rectfill(120,-1,121,130,0)rectfill(-1,-2,129,-1,0)for e=8,18,9do rectfill(120,e,129,e+1,0)end for e=0,19do local n=127-e*5.45rectfill(126,flr(n),128,flr(n-3.45),e<c and 9or 7)end end function e4()P=_<10and"000"or _<100and"00"or _<1000and"0"or""Q=u<10and"000"or u<100and"00"or u<1000and"0"or""end function eQ()cls(1)?"0 aim left   aim right 1",15,50,7
?"hold 4 for precise aim",20,60,7
?"5 to fire",44,70,7
?"obj: clear all goal pegs",10,80,7
spr(55,110,78)?"hit   to earn double points!",8,90,7
spr(57,21,88)?"hit   to for powers/curses!",10,100,7
spr(58,23,98)?"hit   for some points too",12,110,7
spr(56,25,108)?"press 2 for next page",18,120,7
if not o.r do o.e,o.i,o.d,o.r=10,0,0,false eD()ex()nn()if btnp(5)do o.r=true o.i=cos(a)*2o.d=sin(a)*2end else o.d=o.d+.1o.l=o.l+o.i o.e=o.e+o.d if o.e>128or o.l<0or o.l>128do o.r=false o.l=64o.e=10end end circfill(o.l,o.e,o.t or 2,o.c or 7)end function eR()cls(1)local e={{2,0,"low tier power-ups:"},{12,9,"sniper, high velocity shot",5},{12,19,"threepeat, ball falls thrice",6},{12,29,"move the ball left or right",10},{2,37,"mid tier power-ups:"},{12,46,"boulder, smashes thru pegs",1},{12,56,"paddle, keep the ball in play",2},{12,66,"multiball, 3 balls shoot out",4},{12,76,"expansion, grows and consumes",7},{2,84,"high tier power-ups:"},{12,93,"magnet, seeks out goal pegs",3},{12,103,"gravity flip, hold 5 to flip",8},{12,113,"reshoot, launch from each peg",9}}for n,e in pairs(e)do?e[3],e[1],e[2],7
if e[4]do spr(e[4],3,e[2]-2)end end?"prevous page 0 1 next page",8,120,7
end function eS()cls(1)local e={{2,0,"curses:"},{12,9,"no reticle, but can still aim",17},{12,19,"random aim, timing is key",18},{12,29,"partial aim increments",21},{12,39,"wobbly, but can still aim",26},{12,54,"half points this shot",19},{12,64,"ball moves randomly",24},{12,74,"drop like a rock, no bounce",20},{12,89,"all pegs look the same",22},{12,99,"a mirage of pegs",25},{12,109,"all pegs shuffle to new spots",23}}for n,e in pairs(e)do?e[3],e[1],e[2],7
if e[4]do spr(e[4],3,e[2]-2)end end?"prevous page 0 5 start screen",3,120,7
end o={l=64,e=10,i=0,d=0,p=2,r=false,t=2,c=6}H=0function eK()if not o.r do local e=btn(4)and.001or.008if f and f.o=="random_aim"do if not y do y=1end local e=.03*y a=a+e if a>=1.25do a=1.25y=-1elseif a<=.25do a=.25y=1end elseif f and f.o=="partial_aim"do local n={.25,.35,.45,.65,.85,1.05,1.15,1.25}if not U do a=.65U=true end local e=1for n,l in ipairs(n)do if abs(a-l)<.05do e=n break end end if btnp(0)and e>1do e=e-1elseif btnp(1)and e<#n do e=e+1end a=n[e]elseif f and f.o=="wobble_aim"do if not e0 do e0=0end e0=e0+.05local e=0if btn(0)do e=e-.008elseif btn(1)do e=e+.008end local n=sin(e0)*.02a=a+(e+n)elseif f and f.o=="ball_move"and o.r==false do if btn(3)do sfx(12)o.l=o.l-1elseif btn(2)do sfx(12)o.l=o.l+1end if o.l<=12do o.l=12elseif o.l>=116do o.l=116end if btn(0)do a=a-e elseif btn(1)do a=a+e end else U=false if btn(0)do a=a-e elseif btn(1)do a=a+e end end a=mid(.25,a,1.25)if btnp(5)do sfx(13)if o.a=="multiball"do local e={-.15,0,.15}local l={2,3,4}s={}for n=1,#e do add(s,{l=o.l,e=o.e,i=cos(a+e[n])*o.p,d=sin(a+e[n])*o.p,t=l[n],r=true,_=o.l,m=o.e,h=0})end o.r=true else o.i=cos(a)*o.p o.d=sin(a)*o.p o.r=true end end end end function eP()if f and f.o=="no_aim"do return elseif not o.r do eD()end end function nn()local e=btn(4)and.001or.008if f and f.o=="random_aim"do if not y do y=1end a=a+.03*y if a>=1.25do a=1.25y=-1elseif a<=.25do a=.25y=1end elseif f and f.o=="partial_aim"do local n={.25,.35,.45,.65,.85,1.05,1.15,1.25}if not U do a=.65U=true end local e=1for n,l in ipairs(n)do if abs(a-l)<.05do e=n break end end if btnp(0)and e>1do e=e-1elseif btnp(1)and e<#n do e=e+1end a=n[e]else U=false if btn(0)do a=a-e elseif btn(1)do a=a+e end end a=mid(.25,a,1.25)end function nr()if btnp(5)do o.i=cos(a)*o.p o.d=sin(a)*o.p o.r=true end end function ex()if o.a=="multiball"do if not o.r do circfill(o.l,o.e,o.t,o.c)else for e=1,#s do local e=s[e]circfill(e.l,e.e,e.t,o.c)end end else circfill(o.l,o.e,o.t,o.c)end end function eD()local e,n,l,t=o.l,o.e,cos(a)*o.p,sin(a)*o.p for o=1,150do l=l t=t+.008e=e+l*.1n=n+t*.1pset(e,n,2)end end function ns()if o.e>128do if r>0do n="pause"else o.r=false end end end function eL()local e={{19500,12},{18000,11},{16500,10},{15000,9},{13500,8},{12000,7},{10500,6},{9000,5},{7500,4},{6000,3},{4500,2},{3000,1}}if d<1500do r=r-1else for n,e in ipairs(e)do if d>=e[1]do r=r+e[2]break end end end r=min(r,16)if c==20and J==29do r=r+1end end function eM()s={}o.r,o.a,o.c,o.i,o.d,C,nh=false,nil,6,0,0,2,0o.t=g and 5or 2D={}e_()if c==20do l=true if not o.r and(o.e>128or o.h>=120)do n="pause"end end if S<4do S=S+1end if S==4and h do if E and E.f=="dead"do K(1,w.w.u,"power")for e=1,#i do local e=i[e]if e.s=="power"do E=e break end end elseif E and E.f=="active"do del(i,E)K(1,w.w.u,"power")for e=1,#i do local e=i[e]if e.s=="power"do E=e break end end end S=0end local e={}for n=1,#i do local n=i[n]if n.f=="active"do add(e,n)end end i=e if f do ed()end if q do nl(q)q=nil else o.c=6end if r<=0do n="game_over"return end if f and f.o=="ball_start"do local e={26,51,77,102}H=(H+1)%45if H==0do o.l=e[flr(rnd(#e))+1]end else o.l=64end o.e,o.i,o.d,o.r=10,0,0,false nt()ek()T,V,I,ei=nil,nil,false,false end function eA()for e=1,r-1do local e=128-e*8circfill(3,e,2,6)end end i={}w={z={b=29,u=5},A={b=20,u=9},g={b=1,u=12},w={b=1,u=11}}D={}function ep(e,n)for l=1,#i do local l=i[l]local e=sqrt((l.l-e)^2+(l.e-n)^2)if e<6do return false end end for l=1,#D do local l=D[l]local e=sqrt((l.l-e)^2+(l.e-n)^2)if e<6do return false end end return true end function Z()i={}K(w.z.b,w.z.u,"basic")K(w.A.b,w.A.u,"goal")K(w.g.b,w.g.u,"bonus")if h do K(1,w.w.u,"power")for e=1,#i do local e=i[e]if e.s=="power"do E=e break end end else E=nil end if o.a=="peg_shuffle"do eE()end end function K(n,o,a)local e=0for n=1,n do local n=false local l,t while(not n)l=flr(rnd(107))+11t=flr(rnd(96))+20n=ep(l,t)e=e+1if e>1000do break end
if n do add(i,{l=l,e=t,u=o,s=a,f="active",t=2})end end end function nt()for e=1,#i do local e=i[e]if e.s=="bonus"and e.f=="active"do del(i,e)break end end K(w.g.b,w.g.u,"bonus")end function ey()if o.a=="blind_peg"do for e=1,#i do local e=i[e]if e.f=="active"do circfill(e.l,e.e,e.t,7)elseif e.f=="dead"do circ(e.l,e.e,e.t,7)end end else for e=1,#i do local e=i[e]if e.f=="active"do circfill(e.l,e.e,e.t,e.u)elseif e.f=="dead"do circ(e.l,e.e,e.t,7)end end if o.a=="peg_mirage"do for e=1,#D do local e=D[e]circfill(e.l,e.e,e.t,e.u)end end end end function eE()local e=0for n=1,#i do local n=i[n]if n.f=="active"do local l=false local t,o while(not l)t=flr(rnd(107))+11o=flr(rnd(96))+20l=ep(t,o)e=e+1if e>1000do break end
if l do n.l=t n.e=o end end end end j,e7,J=0,0,0e8,c,R,eF=0,0,0,0ea,eo,d,el,n2=0,false,0,0,0local e=false function ek()e7,e8,R,d=0,0,0,0end function er()j,J,c,nc,u=0,0,0,0,0ed()end function eJ()if j==nil do j=0end if W==nil do W=0end W=W+1if W>=60do j=j+1W=0end end function e1()local e=flr(j/60)local n=j%60return e.."m "..n.."s"end function no()if c<=6do return 100,25elseif c<=11do return 200,50elseif c<=15do return 400,100else return 800,200end end function L(e)local n,l=no()if e=="basic"do e7=e7+1J=J+1d=d+l elseif e=="goal"do e8=e8+1c=c+1d=d+n elseif e=="bonus"do R=R+1eF=eF+1elseif e=="power"do eZ=true S=0if z do q=z[flr(rnd(#z))+1]elseif v==4do q=flr(rnd(10))+1elseif v==5do q=flr(rnd(10))+11elseif v==6do q=flr(rnd(20))+1end es=true end end function na(e,n)for l,e in pairs(e)do if e==n do return true end end return false end b={}function eH()local e={4,8,9}local e=e[flr(rnd(#e))+1]local n=X({11,12,13,14,15,16,17,18,19,20},4)b.x={e,unpack(n)}local e={1,3,5,7}local e=X(e,2)local n=X({11,12,13,14,15,16,17,18,19,20},3)b.y={e[1],e[2],unpack(n)}local n={2,6,10}local e={1,3,5,7}local n=X(n,2)local e=e[flr(rnd(#e))+1]local l=X({11,12,13,14,15,16,17,18,19,20},2)b.j={n[1],n[2],e,unpack(l)}b.D={1,2,3,4,5,6,7,8,9,10}b.E={11,12,13,14,15,16,17,18,19,20}b.F={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}end function X(n,l)local e={}while(#e<l)local n=n[flr(rnd(#n))+1]if not na(e,n)do add(e,n)end
return e end function e_()if R>0do d=d*2end if f and f.o=="half_pts"do if d%2==0do d=d*.5else d=flr(d*.5)+1end end R=0end function eN()el=flr(A/1500)if el+r>=16do r=16else r=r+el end end function eq()local e=min(flr(d/1500*107),107)if d>0do local n=d<=499and 9or d<=999and 10or d<1500and 11or(flr(time()*4)%2==0and 3or 7)rectfill(121,127,124,max(127-e,20),n)end end e=false function e6()if d>=1500do if not e do sfx(14)e=true end else if e do sfx(-1)e=false end end end function ee()if eC~=1do music(1)eC=1end end function e2()if e do sfx(-1)e=false end end function eT()local e="points this shot: "..d local n=(128-#e*4)/2?e,n,10,10
local e={{24000,"15 balls earned!"},{22500,"14 balls earned!"},{21000,"13 balls earned!"},{19500,"12 balls earned!"},{18000,"11 balls earned!"},{16500,"10 balls earned!"},{15000," 9 balls earned!"},{13500," 8 balls earned!"},{12000," 7 balls earned!"},{10500," 6 balls earned!"},{9000," 5 balls earned!"},{7500," 4 balls earned!"},{6000," 3 balls earned!"},{4500," 2 balls earned!"},{3000," 1 ball earned!"},{1500,"   ball saved!"}}for l,e in ipairs(e)do if d>=e[1]do?e[2],n+12,20,10
break end end if flr(d/1500)+(r-1)>=16and d>=1500do?"max balls earned! (16 total)",10,30,10
end end function eB()local e=c>=16and"x8"or c>=12and"x4"or c>=7and"x2"or"x1"?e,121,11,7
end function em()if B or g or k do return end m={}N=nil local e=h and 0or 6local l=h and 1or 7local t=h and 3or 8local o=h and 4or 9local a=h and 11or 12if _>dget(e)or _==dget(e)and u>dget(l)do dset(e,_)dset(l,u)add(m,"new high score!")end if n=="time_trial_complete"do local e,l=dget(t),dget(o)local n,a=flr(j/60),j%60if e==0and l==0or n<e or n==e and a<l do dset(t,n)dset(o,a)add(m,"new fastest time!")end end if O>dget(a)do dset(a,O)N="new highest stage!"end end eu=false function ew()if B or g or k do return end if eu or J~=29do return end local n=h and 5or 10local e=dget(n)e=e+1dset(n,e)eu=true end T,V,I,ei,et=nil,nil,false,false,2function e9(t,l)local o=.08if t.a=="gravity_flip"do if btn(5)do o=-.08if not Y do sfx(16,et)Y=true end else o=.08if Y do sfx(-1,et)Y=false end end else if Y do sfx(-1,et)Y=false end end local e=t.a=="multiball"and s or{t}for a=1,#e do local e=e[a]if e.r do e.d=e.d+o local d=e.i/5local i=e.d/5for a=1,5do local a=false e.l=e.l+d e.e=e.e+i if e.a=="boulder"do for n=1,#l do local n=l[n]if n.f=="active"do local l=e.l-n.l local t=e.e-n.e local l=sqrt(l^2+t^2)local e=e.t+n.t if l<e do n.f="dead"L(n.s)if n.s=="bonus"do sfx(10)elseif n.s=="power"do sfx(9)else sfx(0)end a=false end end end elseif e.a=="reshoot"do for t=1,#l do local l=l[t]if l.f=="active"do local t=e.l-l.l local o=e.e-l.e local t=sqrt(t^2+o^2)local o=e.t+l.t if t<o do l.f="dead"L(l.s)if l.s=="bonus"do sfx(10)elseif l.s=="power"do sfx(9)else sfx(0)end e.r=false if c==20and(e.e>128or e.h>=120)do n="pause"end end end end elseif e.a=="expansion"do if not I do T=nil V=nil e.t=t.t I=true eG=false end for n=1,#l do local n=l[n]local t=e.l-n.l local o=e.e-n.e local t=sqrt(t^2+o^2)local o=e.t+n.t if t<o do if not T do T=n.l V=n.e end e.l=T e.e=V e.i=0e.d=0e.e=e.e-.08if n.f=="active"do n.f="dead"L(n.s)if n.s=="bonus"do sfx(10)elseif n.s=="power"do sfx(9)else sfx(0)end end if e.d==0and I do e.t=e.t+.16if not eG do sfx(15,3)eG=true end for n=1,#l do local n=l[n]if n.f=="active"do local l=e.l-n.l local t=e.e-n.e local l=sqrt(l^2+t^2)local e=e.t+n.t if l<e do n.f="dead"L(n.s)if n.s=="bonus"do sfx(10)elseif n.s=="power"do sfx(9)else sfx(0)end end end end end return end end if e.t>=20do e.a=nil T=nil V=nil I=false sfx(-1,3)end elseif e.a=="rock_drop"do if not ei do ei=false e.B=false end if not e.B do for n=1,#l do local n=l[n]if n.f=="active"or n.f=="dead"do local t=e.l-n.l local a=e.e-n.e local l=sqrt(t^2+a^2)local d=e.t+n.t if l<d do e.B=true ei=true local t=t/l local a=a/l local l=d-l e.l=e.l+t*l e.e=e.e+a*l e.i=0e.d=o if n.f=="active"do n.f="dead"L(n.s)if n.s=="bonus"do sfx(10)elseif n.s=="power"do sfx(9)else sfx(0)end end break end end end else e.i=0e.d=e.d+o for n=1,#l do local n=l[n]if n.f=="active"or n.f=="dead"do local t=e.l-n.l local a=e.e-n.e local l=sqrt(t^2+a^2)local d=e.t+n.t if l<d do local t=t/l local a=a/l local l=d-l e.l=e.l+t*l e.e=e.e+a*l e.i=0e.d=o if n.f=="active"do n.f="dead"L(n.s)if n.s=="bonus"do sfx(10)elseif n.s=="power"do sfx(9)else sfx(0)end end break end end end end elseif e.a=="magnet"do local n=n1(e,l)if n do local l=n.l-e.l local t=n.e-e.e local n=sqrt(l^2+t^2)if n>0and n<40do local l=l/n local n=t/n e.i=e.i+l*.115e.d=e.d+n*.115end end e.i=e.i*.98+rnd()*.1-.05e.d=e.d*.98+rnd()*.1-.05local n=sqrt(e.i^2+e.d^2)if n>3.5do e.i=e.i/n*3.5e.d=e.d/n*3.5end end if e.a~="boulder"do for n=1,#l do local n=l[n]if n and(n.f=="active"or n.f=="dead")do local t=e.l-n.l local o=e.e-n.e local l=sqrt(t^2+o^2)local d=e.t+n.t if l<d do local t=t/l local o=o/l local l=d-l e.l=e.l+t*l e.e=e.e+o*l local l=e.i*t+e.d*o e.i=(e.i-2*l*t)*.84e.d=(e.d-2*l*o)*.84if n.f=="active"do n.f="dead"L(n.s)if n.s=="bonus"do sfx(10)elseif n.s=="power"do sfx(9)else sfx(0)end end a=true break end end end end if f and f.o=="threepeat"do if t.e>126and C>0do t.e=1C=C-1elseif t.e>126and C==0do end if C==2do t.c=3elseif C==1do t.c=11elseif C==0do t.c=6end end if f and f.o=="paddle"do if e.e+e.t>=126and e.e+e.t<=128and e.l>=x-19and e.l<=x+19do sfx(11)e.d=-abs(e.d)*1.05local n=(e.l-x)/18e.i=e.i+n*.5e.e=126-e.t end end if e.l-e.t<=8do e.l=8+e.t e.i=-e.i*.9elseif e.l+e.t>=120do e.l=120-e.t e.i=-e.i*.9end if e.e-e.t<=0do e.e=e.t e.d=-e.d*.84end if e.e>128do e.q=true end if a do break end end end end if t.a=="multiball"do local e=true for n=1,#s do local n=s[n]if not n.q do e=false break end end if e do s={}t.a=nil t.r=false n="pause"end end for e=1,#l do local e=l[e]if e.v and e.v>0do e.v=e.v-1end end end function n1(n,e)local l=nil local t=9999for o=1,#e do local e=e[o]if e.s=="goal"and e.f=="active"do local o=n.l-e.l local n=n.e-e.e local n=sqrt(o^2+n^2)if n<t do t=n l=e end end end return l end function e3(e)local l=g and 5or 3if e.a=="multiball"do for e=1,#s do local e=s[e]if not e.h do e.h=0end if e.e>128do del(s,e)elseif abs(e.l-e._)<l and abs(e.e-e.m)<l do e.h=e.h+1if e.h>=120do del(s,e)end else e.h=0e._=e.l e.m=e.e end end if#s==0do e.a=nil e.r=false n="pause"end else if abs(e.l-e._)<l and abs(e.e-e.m)<l do e.h=e.h+1else e.h=0e._=e.l e.m=e.e end if e.h>=120or e.e>128do e.h=0if r>0do n="pause"else n="game_over"end end end end q,f,nu=nil,nil,""s={}n0={[1]={o="boulder",t=8,c=4,a="boulder"},[2]={o="sniper",p=6,c=14},[3]={o="paddle",a="paddle",Q=64},[4]={o="magnet",a="magnet",c=13},[5]={o="multiball",a="multiball",c=10},[6]={o="threepeat",a="threepeat",c=3},[7]={o="expansion",a="expansion",c=2},[8]={o="gravity_flip",a="gravity_flip",c=0},[9]={o="reshoot",a="reshoot",c=7},[10]={o="ball_move",a="ball_move"},[11]={o="no_aim",a="no_aim"},[12]={o="random_aim",a="random_aim"},[13]={o="half_pts",a="half_pts"},[14]={o="rock_drop",a="rock_drop",c=8},[15]={o="partial_aim",a="partial_aim"},[16]={o="blind_peg",a="blind_peg"},[17]={o="peg_shuffle",a="peg_shuffle",k=eE},[18]={o="ball_start",a="ball_start"},[19]={o="peg_mirage",a="peg_mirage",k=function()D={}for e=1,50do local l=false local e,n while(not l)e=flr(rnd(107))+10n=flr(rnd(96))+20l=ep(e,n)
add(D,{l=e,e=n,t=2,u=flr(rnd(3))==0and 5or(rnd()<.5and 9or 12)})end end,C=function()D={}end},[20]={o="wobble_aim",a="wobble_aim"}}function nl(e)if f do ed()end local e=n0[e]if not e do return end o.a=e.a or o.a o.c=e.c or o.c o.t=e.t or o.t o.p=e.p or o.p x=e.Q or x if e.k do e.k()end f=e end function ed()if not f do return end o.a,o.c,o.t,o.p=nil,6,g and 5or 2,2if f.C do f.C()end f=nil end function n5()if f do ed()end end function eI()x=mid(27,x+(btn(1)and 2.2or 0)-(btn(0)and 2.2or 0),101)end
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
