start_lvl=0
lvl_max=22
shk=0
cls()

function reset()
 ents={}
 circs={}
 delays={}
 grt={}
 for i=0,256 do add(grt,0)end
 for i=0,32 do grt[rand(256)+1] = rand(4)end
 m={}
 m.draw=function() end
 stp=0
 t=0
end

function inm()
 reset()
 m.draw=dr_menu
 m.tdy=0
 go=0
 acc=0
 st=0
 gw=0
 sfx(1)
end

function dr_menu()
 
 --
 if(st>1) then 
  bganim()
  ma=22
  if(go==0) rectfill(ma,6,127-ma,38,2)
 end

 --
 if(st==0 and t<16) then
  apal(sget(32+t/2,3))
 else
  if(st==0) st=1 t=0 sfx(3)
 end
 by=2
 if(go==1) by-=t
 sspr(0,40,40,13,24,by,80,26)
 pal()
 
 if(st>=2)then
  f = function(k) return cos(((t+k)%60)/60)*2 end
  dy=0
  if(go==1) dy+=t  
  sspr(64,64,40,32,22,82+dy+f(8)*2,80,64)
  sspr(96,32,32,32,38,42+dy+f(0)*1,64,64)
  a={2,1,0,0,1}
  k=2
  if(t%128==126 and go==0) gw=20 sfx(22)
  if(gw>0) then
   gw-=1
   k=a[1+flr(gw/4)]
  end
  sspr(40+k*16,40,16,16,22+32,42+32+dy+f(0)*1,32,32)
  for i=0,1 do
   dy*=0.75
   sspr(i*32,64,32,32,i*90-16,dy+76+f(12+i*8)*4+i*8,64,64)
  end 
 end
 
 if(st>0)then
  c=max(1-t/10,0)
  if(st>=2) c=0
  sc=2+c*8
  ma = (128-29*sc)*0.5
  by = 24
  if(go==1) by-=t
  sspr(0,53,32,9,ma,by,32*sc,9*sc)
  if(st==1 and t==10) st+=1 t=0 music(0) sfx(2,3)
  pal()
 end
  
 k=12
 if(st==3) then
  k=2
  if(t==lim) go=1 t=0
 end
 c = 1+flr(cyc(2,k))*6
 if(st>1 and (go==0 or t<16) ) print("press action to start",21,120,c)
 if(go==1 and t>320 ) then
  reset()
  fade(-1)
  ing()
 end 
end

function bganim()
 k = 8
 d = 20
 if(go==1) then
  t += acc
  acc += 0.5
  d -= go*4
  m.tdy += m.tdy/3-1
 else
  if(st<3 and btnp(4) ) st=3 lim=t+20 sfx(4) music(-1,900)
 end 
 for i=0,k do 
  c = (i+1-(t%d)/d)/k
  ri = i+flr(t/d)
  col = sget(32+ri%k,1)
  if( go==1 and k-i < t/d ) col = 1
  circfill(64,80,(1-c)*120,col)
 end
end

function ing()
 reset()
 up=2
 m.upd=upd_game
 m.draw=dr_game
 trej=0
 ups={1,3,6,10,15,30,60}
 pool={1,1,2,2,3,3,4,4,5,5,6,6}
 opt={1,1,1,1,1} 
 ti=0
 lvl=start_lvl
 mk_bear()
 start()
end

function start()
 sfx(20)
 for y=0,15 do
  f=mget(lvl,y)
  if(f==33) mk0()
  if(f==51) mk1()
  if(f==55) mk2()
  if(f==39) mk3()
  if(f==35) mk4()
  if(f==56) mk5()
 end
end



function upd_game()
 for e in all(ents) do upd_ent(e) end 
 
 if( m.xpl and t%12==0 ) then
  k = 0
  for e in all(ents) do
   if( e.bad == -1) then
				expl(e)
    return
   end
   if(e.bonus) k+=1  
  end
  m.xpl=nil
  dl(40,next_lvl)
 end
end

function next_lvl()
 for u in all(ups) do
  if( u==lvl+1 ) then
   del(ups,u)
   pop_bon()
   return
  end
 end
 lvl+=1
 if(lvl==lvl_max)then
  fade(1,init_ending)
  fd.col=0
 else
  start()
 end
end
function chk_end()
 for e in all(ents) do if( e.bad == 1 ) return end
 m.xpl=1
