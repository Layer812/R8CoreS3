
	--mode, right road, bottom road
	city = {
		{11,0,0, 10,1,1, 8,1,1, 1,0,1, 6,0,1, 0,0,0},
		{4,1,0, 2,0,1, 3,1,1, 9,1,1, 5,1,1, 7,0,1},
		{8,0,1, 0,1,0, 1,1,1, 0,1,0, 4,1,0, 2,0,0},
		{1,1,1, 11,0,1, 3,0,1, 11,1,1, 9,0,1, 8,0,1},
		{11,0,0, 9,0,1, 8,0,1, 0,1,1, 1,0,1, 3,0,0},
		{4,1,0, 2,0,0, 3,0,0, 4,1,0, 0,0,0, 11,0,0},
	}

	tick = {
		str = {
			"it's 10am and everyone is at work! that means it's time to 'deliver' everyone's packages!",
			"it's also worthwile to drive as recklessly as possible, so people don't try deliver their own packages",
			"we don't want to go out of business! i think..."
		},
		strs = 3
	}

	firstc = {
		str = {
			"this next guy likes to look out his window for my truck...",
			"need to park it around the corner!"
		},
		strs = 2
	}

	firsts = {
		str = {
			"ok, this must be really getting to people if they're out waiting for me...",
			"oh well, might as well slip past them!"
		},
		strs = 2
	}

	storedm = {
		str = {
			"cool, 5,000 more slips should do it. i'm back in the game baby!"
		},
		strs = 1
	}

	storem = {
		str = {
			"i'm out of slips! i need to go to the store to buy more...",
			"my boss likes it more when i *park over the most disabled spaces*"
		},
		strs = 2
	}

	endm = {
		str = {
			"finished!! need to get back to the depot before my shift ends!",
			"i can't wait to get right into the next episode of mail call",
			"love that series...",
			"...jk i've never even seen it lmao its from like 2002??"
		},
		strs = 4
	}

	ml = {a=90,x=-128}

	spacespts = {0,200,600,1000}
	spacest = {"wow, one space. i'm barely inconveniencing anyone!", "two spaces is alright, i mean at least you aren't being nice.", "3, nice! today is a good day... for me.", "flawless. i'm about to disable myself laughing!"}

	failtimes = 0

	failed = {
		m = {
			"here's your parcel, good thing you were here!!!!!",
			"how did you even see me?!?!",
			"really like your taste in games. not lame at all.",
			"i had a peek in your parcel. i'm disgusted. take it and go."
		},
		ms = 4
	}

	notes = {
		str = {
			{"maybe next", "time!! ;)", "hahahahahahaha"},
			{"you snooze...", "you lose!!", "hohoho!"},
			{"i'll be back", "lol jk", "come 2 the depot"},
			{"ayy lmao", "\\o_o/", "skjfogijg"},
			{"wow seriously", "you dead?", "#neverin"},
			{"i know you", "love me", "meet me @ mcds"},
			{"your package", "is gettin", "pawned #yolo"},
			{"nice car", "loooser", "#midlifecrisis"},
			{"collection", "is £200", "per kg #dwi"},
		},
		strs = 7
	}

	carplts = {{}, {{8,13},{14,6},{2,5}}, {{8,3},{14,11},{2,5}}, {{8,4},{14,9},{2,5}}, {{8,12},{14,7},{2,1}}, {{8,2},{14,0},{2,14}}}
	carspawns = {{{40,102,0}, {55,102,0}},{{17,107,0.25}},{{52,24,0.5},{76,12,0.5}},{{109,25,0.75}},
		{{24,13,0.75},{24,37,0.75},{24,73,0.75},{24,97,0.75}, {68,24,0.25},{68,58,0.25}},
		{{136,145,0.75},{68,176,0.25},{118,160,0.25}},
		{{0,59,0.75},{-20,47,0.25},{-20,71,0.25}},
		{{56,112,0}}
	}

	gamestate = 0

	cmid = 0
	curm = {}

	camx = 0
	camy = 0

	lxseg = -200
	lyseg = -200

	ent = {}
	scr = {}
	ti = {active=tick, a=0, scr=0, m=1, block=true, prog=false}
	inc = true;
	topuiy=0;
	score = 0

	timeleft=0
	startanim=0

	function _init()

		missions = {
			{x=2,y=2,type=0,ents={}},
			{x=3,y=4,type=0,ents={}},
			{x=4,y=2,type=0,ents={}},

			{x=3,y=5,type=2,ents={{x=84,y=45,props={sdir=0.5,scone=0.125,sx=92,sy=61,swing=0.03,rate=1/200,t=0,rad=130},n=218,tfra=8,hide=true,type=1,update=pvis}}}, --first carsee miss
			{x=4,y=6,type=0,ents={}},

			{x=2,y=6,type=5,ents={{x=32,y=83,props={sdir=0.7,scone=0.125,swing=0.25,rate=1/200,t=0,rad=48},n=218,tfra=8,type=0,update=pvis}}}, --first people dodge

			{x=5,y=1,type=3,tx=128,ty=150,ents={
				{x=106,y=136,update=phit,playerin=false,hide=true},
				{x=106,y=152,update=phit,playerin=false,hide=true},
				{x=128,y=136,update=phit,playerin=false,hide=true},
				{x=128,y=152,update=phit,playerin=false,hide=true}
				}},
			{x=5,y=1,type=1,ents={}},

			{x=4,y=1,type=0,ents={{x=60,y=68,props={sdir=0.5,scone=0.125,sx=92,sy=100,swing=0.06,rate=1/150,t=0,rad=150},n=218,tfra=8,hide=true,type=1,update=pvis}}},

			{x=3,y=2,type=0,ents={
				{x=98,y=53,props={sdir=0,scone=0.125,swing=0.1,rate=1/200,t=0,rad=64},n=218,tfra=8,type=0,update=pvis},
				{x=64,y=88,props={sdir=0.75,scone=0.125,swing=0.25,rate=1/150,t=0,rad=48},n=218,tfra=8,type=0,update=pvis},
			}},

			{x=1,y=3,type=0,ents={
				{x=56,y=76,props={sdir=0.5,scone=0.125,swing=0.12,rate=1/115,t=0,rad=64},n=218,tfra=8,type=0,update=pvis},
				{x=104,y=42,props={sdir=0.25,scone=0.125,swing=0.25,rate=1/115,t=0.5,rad=48},n=218,tfra=8,type=0,update=pvis},
			}},

			{x=5,y=4,type=0,ents={
				{x=68,y=151,props={sdir=0.5,scone=0.100,swing=0.5,rate=1/160,t=0,rad=64},n=218,tfra=8,type=0,update=pvis},
				{x=63,y=81,props={sdir=0.5,scone=0.125,sx=84,sy=108,swing=0.20,rate=1/200,t=0,rad=130},n=218,tfra=8,hide=true,type=1,update=pvis}
			}},

			{x=2,y=1,type=4,ents={}},
		}
		rmiss = 13

		car = {x=216,y=118,xv=0,yv=0,dir=0.5,tfra=16,w=2,h=2,n=192,rv=0,cx=0,cy=0,rv=0,use=true,rad=7,update=pcar}
		ply = {x=128,y=128,xv=0,yv=0,dir=0,tfra=8,w=1,h=1,n=202,cx=0,cy=0,rad=3,cantpush=true,mail=false,update=pguy}
		arr = {x=128,y=128,xv=0,yv=0,dx=0,dy=0,dir=0,tfra=16,w=1,h=1,n=250,rv=0,update=parr}
		add(ent, ply)
		add(ent, car)
		add(ent, arr)


		music(0)
		--gamestate = 1
		ml.a = 0
		ml.x = 128
		ml.str = {"by rhys", "for ld33", "z to start!"}
		timeleft = 60*5
	end

	function newcar(x,y,dir)
		return {x=x,y=y,xv=0,yv=0,dir=dir,tfra=16,w=2,h=2,n=224,rv=0,rv=0,rad=7,pal=carplts[flr(rnd(6))+1],scrt=0,update=ppark}
	end

	function segat(x,y)
		return {flr(x/176), flr(y/176)}
	end

	function _draw()
		local rdx = flr(camx/176)
		local rdy = flr(camy/176)

		local sx = 0;
		if (rdx ~= lxseg) then
			if (lxseg < rdx) then 
				spawnents(rdx+1, rdy)
				spawnents(rdx+1, rdy+1)
				sx = 1
			else
				spawnents(rdx, rdy)
				spawnents(rdx, rdy+1)
				sx = 2
			end
			
			lxseg = rdx
		end
		if (rdy ~= lyseg) then
			if (lyseg < rdy) then 
				spawnents(rdx, rdy+1)
				if (sx ~= 1) spawnents(rdx+1, rdy+1)
			else
				if (sx ~= 2) spawnents(rdx, rdy)
				spawnents(rdx+1, rdy)
			end
			lyseg = rdy
		end

		camera(camx, camy)
		rectfill(camx,camy,127+camx,127+camy,3)
		local t = city[rdy+1][rdx*3+2]
		drawvroad(rdx,rdy,t)
		local r = city[rdy+1][rdx*3+6]
		drawhroad(rdx+1,rdy,r)
		local b = city[rdy+2][rdx*3+2]
		drawvroad(rdx,rdy+1,b)
		local l = city[rdy+1][rdx*3+3]
		drawhroad(rdx,rdy,l)
		drawintersection(rdx,rdy,t,r,b,l)

		drawcel(rdx,rdy,city[rdy+1][rdx*3+1])
		drawcel(rdx+1,rdy,city[rdy+1][rdx*3+4])
		drawcel(rdx,rdy+1,city[rdy+2][rdx*3+1])
		drawcel(rdx+1,rdy+1,city[rdy+2][rdx*3+4])

		foreach(ent, drawspr)

		camera(0, 0)
		if (ti.a<32) then
			topuiy += (12-topuiy)/10
			if (ti.a < 16) then
				ti.a += 1
				rectfill(128-ti.a*8,0,128,10,1)
			elseif (ti.a>16) then
				ti.a += 1
				rectfill(0,0,256-ti.a*8,10,1)
				if (ti.a >= 32) then
					ti.block = false
					if (ti.prog) nextmission()
				end
			else 
				rectfill(0,0,128,10,1)
				ti.scr += 2
				local txt = ti.active.str[ti.m]
				print(txt,128-ti.scr,3,7)
				if (ti.scr>(#txt)*4+128) then
					ti.m += 1
					ti.scr = 0
					if (ti.m > ti.active.strs) ti.a = 17
				end
			end
		else
			topuiy += (0-topuiy)/10
		end

		if (ml.a < 90) then
			local x = 0
			if (ml.a < 45) then 
				local f = (45-ml.a)/2
				x = 28+(f*f*f)/40
				ml.a += 1
			else 
				local f = (ml.a-45)/2
				x = 28-(f*f*f)/40 
				if (gamestate==1) ml.a += 1
			end
			map(0,15,x,40,10,7)
			for i=1,3,1 do
				print(ml.str[i],x+8,47+i*8,7)
			end
		end

		if (gamestate > 0) then
			palt(0, false)
			palt(10, true)
			map(0,12,5,99,6,3)
			local minstr = ""..(flr(timeleft)%60)
			if (#minstr == 1) minstr = "0"..minstr
			local timestr = flr(timeleft/60)..":"..minstr
			print(timestr,31,118,1)
			print(timestr,31,117,7)
			palt()
			map(6,12,99,99,3,3)
			spr(141,96+arr.dx/42,96+arr.dy/42)
			local e = ply
			if (inc) e = car
			spr(142,96+e.x/42,96+e.y/42)

			local hrangle=(((60*3-timeleft)/60)/12)%1
			thickline(17,111,17+sin(hrangle)*-3, 111+cos(hrangle)*-3, 1, 0.5, false)
			local minangle=((600-timeleft)/60)%1
			line(17,111,17+sin(minangle)*-6, 111+cos(minangle)*-6, 5)

			rip = {}
			foreach(scr, function(p) 
				local sc=p.v.."0"
				local ia=1-p.a
				prthick(sc,(p.x*ia+64*p.a)-(#sc)*2,(topuiy+3)*p.a+p.y*ia,p.col)
				p.a += p.s
				if (p.a >= 1) add(rip,p)
			end)
			foreach(rip, function(p) del(scr,p) end)

			local sc=score.."0"

			prthick(sc,64-(#sc)*2,topuiy+3,1)
		end
	end

	function prthick(txt,x0,y0,back)
		for x=-1,1,1 do
			for y=-1,1,1 do
				print(txt,x0+x,y0+y,back)
			end
		end
		print(txt,x0,y0,7)
	end

	function spawnents(x,y)
		local mode = city[y+1][x*3+1]

		if (mode < 5 or mode > 7) then
			if (city[y+1][x*3+2] == 1) then
				for i=0,7,1 do
					if (rnd(1)<0.2) add(ent, newcar(x*176+139,y*176+i*16,0))
					if (rnd(1)<0.2) add(ent, newcar(x*176+165,y*176+i*16,0.5))
				end
			end
			if (city[y+1][x*3+3] == 1) then
				for i=0,7,1 do
					if (rnd(1)<0.2) add(ent, newcar(x*176+i*16,y*176+139,0.25))
					if (rnd(1)<0.2) add(ent, newcar(x*176+i*16,y*176+165,0.75))
				end
			end
		end
		
		if (mode > 0) then
			foreach(carspawns[mode], function(p) add(ent, newcar(x*176+p[1],y*176+p[2],p[3])) end)
		end
	end

	function failmission()
		sfx(11,3)
		ti = {active={str={failed.m[flr(rnd(failed.ms))+1]}, strs=1}, a=0, scr=0, m=1, block=true, prog=true}
		failtimes += 1
		foreach(curm.ents, function(e) 
			add(rip, e)
		end)
	end

	function nextmission()
		cmid += 1
		if (failtimes > 2) then
			ml.a = 0
			ml.x = 128
			ml.str = {"awful job!", "you're fired!", "you get nothing!"}
			cmid = rmiss+1
		end
		if (cmid > rmiss) then
			ti.a = 200
			ti.block = true
			gamestate = 2
			return
		end

		if (cmid ~= 1) then
			foreach(curm.ents, function(e) 
			add(rip, e)
			end)
		end
		curm = missions[cmid]

		local newti = nil
		if (curm.type == 3) newti = storem
		if (curm.type == 4) newti = endm
		if (curm.type == 5) newti = firsts
		if (curm.type == 2) newti = firstc
		if (newti ~= nil) then
			ti = {active=newti, a=0, scr=0, m=1}
			sfx(12,3)
		end

		local bx=curm.x*176-176
		local by=curm.y*176-176
		foreach(curm.ents, function(e) 
			if (e.w == nil) then 
				e.w=1
				e.h=1
			end
			e.dir=0
			e.bx = bx
			e.x += bx
			e.by = by
			e.y += by
			add(ent, e)
		end)

		--get destination
		local d = {}
		if (curm.tx ~= nil) then
			d = {curm.tx, curm.ty}
		else
			local destt = city[curm.y][curm.x*3-2]
			d = getdest(destt)
		end
		arr.dx = d[1]+bx
		arr.dy = d[2]+by
	end

	function getdest(num)
		for x=0,16,1 do
			for y=0,16,1 do
				if (num>7) num += 1
				local tile = mget(((num%8)*16-4) + x, flr(num/8)*16+y)
				if (fget(tile, 0)) return {x*8+4, y*8+4}
			end
		end
		return {64, 64}
	end

	function drawspr(e)
		if (e.draw ~= nil) e.draw(e)
		if (e.hide == true) return
		local rotn = flr(e.dir*e.tfra+0.5)%e.tfra
		local yf = rotn >= e.tfra/4 and rotn < (e.tfra*3)/4
		local xf = rotn >= e.tfra/2

		rotn = rotn%(e.tfra/4)
		if (((not xf) and yf) or (xf and (not yf))) rotn = (e.tfra/4)-rotn

		for i=2,15,1 do pal(i, 1) end
		spr(e.n+rotn*e.w, e.x-e.w*4-2, e.y-e.h*4-2, e.w, e.h, xf, yf)
		pal()
		if (e.pal ~= nil) then
			foreach(e.pal, function(p) pal(p[1], p[2]) end)
		end
		spr(e.n+rotn*e.w, e.x-e.w*4, e.y-e.h*4, e.w, e.h, xf, yf)
		if (e.pal ~= nil) pal()
	end

	function drawcel(x,y,num)
		local bx = x*176
		local by = y*176
		if (num == 0) then
			map(6,6,bx,by,6,6)
			map(6,6,bx+48,by,6,6)
			map(6,6,bx,by+48,6,6)
			map(6,6,bx+48,by+48,8,6)
			map(6,6,bx,by+96,6,4)
			map(6,6,bx+48,by+96,6,4)
			map(6,6,bx+96,by+96,4,4)
			map(6,6,bx+96,by,4,6)
			map(6,6,bx+96,by+48,4,6)
		elseif (num == 6) then
			map(num*16-4,0,bx,by,22,22)
		elseif (num == 7) then
			map(num*16+2,0,bx-48,by,14,16)
		else
			if (num > 7) num += 1
			map((num%8)*16-4,flr(num/8)*16,bx,by,16,16)
		end
	end

	function drawhroad(x,y,num)
		if (num==0) return
		local bx = x*176
		local by = y*176+128
		map(0,6,bx,by,6,6)
		map(0,6,bx+48,by,6,6)
		map(0,6,bx+96,by,4,6)
	end

	function drawvroad(x,y,num)
		if (num==0) return
		local bx = x*176+128
		local by = y*176
		map(0,0,bx,by,6,6)
		map(0,0,bx,by+48,6,6)
		map(0,0,bx,by+96,6,4)
	end

	function drawintersection(x,y,t,r,b,l)
		local bx = x*176+128
		local by = y*176+128
		map(6,0,bx,by,6,6)
		if(t~=1) map(0,6,bx+8,by,4,2)
		if(r~=1) map(4,0,bx+32,by+8,2,4)
		if(b~=1) map(0,10,bx+8,by+32,4,2)
		if(l~=1) map(0,0,bx,by+8,2,4)
	end

	function _update()
		if (gamestate == 1) then 
			timeleft -= 1/30
			if (timeleft <= 0) then
				gamestate = 2
				ml.a = 0
				ml.x = 128
				ml.str = {"out of time", "you're fired!", "you get nothing!"}
				timeleft = 0
				ti.block = true
				ti.a = 200
			end
		elseif (gamestate == 0) then
			camx = 440+cos(startanim/632)*437
			camy = 440+sin(startanim/1568)*437
			ti.block=true
			startanim += 1
			if (btnp(4)) then
				ti.block = false
				gamestate = 1
				music(0)
				nextmission()
			end
		end
		rip = {}
		foreach(ent, function(e) if (e.update ~= nil) then e.update(e) end end)
		foreach(rip, function(e) del(ent, e) end)
	end

	function mapcollide(x,y,f)
		if (x<0 or y<0 or x>1008 or y>1008) return true
		
		local rdx = flr(x/176)
		local rdy = flr(y/176)
		local num = city[rdy+1][rdx*3+1]
		if (num==7 or x%176 > 127 and y%176 > 127) return false
		if (x%176 > 127) return (f==1 and city[rdy+1][rdx*3+2]==0)
		if (y%176 > 127) return (f==1 and city[rdy+1][rdx*3+3]==0)
		if (num == 0) return (i==1)
		if (num > 7) num += 1
		local tile = mget((num%8)*16-4 + (x%176)/8, flr(num/8)*16+(y%176)/8)
		return fget(tile, f)
	end

	function rectcol(x1,x2,y1,y2,f)
		return mapcollide(x1,y1,f) or mapcollide(x2,y1,f) or mapcollide(x1,y2,f) or mapcollide(x2,y2,f)
	end

	function pcar(p)
		if (inc and (not ti.block)) then
			ply.x = -200
			ply.n = 202
			ply.mail = true
			if (btn(2)) then
				p.xv+=sin(p.dir)*-0.25
				p.yv+=cos(p.dir)*-0.25
			end

			if (btn(0)) p.rv -= 0.0025
			if (btn(1)) p.rv += 0.0025

			if (btnp(5) and p.use) then
				p.use = false

				if (curm.type == 3) then --park mission
					local tot = 0
					foreach(ent, function(e) if (e.playerin) then tot +=1 end end)
					if (tot > 0) then
						ti = {active={str={spacest[tot]}, strs=1}, a=0, scr=0, m=1, block=false, prog=false}
						sfx(12,3)
						addscore(p.x, p.y, spacespts[tot])
						nextmission()
					end
				end
				ply.x = p.x+cos(p.dir)*8
				ply.y = p.y+sin(p.dir)*-8
				inc = false
			end
		end

		p.dir += p.rv
		p.rv *= 0.8

		p.x += p.xv
		if (rectcol(p.x-6,p.x+6,p.y-6,p.y+6,7)) then 
			p.x -= p.xv
			p.xv *= -0.2
		end
		p.y += p.yv
		if (rectcol(p.x-6,p.x+6,p.y-6,p.y+6,7)) then 
			p.y -= p.yv
			p.yv *= -0.2
		end
		p.xv *= 0.9
		p.yv *= 0.9

		if (rectcol(p.x-6,p.x+6,p.y-6,p.y+6,1)) then
			p.xv *= 0.95
			p.yv *= 0.95
		end

		p.cy += (p.yv-p.cy)/10
		p.cx += (p.xv-p.cx)/10

		if (inc and (not ti.block)) then
			camx = mid(0, p.x-64+p.cx*5, 879)
			camy = mid(0, p.y-64+p.cy*5, 879)
			p.use = true
		end
	end

	function dist2(a,b)
		local dx = (a.x-b.x)/256
		local dy = (a.y-b.y)/256
		return dx*dx+dy*dy
	end

	function pguy(p)
		if (rectcol(p.x-3,p.x+3,p.y-3,p.y+3,7)) then 
			p.x = car.x
			p.y = car.y
		end

		if (inc or ti.block) return;
		if (btn(0)) p.xv -= 0.1
		if (btn(1)) p.xv += 0.1
		if (btn(2)) p.yv -= 0.1
		if (btn(3)) p.yv += 0.1
		if (btnp(5) and dist2(p, car) < 0.0087890625) inc = true

		p.dir = atan2(-p.yv, -p.xv)

		p.x += p.xv
		if (rectcol(p.x-3,p.x+3,p.y-3,p.y+3,7)) then 
			p.x -= p.xv
			p.xv *= -0.2
		end
		p.y += p.yv
		if (rectcol(p.x-3,p.x+3,p.y-3,p.y+3,7)) then 
			p.y -= p.yv
			p.yv *= -0.2
		end
		p.xv *= 0.9
		p.yv *= 0.9
		local seg = segat(p.x, p.y)

		if (p.mail and curm.x == seg[1]+1 and curm.y == seg[2]+1 and rectcol(p.x-3,p.x+3,p.y-3,p.y+3,0)) then 
			p.mail = false
			if (curm.type ~= 3) then
				addscore(p.x, p.y, 500)
				if (curm.type ~= 1) then smail()
				else 
					ti = {active=storedm, a=0, scr=0, m=1, block=false, prog=false} 
					sfx(12,3)
				end
				nextmission()
				sfx(10,3)		
			end
		end

		p.cy += (p.yv-p.cy)/10
		p.cx += (p.xv-p.cx)/10

		camx = mid(0, p.x-64+p.cx*5, 879)
		camy = mid(0, p.y-64+p.cy*5, 879)

		foreach(ent, function(e) 
			if (e.rad ~= nil and e ~= p) then 
				local rad = (e.rad+p.rad)/256
				local dist = dist2(e,p)
				if (dist2(e, p) < rad*rad) then
					local xp = (p.x-e.x)
					local yp = (p.y-e.y)
					p.xv += xp*(rad*rad-dist)*256/5
					p.yv += yp*(rad*rad-dist)*256/5
				end
			end 
		end)
	end

	function smail()
		ml.a = 0
		ml.x = 128
		if (curm.type == 4) then 
			addscore(camx+48,camy+110,flr(timeleft*50))
			ml.str = {"game over!", "your score", "is: ~"..score.."0~!"}
		else ml.str = notes.str[flr(rnd(notes.strs))+1] end
	end

	function ppark(p)
		p.dir += p.rv
		p.rv *= 0.9

		local w = segat(camx, camy)
		local m = segat(p.x, p.y)
		if (m[1] < w[1] or m[1] > w[1]+1 or m[2] < w[2] or m[2] > w[2]+1) then
			add(rip, p)
			return
		end

		if (p.scrt>0) p.scrt -= 1

		p.x += p.xv
		if (rectcol(p.x-3,p.x+3,p.y-3,p.y+3,7)) then 
			p.x -= p.xv
			p.xv *= -0.2
		end
		p.y += p.yv
		if (rectcol(p.x-3,p.x+3,p.y-3,p.y+3,7)) then 
			p.y -= p.yv
			p.yv *= -0.2
		end
		p.xv *= 0.925
		p.yv *= 0.925

		foreach(ent, function(e) 
			if (e.rad ~= nil and e ~= p and e.cantpush == nil) then 
				local rad = (e.rad+p.rad)/256
				local dist = dist2(e,p)
				if (dist2(e, p) < rad*rad) then
					if (e == car and p.scrt == 0) then
						addscore(p.x,p.y,5)
						p.scrt = 10
						sfx(0,3)
					end
					local xp = (p.x-e.x)
					p.rv += xp*(rad*rad-dist)*256/100
					local yp = (p.y-e.y)
					p.xv += xp*(rad*rad-dist)*51.2
					p.yv += yp*(rad*rad-dist)*51.2
				end
			end 
		end)
	end

	function parr(p)
		local e = ply
		if (inc) e = car
		p.xv = p.dx-e.x
		p.yv = p.dy-e.y

		if (dist2(e, {x=p.dx,y=p.dy}) < 0.0625) then
			p.x += (p.dx-p.x)/10
			p.y += ((p.dy-12)-p.y)/10
			p.dir += (0.5-p.dir)/10
		else
			p.dir = atan2(-p.yv, -p.xv)
			p.x = e.x + sin(p.dir)*-40
			p.y = e.y + cos(p.dir)*-40
		end
	end

	function pvis(p)
		p.draw = visdraw
		p.dir = p.props.sdir+sin(p.props.t)*p.props.swing

		p.props.t += p.props.rate
		p.props.t %= 1;

		if (p.type == 1) then
			p.ccol = 2
			if (conecheck(p, car, 1)) then
				p.ccol = 8
				if (not inc and conecheck(p, ply, 0.5)) then
					makerunner(p)
					failmission()
					addscore(ply.x, ply.y, -100)
				end
			end
		else
			p.props.sx = p.x
			p.props.sy = p.y
			p.ccol = 8
			local e = ply
			if (inc) e = car
			if (conecheck(p, e, 1)) then
				if (inc) then
					car.use = false
					ply.x = car.x+cos(car.dir)*8
					ply.y = car.y+sin(car.dir)*-8
					inc = false
				end
				p.ccol = 8
				makerunner(p)
				failmission()
				addscore(ply.x, ply.y, -100)
			end
		end

	end

	function makerunner(p)
		local x = p.props.sx+p.bx
		local y = p.props.sy+p.by
		add(ent, {sx=x,sy=y,x=x,y=y,n=218,w=1,h=1,tfra=8,dir=0,a=0,update=prunner})
	end

	function prunner(p)
		local xv = ply.x-p.sx
		local yv = ply.y-p.sy
		p.dir = atan2(-yv, -xv)
		if (p.a>5) add(rip,p)

		if (p.a<0.8) then
			p.x = p.sx+xv*p.a
			p.y = p.sy+yv*p.a
		elseif (p.a > 4.2) then
			p.x = p.sx+xv*(5-p.a)
			p.y = p.sy+yv*(5-p.a)
			p.dir += 0.5
		else
			ply.n = 234
		end

		p.a += 1/20
	end

	function conecheck(p, e, short)
		if (dist2(p,e) < ((p.props.rad*short)/256)*((p.props.rad*short)/256)) then
			local xv = e.x-p.x
			local yv = e.y-p.y
			local dir = atan2(-yv, -xv)
			if (dirdiff(dir,p.dir) < p.props.scone) then
				return true
			end
		end
		return false
	end

	function dirdiff(a,b)
		return abs((((a-b)+0.5)%1)-0.5)
	end

	function thickline(x0,y0,x1,y1,col,thick,mid)
		for x=-thick,thick,1 do
			for y=-thick,thick,1 do
				line(x0+x,y0+y,x1+x,y1+y,col)
			end
		end
		if (mid) line(x0,y0,x1,y1,7)
	end

	function phit(p)
		p.draw=hitrd
		p.x += 10.5
		p.y += 6.5
		p.playerin = (dist2(car,p) < 0.006)
		p.x -= 10.5
		p.y -= 6.5
		if (curm.type ~= 3) add(rip, p)
	end

	function hitrd(p)
		local col = 8
		if (p.playerin) col = 11 
		rect(p.x,p.y,p.x+21,p.y+13, col)
	end

	function addscore(x,y,val)
		local col=2
		local s = 0.1
		if (val >= 100) then 
			col=11
			s = 0.03 
		end
		if (val < 0) then
			col=8
			s = 0.03
		end
		score += val
		add(scr,{x=x-camx,y=y-camy,v=val,col=col,a=0,s=s})
	end

	function visdraw(p)
		if (p.type == 1 and p.ccol == 2 and (not inc)) return
		local mind = p.dir-p.props.scone
		local maxd = p.dir+p.props.scone
		thickline(p.x,p.y,p.x+sin(mind)*-p.props.rad,p.y+cos(mind)*-p.props.rad, p.ccol, 1, true)
		thickline(p.x,p.y,p.x+sin(maxd)*-p.props.rad,p.y+cos(maxd)*-p.props.rad, p.ccol, 1, true)
		for i=0,p.props.rad,p.props.rad/3 do
			line(p.x+sin(maxd)*-i,p.y+cos(maxd)*-i,p.x+sin(mind)*-i,p.y+cos(mind)*-i, 7)
		end
	end