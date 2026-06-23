--p.craft
--by nusan

lb4 = false
lb5 = false
block5 = false

time = 0

function item(n,s,p,bc)
	return {name=n,spr=s,pal=p,becraft=bc}
end

function inst(it)
	return {type=it}
end

function instc(it,c,l)
	return {type=it,count=c,list=l}
end

function setpower(v,i)
	i.power=v
	return i
end

function entity(it,xx,yy,vxx,vyy)
	return {type=it,x=xx,y=yy,vx=vxx,vy=vyy}
end

function rentity(it,xx,yy)
	return entity(it,xx,yy,rnd(3)-1.5,rnd(3)-1.5)
end

enstep_wait=0
enstep_walk=1
enstep_chase=2
enstep_patrol=3

function settext(t,c,time,e)
	e.text=t
	e.timer=time
	e.c=c
	return e
end

function bigspr(spr,ent)
	ent.bigspr=spr
	ent.drop=true
	return ent
end

function recipe(m,require)
	return {type=m.type,power=m.power,count=m.count,req=require,list=m.list}
end

function cancraft(req)
	local can=true
	for i=1,#req.req do
		if howmany(invent,req.req[i])<req.req[i].count then
			can=false
			break
		end
	end
	return can
end

function craft(req)
	for i=1,#req.req do
		reminlist(invent,req.req[i])
	end
	additeminlist(invent,setpower(req.power,instc(req.type,req.count,req.list)),0)
end

pwrnames = {"wood","stone","iron","gold","gem"}
pwrpal = {{2,2,4,4,},{5,2,4,13},{13,5,13,6},{9,2,9,10},{13,2,14,12}}

function setpal(l)
	for i=1,#l do
		pal(i,l[i])
	end
end

haxe = item("haxe",98)
sword = item("sword",99)
scythe = item("scythe",100)
shovel = item("shovel",101)
pick = item("pick",102)

pstone={0,1,5,13}
piron={1,5,13,6}
pgold={1,9,10,7}

wood = item("wood",103)
sand = item("sand",114,{15})
seed = item("seed",115)
wheat = item("wheat",118,{4,9,10,9})
apple = item("apple",116)
apple.givelife = 20
glass = item("glass",117)
stone = item("stone",118,pstone)
iron = item("iron",118,piron)
gold = item("gold",118,pgold)
gem = item("gem",118,{1,2,14,12})

fabric = item("fabric",69)
sail = item("sail",70)
glue = item("glue",85,{1,13,12,7})
boat = item("boat",86)
ichor = item("ichor",114,{11})
potion = item("potion",85,{1,2,8,14})
potion.givelife = 100

ironbar = item("iron bar",119,piron)
goldbar = item("gold bar",119,pgold)
bread = item("bread",119,{1,4,15,7})
bread.givelife = 40

workbench = bigspr(104,item("workbench",89,{1,4,9},true))
stonebench = bigspr(104,item("stonebench",89,{1,6,13},true))
furnace = bigspr(106,item("furnace",90,nil,true))
anvil = bigspr(108,item("anvil",91,nil,true))
factory = bigspr(71,item("factory",74,nil,true))
chem = bigspr(78,item("chem lab",76,nil,true))
chest = bigspr(110,item("chest",92))

inventary = item("inventory",89)
pickuptool = item("pickup tool",73)

etext = item("text",103)
player = 1
zombi = 2

grwater = {id=0,gr=0}
grsand = {id=1,gr=1}
grgrass = {id=2,gr=2}
grrock = {id=3,gr=3,mat=stone,tile=grsand,life=15}
grtree = {id=4,gr=2,mat=wood,tile=grgrass,life=8,istree=true,pal={1,5,3,11}}
grfarm = {id=5,gr=1}
grwheat = {id=6,gr=1}
grplant = {id=7,gr=2}
griron = {id=8,gr=1,mat=iron,tile=grsand,life=45,istree=true,pal={1,1,13,6}}
grgold = {id=9,gr=1,mat=gold,tile=grsand,life=80,istree=true,pal={1,2,9,10}}
grgem = {id=10,gr=1,mat=gem,tile=grsand,life=160,istree=true,pal={1,2,14,12}}
grhole = {id=11,gr=1}

lastground=grsand

grounds = {grwater,grsand,grgrass,grrock,grtree,grfarm,grwheat,grplant,griron,grgold,grgem,grhole}

function cmenu(t,l,s,te1,te2)
	return {list=l,type=t,sel=1,off=0,spr=s,text=te1,text2=te2}
end

mainmenu=cmenu(inventary,nil,128,"by nusan","2016")
intromenu=cmenu(inventary,nil,136,"a storm leaved you","on a deserted island")
deathmenu=cmenu(inventary,nil,128,"you died","alone ...")
winmenu=cmenu(inventary,nil,136,"you successfully escaped","from the island")

function howmany(list,it)
	local count=0
	for i=1,#list do
		if list[i].type==it.type then
			if not it.power or it.power==list[i].power then
				if list[i].count then
					count+=list[i].count
				else
					count+=1
				end
			end
		end
	end
	return count
end

function isinlist(list,it)
	for i=1,#list do
		if list[i].type==it.type then
			if not it.power or it.power==list[i].power then
				return list[i]
			end
		end
	end
	return nil
end

function reminlist(list,elem)
	local it=isinlist(list,elem)
	if not it then
		return
	end
	if it.count then
		it.count-=elem.count
		if it.count<=0 then
			del(list,it)
		end
	else
		del(list,it)
	end
end

function additeminlist(list,it,p)
	local it2=isinlist(list,it)
	if not it2 or not it2.count then
		addplace(list,it,p)
	else
		it2.count+=it.count
	end
end