end

function pop_bon()
 a=copy(pool)
 ba={}
 for i=0,2 do
  e = mk_ent()
  add(ba,e)
  e.bns=rget(a)
  e.fr=63+e.bns
  e.fam=2
  rnd_pos(e)
  e.upd=function(e)
   rep(e,15,sget(32+t%8,5))
   if( dist(e,be)<8 ) grab(e.bns)
  end
 end
end

function grab(k)
 sfx(14)
 dl(20,next_lvl)
 for b in all(ba) do
  b.dash=1
  b.dp=0
  b.lif=8
  b.upd=nil
 end 
 
 for n=0,count(pool) do
  if(pool[n]==k) pool[n]=0
 end
 if(k==6)then
  up+=1
 else
  opt[k] = opt[k]+1
 end
 tx={"love","speed","power","reach","regen","life"}
 txt(be,tx[k])
end

function dr_game()
 -- ground
 map(0,16,0,0,16,16)
 clip(8,16,112,96)

 g=7
 if(be.ven) g=9
 sc=sget(32+t%8,g)
 if(scn!=nil) circfill(scn.x,scn.y,5,sc)
 
 --
 for e in all(ents) do
  apal(0)
  spr(e.fr,e.x-3,e.y-3)
 end
 pal()
 --
 if(scn!=nil) line(be.x,be.y,scn.x,scn.y,sc)
 -- ents
 for i=0,3 do
   for e in all(ents) do 
    if(e.dp==i) draw_ent(e)
   end
 end
 
 -- fx
 for c in all(circs) do
  c.v *= c.f
  c.r += c.v
  circ(c.x,c.y,c.r,sget(32+c.t,c.g))
  c.t-=1
  if(c.t<0)del(circs,c)
 end
 clip()
 -- inter
 if(be!=nil)then
  c = 14
  if(be.ven) c=11
  if(ti>0) c=12
  if(t%4<2 and t<trej) c=8
  print("love:",1,121,c)
  ma = 21
  rect(ma,121,hpm()+4+ma,125,7)
  rectfill(ma+2,123,be.hp+ma+2,123,c) 
 end
 lx=101
 if(lvl>8) lx-=4
 print("level:",lx,2,7)
 print(lvl+1,lx+24,2,7)
 for i=0,3 do
  x=16
  if(up<=i) x+=3
  sspr(x,24,3,6,1+i*4,1)
 end
 
end

----------
-- ents --
----------
function mk_ent()
 e={} 
 e.x=0 
 e.y=0
 e.vx=0 
 e.vy=0
 e.lif=-1
 e.t=0
 e.dp=1
 e.fr=-1
 e.gr=0
 e.ox=0
 e.oy=0
 e.acc=0
 e.spd=0
 e.flh=0
 e.bad=0
 e.fam=0
 e.ft=1
 e.stp=0
 e.ray=4
 e.frz=0
 e.inv=0
 e.bm=0
 e.hp=20
 e.dr={}
 e.ob = function() end
 add(ents,e)
 return e
end

function upd_ent(e)
 if(e.frz>0)then
  e.frz-=1
  return
 end
 if(e.bad==-1 and dist(be,e)<16
  and e.t>40 and rand(12)==0 )then
  lov(e) sfx(23)
  bst(1)
 end
 if(e.bm>60) e.pk=1
 if(e.bm>0) e.bm-=1
 if(e.bm==0) e.pk=nil
 e.t+=1 
 if(e.upd!=nil) e.upd(e)
 
 if(e.tw!=nil)then
  w=e.tw
  w.c= min(w.c+w.spc,1)
  c=w.crv(w.c)
  e.x=w.sx*(1-c)+w.ex*c
  e.y=w.sy*(1-c)+w.ey*c
  if(w.c==1)then
   e.tw=nil
   if(w.f!=nil) w.f()
   e.vx=0
   e.vy=0
  end
 end
 
 for b in all(ents) do
  if(b!=e and b.fam>0 and b.fam == e.fam and e.frz+b.frz==0 ) then
   d=e.ray+b.ray-dist(e,b)
   if( d > 0 ) then
    a=atan2(e.y-b.y,e.x-b.x)
    d*=0.5
    push(e,a,d)
    push(b,a+0.5,d)
   end
  end
 end
 
 if( e.shot ) then
  if(dist(e,be)<4) hit_bear()
  c=0
		for b in all(ents) do
		 if(b.bad==-1 and dist(e,b)<5 ) c=1
		end
  if(out(e,10) or c==1)then
		 e.shot=nil
		 sfx(19)
		 anim(e,{11,12,13},0.5)
		 e.lif=5
		 e.spd=0
		 return
		end
 end
 
 if( e.bad==1 and be.trg!=e and dist(e,be) < 7 ) hit_bear()
 
 if( e.an != nil ) then
  e.vx=cos(e.an)*e.spd
  e.vy=sin(e.an)*e.spd
 end
 e.spd+=e.acc
 e.vy+=e.gr
 e.vx*=e.ft
 e.vy*=e.ft
 e.ox=e.x
 e.oy=e.y
 e.x+=e.vx
 e.y+=e.vy
 e.lif-=1
 if(e.lif==0) kill(e) 

end

function bst(n)
 k=hpm()-be.hp
 be.hp+=min(k,n)
end

function draw_ent(e)
 if(be.trg==e and be.upd==focus ) return
 if(e.flh>0) then e.flh-=1 apal(7) end
 if(e.rep!=nil)then
  r=e.rep
  if(r.b==-1)then
   apal(r.c)
  else
   pal(r.b,r.c)
  end
 end
 if(e.dash) apal(sget(32+e.lif,0))
 if(e.ram) pal(10,8)
 if(e.pa)then
  for i=0,15 do 
   pal(i,sget(44+i%4,flr(i/4)))
  end
 end
 for d in all(e.dr) do d() end
 if(e.qu!=nil)then
  line(e.ox,e.oy,e.x,e.y,e.qu)
 end
 f=e.fr
 if(e.anim!=nil)then
  a=e.anim
  a.i=(a.i+a.s)%count(a.f)
  f=a.f[1+flr(a.i)]
 end
 if(f>=0) spr(f,e.x-4,e.y-4)
 pal()
end

function mk_bear()
 be=mk_ent()
 be.x=64
 be.y=64
 be.dp=2
 be.fam=3
 be.hp=hpm()
 be.upd=upd_bear
end

function upd_bear(e)
 e.fam=3
 if( e.dead ) return
 scn=nil
 e.ven=nil
 if( e.trg!=nil ) then
  e.fam=2
  e.an = atan2(e.trg.y-e.y,e.trg.x-e.x)
 	if( e.man == nil ) e.man = e.an
 	d = dist(e.trg,e)
 	e.spd = min(d,5)
 	if(d<=3)then
 	 sfx(6,2)
 	 e.upd=focus
 	end
  s=pop(e)
  s.fr=e.fr
  s.dash=1
  s.dp=0
  s.lif=8
  return
 end
 
 acc=0.75*opt[2]
 a=gda()
 
 if(a!=nil) then
  dx=cos(a)*acc
  dy=sin(a)*acc  
  e.x+=dx
  e.y+=dy
  md=8-opt[2]*2
  if(t%md==0)then
   e.fr=(e.fr+1)%3
   sfx(12+cyc(2,md))
  end 
 else
  e.fr=3
 end
 
 if(btn(4))then
  prs+=1
 else
  prs=0
 end

 if(ti<=0 and e.trg==nil) then
  scn=seek_trg(e)
  if(scn!=nil)e.ven=scn.ven
  if(e.trg==nil and btn(4) and scn!=nil) then
   e.trg=scn
   sfx(5)
   e.man=nil
  end
 end 
 if(e.trg==nil and prs==1)then
  sfx(21)
  if(lvl<2)then
   c=fx_circ(e.x,e.y,8+16*opt[4])
   c.g=8
   txt(e,"hug?")
  end
 end
 
 ti-=1
 if(ti<=0)then  
  f=10-opt[5]*3
  if(scn==nil) f+=8
  if(e.ven) f+=16
  if(e.hp<hpm() and t%f==0) e.hp+=1
 end 
 wall(e)
end

function hit_bear()
 scn=nil
 if(be.dead or 
 be.inv >= be.t ) then return end
 sfx(11)
 if(be.upd==focus) unf(be)
 
 for e in all(ents) do e.frz = 32 end
 be.frz=0
 be.dead=1
 be.upd=function()
  be.fr=59+cyc(2,2)
 end
 e=jump(be)
 if(up==0)then
  e.f=function() kill(be) end
  f=function()
   fade(1,inm)
   fd.col=0
   kill(be)
  end
  dl(42,f) 
 else
  up-=1
  e.f=function()
   be.dead=nil
   be.upd=upd_bear
   for e in all(ents) do
    if(e!=be) kill(e)
   end
   be.hp=hpm()
   dl(40,start)
  end
 end