function addplace(l,e,p)
	if p<#l and p>0 then
		for i=#l,p,-1 do
			l[i+1]=l[i]
		end
		l[p]=e
	else
		add(l,e)
	end	
end

function isin(e,size)
	return (e.x>clx-size and e.x<clx+size and e.y>cly-size and e.y<cly+size)
end

function lerp(a,b,alpha)
	return a*(1.0-alpha)+b*alpha
end

function getinvlen(x,y)
	return 1/getlen(x,y)
end

function getlen(x,y)
	return sqrt(x*x+y*y+0.001)
end

function getrot(dx,dy)
	return dy >= 0 and (dx+3) * 0.25 or (1 - dx) * 0.25
end

function normgetrot(dx,dy)
	local l = 1/sqrt(dx*dx+dy*dy+0.001)
	return getrot(dx*l,dy*l)
end

function fillene(l)
	l.ene={entity(player,0,0,0,0)}
	enemies=l.ene
	for i=0,levelsx-1 do
		for j=0,levelsy-1 do
			local c = getdirectgr(i,j)
			local r = rnd(100)
			local ex = i*16 + 8
			local ey = j*16 + 8
			local dist = max(abs(ex-plx),abs(ey-ply))
			if r<3 and c!=grwater and c!=grrock and not c.istree and dist>50 then
				local newe = entity(zombi,ex,ey,0,0)
				newe.life=10
				newe.prot=0
				newe.lrot=0
				newe.panim=0
				newe.banim=0
				newe.dtim = 0
				newe.step = 0
				newe.ox = 0
				newe.oy = 0
				add(l.ene, newe)
			end
		end
	end
end

function createlevel(xx,yy,sizex,sizey,isunderground)
	local l = {x=xx,y=yy,sx=sizex,sy=sizey,isunder=isunderground,ent={},ene={},dat={}}
	setlevel(l)
	levelunder = isunderground
	createmap()
	fillene(l)
	l.stx=(holex-levelx)*16+8
	l.sty=(holey-levely)*16+8
	return l
end

function setlevel(l)
	currentlevel=l
	levelx = l.x
	levely = l.y
	levelsx = l.sx
	levelsy = l.sy
	levelunder = l.isunder
	entities=l.ent
	enemies=l.ene
	data=l.dat
	plx=l.stx
	ply=l.sty
end

function resetlevel()

	reload()
	memcpy(0x1000,0x2000,0x1000)

	prot = 0
	lrot = 0

	panim = 0

	pstam = 100
	lstam = pstam
	plife = 100
	llife = plife

	banim = 0

	coffx = 0
	coffy = 0

	time = 0

	tooglemenu=0
	invent = {}
	curitem = nil
	switchlevel = false
	canswitchlevel = false
	menuinvent=cmenu(inventary,invent)

	for i=0,15 do
		rndwat[i] = {}
		for j=0,15 do
			rndwat[i][j] = rnd(100)
		end
	end
	
	cave = createlevel(64,0,32,32,true)
	island = createlevel(0,0,64,64,false)

	local tmpworkbench = entity(workbench,plx,ply,0,0)
	tmpworkbench.hascol=true
	tmpworkbench.list = workbenchrecipe
	
	add(invent,tmpworkbench)
	add(invent,inst(pickuptool))

	-- cheat, to remove

	--local tmpchest = entity(chest,plx+16,ply,0,0)
	--tmpchest.hascol=true
	--tmpchest.list = {}
	--local itl = {haxe,pick,sword,shovel,scythe}
	--for i=1,#itl do
	--	for j=1,5 do
	--		add(tmpchest.list, setpower(j, inst(itl[i])))
	--	end
	--end
	--add(entities,tmpchest)

	--add(invent,instc(wood,540))
	--add(invent,instc(stone,300))
	--add(invent,instc(iron,300))
	--add(invent,instc(wheat,300))
	--add(invent,instc(gold,300))


end

function _init()

	music(4,10000)

	furnacerecipe={}
	workbenchrecipe={}
	stonebenchrecipe={}
	anvilrecipe={}
	factoryrecipe={}
	chemrecipe={}

	add(factoryrecipe,recipe(instc(sail,1),{instc(fabric,3),instc(glue,1)}))
	add(factoryrecipe,recipe(inst(boat),{instc(wood,30),instc(ironbar,8),instc(glue,5),instc(sail,4)}))
	
	add(chemrecipe,recipe(instc(glue,1),{instc(glass,1),instc(ichor,3)}))
	add(chemrecipe,recipe(instc(potion,1),{instc(glass,1),instc(ichor,1)}))

	add(furnacerecipe,recipe(instc(ironbar,1),{instc(iron,3)}))
	add(furnacerecipe,recipe(instc(goldbar,1),{instc(gold,3)}))
	add(furnacerecipe,recipe(instc(glass,1),{instc(sand,3)}))
	add(furnacerecipe,recipe(instc(bread,1),{instc(wheat,5)}))

	local tooltypes = {haxe,pick,sword,shovel,scythe}
	local quant = {5,5,7,7,7}
	local pows = {1,2,3,4,5}
	local materials = {wood,stone,ironbar,goldbar,gem}
	local mult = {1,1,1,1,3}
	local crafter = {workbenchrecipe,stonebenchrecipe,anvilrecipe,anvilrecipe,anvilrecipe}
	for j=1,#pows do
		for i=1,#tooltypes do
			add(crafter[j],recipe(setpower(pows[j],inst(tooltypes[i])),{instc(materials[j],quant[i]*mult[j])}))
		end
	end

	add(workbenchrecipe,recipe(instc(workbench,nil,workbenchrecipe),{instc(wood,15)}))
	add(workbenchrecipe,recipe(instc(stonebench,nil,stonebenchrecipe),{instc(stone,15)}))
	add(workbenchrecipe,recipe(instc(factory,nil,factoryrecipe),{instc(wood,15),instc(stone,15)}))
	add(workbenchrecipe,recipe(instc(chem,nil,chemrecipe),{instc(wood,10),instc(glass,3),instc(gem,10)}))
	add(workbenchrecipe,recipe(inst(chest),{instc(wood,15),instc(stone,10)}))

	add(stonebenchrecipe,recipe(instc(anvil,nil,anvilrecipe),{instc(iron,25),instc(wood,10),instc(stone,25)}))
	add(stonebenchrecipe,recipe(instc(furnace,nil,furnacerecipe),{instc(wood,10),instc(stone,15)}))

	--srand(1245)

	curmenu = mainmenu