end

function seek_trg(e)
 best = 8+16*opt[4]
 trg = nil
 for b in all(ents) do 
  if(b.bad==1 and not b.ram and b.frz==0) then
   d=dist(e,b)
   if(d<best) trg=b best=d
  end
 end
 return trg
end

function unf(e)
 scn=nil 
 e.upd=upd_bear
 e.trg=nil
 e.an=nil
 e.inv=e.t+4
 ti=40
 e.flh=6
 sfx(-2,2)
end

function focus(e)
 e.spd=0 
 e.trg.frz=4
 e.fr=48+t%2
 n=opt[3]
 if(n>1 and t%2==0) n=1
 k=min(min(n,e.trg.hp),e.hp)
 e.trg.hp-=k
 e.hp-=k
 c=fx_circ(e.x,e.y,4+e.trg.hp*0.5 )
 c.t=0
 
 if(e.trg.hp<=0) then
  sfx(8)
  e.trg.pa=1
  e.trg.t=0
  e.trg.bad=-1
  e.trg.fam=3
  unf(e)
  c=fx_circ(e.x,e.y,8)
  c.v=6
  c.f=0.75
  dl(20,chk_end)
 else
  if( not btn(4) or e.hp == 0 ) then
   s="cancel" x=7
   if(e.hp==0) then
    s="rejected" x=10
    trej=t+40
   end
   sfx(x)
   p=txt(e.trg,s)
   p.lif=12
   a=gda()
   if( a == nil ) a = e.man+0.5
   imp(e,a,5)
   e.ft = 0.8
   unf(e) 
  end 
 end
 
 
 if(t%2==0)then
 lov(e)
 
 s=pop(e)
 s.x+=rnd(64)-32
 s.y+=rnd(64)-32
 s.upd=function(e)
  dx=be.x-e.x
  dy=be.y-e.y
  e.an=atan2(dy,dx)
  d=max(dist(be,e),2)
  e.spd=min(48/d,d)
  e.qu=sget(32+rand(8),0)
  if(d==2)kill(e)
 end
 add(s.draws,d)
 end
end

function mk_bad(n)
 e = mk_ent()
 e.bad=1
 e.fam=1
 rnd_pos(e)
 e.an=rnd(1)
 e.spd=0.5
 e.ob=function(e)
  e.an=atan2(64-e.y,64-e.x)
  if(e.ram)unram(e)
 end 
 c=fx_circ(e.x,e.y,22)
 c.v=-0.5
 c.f=1.14
 c.g=4
 c.t=12
 e.frz=12
 return e
end

function mk0()
 e=mk_bad()
 e.upd=function(e)
  e.spd=0.5
  wander(e)
  e.fr=32+flr(cyc(3,8))
  wall(e)
  if(hot(e))then
   e.spd=1.5
   fol(e)
  else
   if(dist(be,e)>64)then
    if(e.t%100==0 and not e.pa) shoot(e,0.1)
    e.spd=0
    e.fr=18
   end
  end
 end
end

function mk1() 
 e=mk_bad()
 e.hp=30
 e.spd=0.25
 e.upd=function(e)
  wander(e)
  e.fr=51+flr(cyc(4,8))
  wall(e)
  if(hot(e))then
   e.t+=4
  else
   db=dist(be,e)
   if(db<32 and not e.pk)then
    fol(e) 
    e.an+=0.5
   end
   if(db>64) fol(e)
  end
  if(e.t>70 and not e.pa )then
   shoot(e,0.1)
   e.t=0
  end
 end
end

function mk2()
 e = mk_bad()
 e.by=e.y
 e.an=nil
 e.fr=55
 e.hp=30
 e.upd=function(e)
  k=2 d=60
  if(e.pa) e.t=0
  if(e.t>90) k=1 d=10
  if(e.t==120)then
   e.t=0
   for i=0,16 do
    s=shoot(e,0)
    s.an=i/16
   end
  end
  e.y=e.by+sin((t%d)/d)*k
 end
end

function mk3()
 e=mk_bad()
 e.hp=100
 e.ven=1
 e.upd=function(e)
  e.spd=0.2+e.t*0.0002
  if(e.pa or e.pk) then wander(e) else fol(e) end
  e.fr=39+flr(cyc(3,8)) 
  wall(e)
  if(hot(e))then
   e.spd=0
   e.fr=43
   if(t%10==0)shoot(e,0.1)
  end
 end
end

function mk4()
 e=mk_bad()
 e.hp=40
 e.upd=function(e)
  e.fr=35+flr(cyc(3,8))
  if(e.tw!=nil)e.fr=44
  wall(e)
  if(not e.ram)then
   e.spd=0.75
   if(e.t>60 and be.trg!=e and not e.pa)then
    if(abs(be.x-e.x)<5 or abs(be.y-e.y)<5 or hot(e) ) then
     e.ram=1 e.t=0 fol(e)
     e.stp=0 sfx(16)
    end 
   end
  else
   e.spd=0.1+e.t*0.07
   e.stp+=e.spd
   if(e.stp>10)then
    sfx(17+t%2)
    e.stp-=10
    p=pop(e)
    p.dp=0
    anim(p,{25,26,27,28,29},0.25)
    p.lif=20
   end   
  end
 end
end

function mk5() 
 e = mk_bad()
 e.an=nil
 e.hp=40
 e.upd=function(e)
 	e.fr=56+cyc(2,12)
  mx=5
  if(hot(e)) then
   e.fr = 58
   if(e.t%4==0) then 
    s=shoot(e,0.01)
    s.acc=0.01*e.fury
    e.fury+=1
   end   
  else
   if(not e.pa)then
    k=t%60
    if(k==8) shoot(e,0.01)
    if(k<12) e.fr=58
    e.fury=0
   end
  end
 end
end

function fol(e)
 e.an=atan2(be.y-e.y,be.x-e.x)
end

function shoot(e,ra)
 sfx(15)
 s=pop(e)
 s.an=atan2(be.y-e.y,be.x-e.x)
 s.an+=(rnd(2)-1)*ra
 s.spd=0.75
 s.shot=1
 anim(s,{6,7,8},0.5)
 return s
end
function wander(e)
 e.an+=rnd(0.1)-0.05
end
function out(e,ma)
 return e.x<ma or e.y<8+ma or e.x>128-ma or e.y>120-ma
end

-- tool e --
function wall(e) 
 r=e.ray+8
 if( e.x<r or e.x > 127-r ) then
  e.x = mid(r,e.x,127-r)
  e.bm+=15
  e.ob(e)
 end
 if( e.y<8+r or e.y > 119-r ) then
  e.y = mid(8+r,e.y,119-r)
  e.bm+=15
  e.ob(e)
 end
end
function lov(e)
 s=pop(e)
 s.fr=24
 s.ft=0.7+rnd(0.25)
 imp(s,rnd(1),3)
 s.lif = 12
end
function expl(e)
 sfx(9)
 kill(e)
 bst(12)
 for i=0,8 do
 p=pop(e)
 p.fr = 21+rand(2)
 imp(p,(i+rnd(1))/8,1+rnd(3))
 p.ft = 0.85
 p.gr = -0.05-rnd(1)*0.1
 p.lif = 16+flr(rnd(36))
     
 p=pop(e)
 p.qu=sget(32+rand(8),6)
 imp(p,rnd(1),8)
 p.ft =0.7+rnd(0.25)
 p.lif=10+rand(20)
 end
end
function jump(e) 
 w = move_to(e,e.x,e.y-8,0.5)
 w.crv = function(c) return 0.5-cos(c)*0.5 end
 return w
end
function pop(e)
 b=mk_ent()
 b.x=e.x
 b.y=e.y
 b.ox=e.x
 b.oy=e.y
 return b
end
function push(e,a,d)
 e.x+=cos(a)*d
 e.y+=sin(a)*d
 if(e.an!=nil)e.an=a
 if(e.ram)unram(e)
 e.bm+=20
end
function anim(e,f,s)
 a={} a.f=f a.s=s a.i=0 
 e.anim = a
end
function imp(e,a,spd)
 e.vx += cos(a)*spd
 e.vy += sin(a)*spd
end
function unram(e)
 sfx(2)
 e.ram=nil
 e.t=0
 e.spd=0
 w=jump(e)
 shk=6