end

function getmcoord(x,y)
	return flr(x/16),flr(y/16)
end

function isfree(x,y)
	local gr = getgr(x,y)
	return not (gr.istree or gr==grrock)
end

function isfreeenem(x,y)
	local gr = getgr(x,y)
	return not (gr.istree or gr==grrock or gr==grwater)
end

function iscool(x,y)
	return not isfree(x,y)
end

function getgr(x,y)
	local i,j = getmcoord(x,y)
	return getdirectgr(i,j)
end

function getdirectgr(i,j)
	if(i<0 or j<0 or i>=levelsx or j>=levelsy) return grounds[1]
	return grounds[mget(i+levelx,j)+1]
end

function setgr(x,y,v)
	local i,j = getmcoord(x,y)
	if(i<0 or j<0 or i>=levelsx or j>=levelsy) return
	mset(i+levelx,j,v.id)
end

function dirgetdata(i,j,default)
	local g = i+j*levelsx
	if data[g]==nil then
		data[g] = default
	end
	return data[g]
end

function dirsetdata(i,j,v)
	data[i+j*levelsx] = v
end

function getdata(x,y,default)
	local i,j = getmcoord(x,y)
	if i<0 or j<0 or i>levelsx-1 or j>levelsy-1 then
		return default
	end
	return dirgetdata(i,j,default)
end

function setdata(x,y,v)
	local i,j = getmcoord(x,y)
	if i<0 or j<0 or i>levelsx-1 or j>levelsy-1 then
		return
	end
	dirsetdata(i,j,v)
end

function cleardata(x,y)
	local i,j = getmcoord(x,y)
	if i<0 or j<0 or i>levelsx-1 or j>levelsy-1 then
		return
	end
	data[i+j*levelsx] = nil
end

function loop(sel,l)
	local lp = #l
	return (((sel-1)%lp)+lp)%lp+1
end

function entcolfree(x,y,e)
	return max(abs(e.x-x),abs(e.y-y))>8
end

function reflectcol(x,y,dx,dy,checkfun,dp,e)

	local newx = x + dx
	local newy = y + dy

	local ccur = checkfun(x,y,e)
	local ctotal = checkfun(newx,newy,e)
	local chor = checkfun(newx,y,e)
	local cver = checkfun(x,newy,e)

	if ccur then
		if chor or cver then
			if not ctotal then
				if chor then
					dy = -dy*dp
				else
					dx = -dx*dp
				end
			end
		else
			dx=-dx*dp
			dy=-dy*dp
		end
	end

	return dx,dy
end

function additem(mat,count,hitx,hity)
	for i=1,count do
		local gi = rentity(mat,flr(hitx/16)*16 + rnd(14)+1,flr(hity/16)*16 + rnd(14)+1)
		gi.giveitem = mat
		gi.hascol = true
		gi.timer = 110+rnd(20)
		add(entities,gi)
	end
end

function upground()

	local ci = flr((clx-64)/16)
	local cj = flr((cly-64)/16)
	for i=ci,ci+8 do
		for j=cj,cj+8 do
			local gr = getdirectgr(i,j)
			if gr==grfarm then
				local d = dirgetdata(i,j,0)
				if time>d then
					mset(i+levelx,j,grsand.id)
				end
			end
		end
	end
end

function uprot(grot,rot)
	if abs(rot-grot) > 0.5 then 
		if rot>grot then
			grot += 1
		else
			grot -= 1
		end
	end
	return (lerp(rot, grot, 0.4)%1+1)%1
end