end
function move_to(e,tx,ty,spd)
 w={}
 w.c=0
 w.sx=e.x w.sy=e.y
 w.ex=tx w.ey=ty 
 dx=tx-e.x dy=ty-e.y
 d=sqrt(dx*dx+dy*dy)
 w.spc=spd/d
 w.crv=function(c) return 0.5-cos(c*0.5)*0.5 end
 e.tw=w
 return w
end
function rep(e,b,c,t)
 r={}
 r.t=t
 r.b=b
 r.c=c
 e.rep=r
 if(r.t==nil) r.t=1

end

function hot(e)
 return not e.pa and be.trg != nil
 and be.trg != e and be.upd == focus
end

function rnd_pos(e)
 while(true) do
  ma = 12
  e.x = ma+rnd(127-2*ma)
  e.y = 8+ma+rnd(111-2*ma)
  if( dist(e,be) > 32 ) break
 end
end

function kill(e)
 e.dead = 1
 del(ents,e)
end

function fx_circ(x,y,r)
 c={} c.x=x c.y=y
 c.r=r c.g=0 c.t=8
 c.v=0 c.f=1
 add(circs,c)
 return c
end
function txt(e,str)
 p=pop(e)
 p.y-=4
 p.fr=-1
 p.vy=-3.5
 p.ft=0.7
 p.lif=24
 p.dp=2
 function d()
  for i=0,1 do
   c=sget(32+min(p.lif,7),6)
   print(str,p.x-i-12,p.y-i,i*c)
  end
 end
 add(p.dr,d)
 return p
end

function fade(k,f)
 fd={}
 fd.c=0.5-k*0.5
 fd.k=k
 fd.f=f
 fd.col=1
end

function _init()
  inm()
end

function _update()
 t+=1
 if( m.upd != nil ) then
  m.upd()
 end
 for d in all(delays) do
  d.t-=1
  if( d.t <= 0 ) then
   d.f()
   del(delays,d)
  end
 end
end

function _draw()
 
 cls()
 if(shk!=0) then
  shk *= -0.75
  if(abs(shk)<1)shk=0
  camera(0,shk)
 end
 m.draw()

 r = 16
 mx = 256/r
 if( fd != nil ) then
  fd.c = mid(0,fd.c+0.05*fd.k,1)
  for x=0,mx do
  for y =0,mx do
    circfill(x*r*2+r,y*r*2+r,fd.c*r*1.4,fd.col)
   end
  end
  
  if( fd.c == 0 or fd.c == 1 ) then
   if(fd.f!= nil)fd.f()
   fd = nil
  end
 end
 
 if( log != nil ) print(log,0,0,7)
 
end


function apal(n)
 for i=0,15 do pal(i,n) end
end
function atan2(dy,dx)
 local q=0.125
 local a=0
 local ay=abs(dy)
 if(ay==0) ay=0.001 
 if(dx>=0) then
  local r=(dx-ay)/(dx+ay)
  a=q-r*q
 else
  local r=(dx+ay)/(ay-dx)
  a=q*3-r*q
 end
 if(dy>0) a=-a 
 return a
end

function sqrt(n)
 local i = 0
 while(i*i <= n) do
  i+=1
 end
 i-=1
 ld=n-i*i
 lp=ld/(2*i)
 la=i+lp
 return la-(lp*lp)/(2*la)
end

function cyc(n,k)
 if(k==nil) k=1
 return (t%(n*k))/k
end

function dist(a,b)
 dx = a.x-b.x
 dy = a.y-b.y
 return sqrt(dx*dx+dy*dy)
end

function dl(t,f)
 d={}
 d.t=t
 d.f=f
 add(delays,d)
end

function rand(n) return flr(rnd(n)) end

function copy(k)
 a={} 
 for n in all(k) do add(a,n) end
 return a
end

function rget(a)
 while(true) do
  n = rand(count(a))+1
  k = a[n]
  if( k > 0 ) then
   a[n] = 0
   return k
  end
 end
end

function hpm() return opt[1]*34 end

function gda()
 x=0 y=0
 if(btn(0)) x-=1
 if(btn(1)) x+=1
 if(btn(2)) y-=1
 if(btn(3)) y+=1
 if(x==0 and y==0) return nil
 return atan2(y,x)
end

function init_ending()
 reset()
 m.draw = function()
  print("thank you for playing",0,0,7)
 end
end