function _update()

	if curmenu then
		if curmenu.spr then
			if btnp(4) and not lb4 then
				if(curmenu==mainmenu) then
					curmenu=intromenu
				else
					resetlevel()
					curmenu=nil
					music(1)
				end
			end
			lb4 = btn(4)
			return
		else
			local intmenu = curmenu
			local othmenu = menuinvent
			if curmenu.type==chest then
				if(btnp(0)) then tooglemenu-=1 sfx(18,3) end
				if(btnp(1)) then tooglemenu+=1 sfx(18,3) end
				tooglemenu=(tooglemenu%2+2)%2
				if tooglemenu==1 then
					intmenu = menuinvent
					othmenu = curmenu
				end
			end

			if #intmenu.list>0 then
				if(btnp(2)) then intmenu.sel-=1 sfx(18,3) end
				if(btnp(3)) then intmenu.sel+=1 sfx(18,3) end
				
				intmenu.sel = loop(intmenu.sel,intmenu.list)

				if btnp(5) and not lb5 then
					if curmenu.type==chest then
						sfx(16,3)
						local el = intmenu.list[intmenu.sel]
						del(intmenu.list,el)
						additeminlist(othmenu.list,el,othmenu.sel)
						if(#intmenu.list>0 and intmenu.sel>#intmenu.list) intmenu.sel-=1
						if intmenu==menuinvent and curitem==el then
							curitem=nil
						end
					elseif curmenu.type.becraft then
						if curmenu.sel>0 and curmenu.sel<=#curmenu.list then
							local rec = curmenu.list[curmenu.sel]
							if cancraft(rec) then
								craft(rec)
								sfx(16,3)
							else
								sfx(17,3)
							end
						end
					else
						curitem = curmenu.list[curmenu.sel]
						del(curmenu.list,curitem)
						additeminlist(curmenu.list,curitem,1)
						curmenu.sel=1
						curmenu=nil
						block5=true
						sfx(16,3)
					end
				end
			end
		end
		if btnp(4) and not lb4 then
			curmenu=nil
			sfx(17,3)
		end
		lb4 = btn(4)
		lb5 = btn(5)
		return
	end

	if switchlevel then
		if currentlevel==cave then setlevel(island)
		else setlevel(cave) end
		plx = currentlevel.stx
		ply = currentlevel.sty
		fillene(currentlevel)
		switchlevel=false
		canswitchlevel=false
		music(currentlevel==cave and 4 or 1)
	end

	if curitem then
		if(howmany(invent,curitem)<=0) curitem=nil
	end

	upground()

	
	local playhit = getgr(plx,ply)
	if(playhit!=lastground and playhit==grwater) sfx(11,3)
	lastground = playhit
	local s = (playhit==grwater or pstam<=0) and 1 or 2
	if playhit==grhole then
		switchlevel = switchlevel or canswitchlevel
	else
		canswitchlevel = true
	end

	local dx = 0
	local dy = 0

	if(btn(0)) dx -= 1
	if(btn(1)) dx += 1
	if(btn(2)) dy -= 1
	if(btn(3)) dy += 1

	local dl = getinvlen(dx,dy)

	dx *= dl
	dy *= dl

	if abs(dx)>0 or abs(dy)>0 then
		lrot = getrot(dx,dy)
		panim += 1/33
	else
		panim = 0
	end

	dx *= s
	dy *= s

	dx,dy = reflectcol(plx,ply,dx,dy,isfree,0)

	local canact = true

	local fin=#entities
	for i=fin,1,-1 do
		local e = entities[i]
		if e.hascol then
			e.vx,e.vy = reflectcol(e.x,e.y,e.vx,e.vy,isfree,0.9)
		end
		e.x += e.vx
		e.y += e.vy
		e.vx *= 0.95
		e.vy *= 0.95

		if e.timer and e.timer<1 then
			del(entities,e)
		else
			if(e.timer) e.timer-=1

			local dist = max(abs(e.x-plx),abs(e.y-ply))
			if e.giveitem then
				if dist<5 then
					if not e.timer or e.timer<115 then
						local newit = instc(e.giveitem,1)
						additeminlist(invent,newit,-1)
						del(entities,e)
						add(entities,settext(howmany(invent,newit),11,20,entity(etext,e.x,e.y-5,0,-1)))
						sfx(18,3)
					end
				end
			else
				if e.hascol then
					dx,dy = reflectcol(plx,ply,dx,dy,entcolfree,0,e)
				end
				if dist<12 and btn(5) and not block5 and not lb5 then
					if curitem and curitem.type==pickuptool then
						if e.type==chest or e.type.becraft then
							additeminlist(invent,e,0)
							curitem=e
							del(entities,e)
						end
						canact = false
					else
						if e.type==chest or e.type.becraft then
							tooglemenu=0
							curmenu = cmenu(e.type,e.list)
							sfx(13,3)
						end
						canact = false
					end
				end
			end
		end
	end

	nearenemies={}

	local ebx = cos(prot)
	local eby = sin(prot)

	for i=1,#enemies do
		local e = enemies[i]
		if isin(e,100) then
			if e.type == player then
				e.x=plx
				e.y=ply
			else
				local distp = getlen(e.x-plx,e.y-ply)
				local mspeed = 0.8

				local disten = getlen(e.x-plx - ebx*8,e.y-ply - eby*8)
				if disten<10 then
					add(nearenemies,e)
				end
				if distp<8 then
					e.ox += max(-0.4,min(0.4,e.x-plx))
					e.oy += max(-0.4,min(0.4,e.y-ply))
				end

				if e.dtim<=0 then
					if e.step==enstep_wait or e.step==enstep_patrol then
						e.step=enstep_walk
						e.dx = rnd(2)-1
						e.dy = rnd(2)-1				
						e.dtim = 30+rnd(60)
					elseif e.step==enstep_walk then
						e.step=enstep_wait
						e.dx=0
						e.dy=0
						e.dtim = 30+rnd(60)
					else -- chase
						e.dtim = 10+rnd(60)
					end
				else
					if e.step==enstep_chase then
						if distp>10 then
							e.dx += plx-e.x
							e.dy += ply-e.y
							e.banim = 0
						else
							e.dx = 0
							e.dy = 0
							e.banim -= 1
							e.banim = e.banim%8
							local pow = 10
							if e.banim==4 then
								plife -= pow
								add(entities,settext(pow,8,20,entity(etext,plx,ply-10,0,-1)))
								sfx(14+rnd(2),3)
							end
							plife = max(0,plife)
						end
						mspeed = 1.4
						if distp>70 then
							e.step=enstep_patrol
							e.dtim = 30+rnd(60)
						end
					else
						if distp<40 then
							e.step=enstep_chase
							e.dtim = 10+rnd(60)
						end
					end
					e.dtim -= 1
				end

				local dl = mspeed*getinvlen(e.dx,e.dy)
				e.dx *= dl
				e.dy *= dl

				local fx = e.dx+e.ox
				local fy = e.dy+e.oy
				fx,fy = reflectcol(e.x,e.y,fx,fy,isfreeenem,0)

				if abs(e.dx)>0 or abs(e.dy)>0 then
					e.lrot = getrot(e.dx,e.dy)
					e.panim += 1/33
				else
					e.panim = 0
				end

				e.x += fx
				e.y += fy

				e.ox *= 0.9
				e.oy *= 0.9

				e.prot = uprot(e.lrot,e.prot)
			end
		end
	end

	dx,dy = reflectcol(plx,ply,dx,dy,isfree,0)

	plx += dx
	ply += dy

	prot = uprot(lrot,prot)

	llife += max(-1,min(1,(plife-llife)))
	lstam += max(-1,min(1,(pstam-lstam)))
		
	if btn(5) and not block5 and canact then
		local bx = cos(prot)
		local by = sin(prot)
		local hitx = plx + bx * 8
		local hity = ply + by * 8
		local hit = getgr(hitx,hity)

		if not lb5 and curitem and curitem.type.drop then
			if hit == grsand or hit == grgrass then
				
				if(not curitem.list) curitem.list={}
				curitem.hascol=true

				curitem.x = flr(hitx/16)*16+8
				curitem.y = flr(hity/16)*16+8
				curitem.vx = 0
				curitem.vy = 0
				add(entities,curitem)
				reminlist(invent,curitem)
				canact = false
			end
		end

		if banim==0 and pstam>0 and canact then
			banim = 8
			stamcost = 20
			if #nearenemies>0 then
				sfx(19,3)
				local pow = 1
				if curitem and curitem.type==sword then
					pow = 1+curitem.power+rnd(curitem.power*curitem.power)
					stamcost = max(0,20-curitem.power*2)
					pow=flr(pow)
					sfx(14+rnd(2),3)
				end
				for i=1,#nearenemies do
					local e = nearenemies[i]
					e.life -= pow/#nearenemies
					local push = (pow-1)*0.5
					e.ox += max(-push,min(push,e.x-plx))
					e.oy += max(-push,min(push,e.y-ply))
					if e.life<=0 then
						del(enemies,e)
						additem(ichor,rnd(3),e.x,e.y)
						additem(fabric,rnd(3),e.x,e.y)
					end
					add(entities,settext(pow,9,20,entity(etext,e.x,e.y-10,0,-1)))
				end
			elseif hit.mat then
				sfx(15,3)
				local pow = 1
				if curitem then
					if hit==grtree then
					 	if curitem.type==haxe then
							pow = 1+curitem.power+rnd(curitem.power*curitem.power)
							stamcost = max(0,20-curitem.power*2)
							sfx(12,3)
						end						
					elseif (hit==grrock or hit.istree) and curitem.type==pick then
						pow = 1+curitem.power*2+rnd(curitem.power*curitem.power)
						stamcost = max(0,20-curitem.power*2)
						sfx(12,3)
					end
				end
				pow=flr(pow)

				local d = getdata(hitx,hity,hit.life)
				if d-pow<=0 then
					setgr(hitx,hity,hit.tile)
					cleardata(hitx,hity)
					additem(hit.mat,rnd(3)+2,hitx,hity)
					if hit==grtree and rnd()>0.7 then
						additem(apple,1,hitx,hity)
					end
				else
					setdata(hitx,hity,d-pow)
				end
				add(entities,settext(pow,10,20,entity(etext,hitx,hity,0,-1)))
			else
				sfx(19,3)
				if curitem then
					if curitem.power then
						stamcost = max(0,20-curitem.power*2)
					end
					if curitem.type.givelife then
						plife = min(100,plife+curitem.type.givelife)
						reminlist(invent,instc(curitem.type,1))
						sfx(21,3)
					end
					if hit==grgrass and curitem.type==scythe then
						setgr(hitx,hity,grsand)
						if(rnd()>0.4) additem(seed,1,hitx,hity)
					end
					if hit==grsand and curitem.type==shovel then
						if curitem.power>3 then
							setgr(hitx,hity,grwater)
							additem(sand,2,hitx,hity)
						else
							setgr(hitx,hity,grfarm)
							setdata(hitx,hity,time+15+rnd(5))
							additem(sand,rnd(2),hitx,hity)
						end
					end
					if hit==grwater and curitem.type==sand then
						setgr(hitx,hity,grsand)
						reminlist(invent,instc(sand,1))
					end
					if hit==grwater and curitem.type==boat then
						reload()
						memcpy(0x1000,0x2000,0x1000)
						curmenu=winmenu
						music(4)
					end
					if hit==grfarm and curitem.type==seed then
						setgr(hitx,hity,grwheat)
						setdata(hitx,hity,time+15+rnd(5))
						reminlist(invent,instc(seed,1))
					end
					if hit==grwheat and curitem.type==scythe then
						setgr(hitx,hity,grsand)
						local d = max(0,min(4,4-(getdata(hitx,hity,0)-time)))
						additem(wheat,d/2+rnd(d/2),hitx,hity)
						additem(seed,1,hitx,hity)
					end
				end
			end
			pstam -= stamcost
		end
	end

	if banim>0 then
		banim -= 1
	end

	if pstam<100 then
		pstam = min(100,pstam+1)
	end

	local m = 16
	local msp = 4

	if abs(cmx-plx)>m then
		coffx += dx*0.4
	end
	if abs(cmy-ply)>m then
		coffy += dy*0.4
	end

	cmx = max(plx-m,cmx)
	cmx = min(plx+m,cmx)
	cmy = max(ply-m,cmy)
	cmy = min(ply+m,cmy)

	coffx *= 0.9
	coffy *= 0.9
	coffx = min(msp,max(-msp,coffx))
	coffy = min(msp,max(-msp,coffy))

	clx += coffx
	cly += coffy

	clx = max(cmx-m,clx)
	clx = min(cmx+m,clx)
	cly = max(cmy-m,cly)
	cly = min(cmy+m,cly)

	if btnp(4) and not lb4 then
		curmenu=menuinvent
		sfx(13,3)
	end

	lb4 = btn(4)
	lb5 = btn(5)
	if not btn(5) then
		block5=false
	end

	time += 1/30

	if(plife<=0) then
		reload()
		memcpy(0x1000,0x2000,0x1000)
		curmenu=deathmenu
		music(4)
	end

end

function mirror(rot)
	if rot<0.125 then
		return 0,1
	elseif rot<0.325 then
	elseif rot<0.625 then
		return 1,0
	elseif rot<0.825 then
		return 1,1
	else
		return 0,1
	end
	return 0,0
end

function dplayer(x,y,rot,anim,subanim,isplayer)

	local cr = cos(rot)
	local sr = sin(rot)
	local cv = -sr
	local sv = cr

	x = flr(x)
	y = flr(y-4)

	local lan = sin(anim*2)*1.5	
	local bel = getgr(x,y)
	if bel==grwater then
		y += 4
		circ(x + cv*3 + cr * lan,y + sv*3 + sr * lan,3,6)
		circ(x - cv*3 - cr * lan,y - sv*3 - sr * lan,3,6)
	
		local anc = 3 + ((time*3)%1)*3
		circ(x + cv*3 + cr * lan,y + sv*3 + sr * lan,anc,6)
		circ(x - cv*3 - cr * lan,y - sv*3 - sr * lan,anc,6)
	else
			
		circfill(x + cv*2 - cr * lan,y + 3 + sv*2 - sr * lan,3,1)
		circfill(x - cv*2 + cr * lan,y + 3 - sv*2 + sr * lan,3,1)
	end
		local blade = (rot+0.25)%1
		if subanim>0 then
			blade = blade - 0.3 + subanim*0.04
		end
		local bcr = cos(blade)
		local bsr = sin(blade)

		local mx,my = mirror(blade)

		local weap = 75

		if isplayer and curitem then
			pal()
			weap=curitem.type.spr
			if curitem.power then
				setpal(pwrpal[curitem.power])
			end
			if curitem.type and curitem.type.pal then
				setpal(curitem.type.pal)
			end
		end

		spr(weap,x + bcr*4 - cr * lan - mx*8 + 1, y + bsr*4 - sr * lan + my*8 - 7,1,1,mx==1,my==1)

		if(isplayer) pal()
	
	if bel!=grwater then
		circfill(x + cv*3 + cr * lan,y + sv*3 + sr * lan,3,2)
		circfill(x - cv*3 - cr * lan,y - sv*3 - sr * lan,3,2)
		
		local my2,mx2 = mirror((rot+0.75)%1)
		spr(75,x + cv*4 + cr * lan -8+mx2*8 + 1, y + sv*4 + sr * lan + my2*8 - 7,1,1,mx2==0,my2==1)

	end
	
	circfill(x+cr,y+sr-2,4,2)
	circfill(x+cr,y+sr,4,2)
	circfill(x+cr*1.5,y+sr*1.5-2,2.5,15)
	circfill(x-cr,y-sr-3,3,4)

end

function noise(sx,sy,startscale,scalemod,featstep)

	local n = {}
	for i=0,sx do
		n[i] = {}
		for j=0,sy do
			n[i][j] = 0.5
		end
	end

	local step = sx
	local scale = startscale
	while step>1 do
		local cscal = scale
		if(step == featstep) cscal = 1
		for i=0,sx-1,step do
			for j=0,sy-1,step do
				local c1 = n[i][j]
				local c2 = n[i+step][j]
				local c3 = n[i][j+step]
				n[i+step/2][j] = (c1+c2)*0.5 + (rnd()-0.5)*cscal
				n[i][j+step/2] = (c1+c3)*0.5 + (rnd()-0.5)*cscal
			end
		end
		for i=0,sx-1,step do
			for j=0,sy-1,step do
				local c1 = n[i][j]
				local c2 = n[i+step][j]
				local c3 = n[i][j+step]
				local c4 = n[i+step][j+step]
				n[i+step/2][j+step/2] = (c1+c2+c3+c4)*0.25 + (rnd()-0.5)*cscal
			end
		end
		step /= 2
		scale *= scalemod

	end

	return n
end

level = {}
typecount = {}

function createmapstep(sx,sy,a,b,c,d,e)

	local cur = noise(sx,sy,0.9,0.2,sx)
	local cur2 = noise(sx,sy,0.9,0.4,8)
	local cur3 = noise(sx,sy,0.9,0.3,8)
	local cur4 = noise(sx,sy,0.8,1.1,4)

	for i=0,11 do
		typecount[i] = 0
	end

	for i=0,sx do
		for j=0,sy do
			local v = abs(cur[i][j] - cur2[i][j])
			local v2 = abs(cur[i][j] - cur3[i][j])
			local v3 = abs(cur[i][j] - cur4[i][j])
			local dist = max((abs(i/sx - 0.5) * 2), (abs(j/sy - 0.5) * 2))
			dist = dist*dist*dist*dist
			local coast = v*4 - dist*4

			local id = a
			if(coast>0.3) id = b -- sand
			if(coast>0.6) id = c -- grass
			if(coast>0.3 and v2>0.5) id = d -- stone
			if(id == c and v3>0.5) id = e -- tree

			typecount[id] += 1

			cur[i][j] = id
		end
	end

	return cur
end

function createmap()

	local needmap = true

	while needmap do

		needmap = false

		if levelunder then
			level = createmapstep(levelsx,levelsy,3,8,1,9,10)

			if(typecount[8]<30) needmap = true
			if(typecount[9]<20) needmap = true
			if(typecount[10]<15) needmap = true
		else
			level = createmapstep(levelsx,levelsy,0,1,2,3,4)

			if(typecount[3]<30) needmap = true
			if(typecount[4]<30) needmap = true
		end

		if not needmap then
			plx = -1
			ply = -1
			for i=0,500 do
				local depx = flr(levelsx/8+rnd(levelsx*6/8))
				local depy = flr(levelsy/8+rnd(levelsy*6/8))
				local c = level[depx][depy]
				if c == 1 or c == 2 then
					plx = depx*16 + 8
					ply = depy*16 + 8
					break
				end
			end
			if plx < 0 then
				needmap = true
			end
		end
	end

	for i=0,levelsx-1 do
		for j=0,levelsy-1 do
			mset(i+levelx,j+levely,level[i][j])
		end
	end

	holex = levelsx/2+levelx
	holey = levelsy/2+levely
	for i=-1,1 do
		for j=-1,1 do
			mset(holex+i,holey+j,((levelunder) and 1 or 3))
		end
	end
	mset(holex,holey,11)
	
	clx = plx
	cly = ply

	cmx = plx
	cmy = ply
	
end

function comp(i,j,gr)
	local gr2 = getdirectgr(i,j)
	return (gr and gr2 and gr.gr == gr2.gr)
end

rndwat = {}

function watval(i,j)
	return rndwat[flr((i*2)%16)][flr((j*2)%16)]
end

function watanim(i,j)
	local a = ((time*0.6 + watval(i,j)/100)%1) * 19
	if(a>16) spr(13+a-16,i*16,j*16)
end

function rndcenter(i,j)
	return (flr(watval(i,j)/34)+18)%20
end

function rndsand(i,j)
	return flr(watval(i,j)/34)+1
end

function rndtree(i,j)
	return flr(watval(i,j)/51)*32
end

function spr4(i,j,gi,gj,a,b,c,d,off,f)
	spr(f(i,j+off)+a,gi,gj+2*off)
	spr(f(i+0.5,j+off)+b,gi+8,gj+2*off)
	spr(f(i,j+0.5+off)+c,gi,gj+8+2*off)
	spr(f(i+0.5,j+0.5+off)+d,gi+8,gj+8+2*off)
end

function drawback()

	local ci = flr((clx-64)/16)
	local cj = flr((cly-64)/16)
	for i=ci,ci+8 do
		for j=cj,cj+8 do
			local gr = getdirectgr(i,j)

			local gi = (i-ci)*2 + 64
			local gj = (j-cj)*2 + 32

			if gr and gr.gr == 1 then -- sand
				local sv=0
				if(gr==grfarm or gr==grwheat) sv=3
				mset(gi,gj,rndsand(i,j)+sv)
				mset(gi+1,gj,rndsand(i+0.5,j)+sv)
				mset(gi,gj+1,rndsand(i,j+0.5)+sv)
				mset(gi+1,gj+1,rndsand(i+0.5,j+0.5)+sv)
			else

				local u = comp(i,j-1, gr)
				local d = comp(i,j+1, gr)
				local l = comp(i-1,j, gr)
				local r = comp(i+1,j, gr)

				local b = gr==grrock and 21 or gr==grwater and 26 or 16
	
				mset(gi,gj,b + (l and (u and (comp(i-1,j-1, gr) and 17+rndcenter(i,j) or 20) or 1) or (u and 16 or 0)) )
				mset(gi+1,gj,b + (r and (u and (comp(i+1,j-1, gr) and 17+rndcenter(i+0.5,j) or 19) or 1) or (u and 18 or 2)) )				
				mset(gi,gj+1,b + (l and (d and (comp(i-1,j+1, gr) and 17+rndcenter(i,j+0.5) or 4) or 33) or (d and 16 or 32)) )
				mset(gi+1,gj+1,b + (r and (d and (comp(i+1,j+1, gr) and 17+rndcenter(i+0.5,j+0.5) or 3) or 33) or (d and 18 or 34)) )

			end
		end
	end

	pal()
	if levelunder then
		pal(15,5)
		pal(4,1)
	end
	map(64,32,ci*16,cj*16,18,18)

	for i=ci-1,ci+8 do
		for j=cj-1,cj+8 do
			local gr = getdirectgr(i,j)
			if gr then
				local gi = i*16
				local gj = j*16

				pal()
					
				if gr==grwater then
					watanim(i,j)
					watanim(i+0.5,j)
					watanim(i,j+0.5)
					watanim(i+0.5,j+0.5)
				end

				if gr==grwheat then
					local d = dirgetdata(i,j,0)-time
					for pp=2,4 do
						pal(pp,3)
						if(d>(10-pp*2)) palt(pp,true)
					end
					if(d<0) pal(4,9)
					spr4(i,j,gi,gj,6,6,6,6,0,rndsand)
				end
				
				if gr.istree then
					setpal(gr.pal)

					spr4(i,j,gi,gj,64,65,80,81,0,rndtree)
					
					if mget(i+levelx,j+1) == c then
						spr4(i,j,gi,gj,64,65,80,81,4,rndtree)
					end
				end

				if gr==grhole then
					pal()
					if not levelunder then
						palt(0,false)
						spr(31,gi,gj,1,2)
						spr(31,gi+8,gj,1,2,true)
					end
					palt()
					spr(77,gi+4,gj,1,2)
				end
			end
		end
	end
end

function panel(name,x,y,sx,sy)
	rectfill(x+8,y+8,x+sx-9,y+sy-9,1)
	spr(66,x,y)
	spr(67,x+sx-8,y)
	spr(82,x,y+sy-8)
	spr(83,x+sx-8,y+sy-8)
	sspr(24,32,4,8,x+8,y,sx-16,8)
	sspr(24,40,4,8,x+8,y+sy-8,sx-16,8)
	sspr(16,36,8,4,x,y+8,8,sy-16)
	sspr(24,36,8,4,x+sx-8,y+8,8,sy-16)

	local hx = x+(sx-#name*4)/2
	rectfill(hx,y+1,hx+#name*4,y+7,13)
	print(name,hx+1,y+2,7)
end

function itemname(x,y,it,col)
	local ty = it.type
	pal()
	local px = x
	if it.power then
		local pwn = pwrnames[it.power]
		print(pwn,x+10,y,col)
		px += #pwn*4 + 4
		setpal(pwrpal[it.power])
	end
	if(ty.pal) setpal(ty.pal)
	spr(ty.spr,x,y-2)
	pal()
	print(ty.name,px+10,y,col)
end

function list(menu,x,y,sx,sy,my)
	panel(menu.type.name,x,y,sx,sy)

	local tlist = #menu.list
	if tlist<1 then
		return
	end

	local sel = menu.sel
	if(menu.off>max(0,sel-4)) menu.off=max(0,sel-4)
	if(menu.off<min(tlist,sel+3)-my) menu.off=min(tlist,sel+3)-my

	sel -= menu.off

	local debut = menu.off+1
	local fin = min(menu.off+my,tlist)

	local sely = y+3+sel*8
	rectfill(x+1,sely,x+sx-3,sely+6,13)

	x+=5
	y+=12

	for i=debut,fin do
		local it = menu.list[i]
		local py = y+(i-1-menu.off)*8
		local col = 7
		if it.req and not cancraft(it) then
			col = 0
		end

		itemname(x,py,it,col)

		if it.count then
			local c = ""..it.count
			print(c,x+sx-#c*4-10,py,col)
		end
	end

	spr(68,x-8,sely)
	spr(68,x+sx-10,sely,1,1,true)
end

function requirelist(recip,x,y,sx,sy)
	panel("require",x,y,sx,sy)
	local tlist = #recip.req
	if tlist<1 then
		return
	end

	x+=5
	y+=12

	for i=1,tlist do
		local it = recip.req[i]
		local py = y+(i-1)*8
		itemname(x,py,it,7)

		if it.count then
			local h = howmany(invent,it)
			local c = h.."/"..it.count
			print(c,x+sx-#c*4-10,py,h<it.count and 8 or 7)
		end
	end
	
end

function printb(t,x,y,c)
	print(t,x+1,y,1)
	print(t,x-1,y,1)
	print(t,x,y+1,1)
	print(t,x,y-1,1)
	print(t,x,y,c)
end

function printc(t,x,y,c)
	print(t,x-#t*2,y,c)
end

function dent()
	for i=1,#entities do
		local e = entities[i]
		pal()
		if(e.type.pal) setpal(e.type.pal)
		if e.type.bigspr then
			spr(e.type.bigspr,e.x-8,e.y-8,2,2)
		else
			if e.type == etext then
				printb(e.text,e.x-2,e.y-4,e.c)
			else
				if e.timer and e.timer<45 and e.timer%4>2 then
					for i=0,15 do
						palt(i,true)
					end
				end
				spr(e.type.spr,e.x-4,e.y-4)
			end
		end
	end
end

function sorty(t)
	local tv = #t-1
	for i=1,tv do
		local t1 = t[i]
		local t2 = t[i+1]
		if t1.y > t2.y then
			t[i] = t2
			t[i+1] = t1
		end
	end
end

function denemies()
	sorty(enemies)

	for i=1,#enemies do
		local e = enemies[i]
		if e.type == player then	
			pal()
			dplayer(plx,ply,prot,panim,banim,true)
		else
			if isin(e,72) then
				pal()
				pal(15,3)
				pal(4,1)
				pal(2,8)
				pal(1,1)

				dplayer(e.x,e.y,e.prot,e.panim,e.banim,false)
			end
		end
	end
end

function dbar(px,py,v,m,c,c2)
	pal()
	local pe = px+v*0.3
	local pe2 = px+m*0.3
	rectfill(px-1,py-1,px+30,py+4,0)
	rectfill(px,py,pe,py+3,c2)
	rectfill(px,py,max(px,pe-1),py+2,c)
	if(m>v) rectfill(pe+1,py,pe2,py+3,10)
end

function _draw()

	if curmenu and curmenu.spr then
		camera()
		palt(0,false)
		rectfill(0,0,128,46,12)
		rectfill(0,46,128,128,1)
		spr(curmenu.spr,32,14,8,8)
		printc(curmenu.text, 64,80,6)
		printc(curmenu.text2, 64,90,6)
		printc("press button 1", 64,112,6+time%2)
		time += 0.1
		return
	end

	cls()

	camera(clx-64, cly-64)

	drawback()

	dent()

	denemies()

	camera()
	dbar(4,4,plife,llife,8,2)
	dbar(4,9,max(0,pstam),lstam,11,3)

	if curitem then
		local ix = 35
		local iy = 3
		itemname(ix+1,iy+3,curitem,7)
		if curitem.count then
			local c = ""..curitem.count
			print(c,ix+88-16,iy+3,7)
		end
	end

	if curmenu then
		camera()
		if curmenu.type==chest then
			if tooglemenu==0 then
				list(menuinvent,87,24,84,96,10)
				list(curmenu,4,24,84,96,10)
			else
				list(curmenu,-44,24,84,96,10)
				list(menuinvent,39,24,84,96,10)
			end
		elseif curmenu.type.becraft then
			if curmenu.sel>=1 and curmenu.sel<=#curmenu.list then
				local curgoal = curmenu.list[curmenu.sel]
				panel("have",71,50,52,30)
				print(howmany(invent,curgoal),91,65,7)
				requirelist(curgoal,4,79,104,50)
			end
			list(curmenu,4,16,68,64,6)
		else
			list(curmenu,4,24,84,96,10)
		end
	end

	--if(true) then
	--	print("cpu "..flr(stat(1)*100),96,0,8)
	--	print("ram "..flr(stat(0)),96,8,8)
	--end

end
