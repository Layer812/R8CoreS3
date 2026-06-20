pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- the remains of el dorado
-- (c) 2016 tom wright
-- licensed cc by-nc-sa

function r(t, b, l, r)
  return {
    t = t,
    b = b,
    l = l,
    r = r
  }
end

-- returns whether rects a and b overlap
function overlap(a, b)
  return a.l <= b.r and a.r >= b.l and a.t <= b.b and a.b >= b.t
end

-- manhattan distance function
function mdst(x1, y1, x2, y2)
  return abs(x1 - x2) + abs(y1 - y2)
end

function unvisited(q)
  while #q > 0 do
    local n = q[1]
    del(q, q[1])
    if (pathlens[n.x][n.y] == nil) return n
  end
  return nil
end

function genlos()
  los = {}
  for x = 0, 7 do
    los[x] = {}
  end
  for d in all {{x = -1, y = 0}, {x = 1, y = 0}, {x = 0, y = -1}, {x = 0, y = 1}} do
    local mx, my = pl.x / 16, pl.y / 16
    while true do
      mx += d.x
      my += d.y
      if (mx < 0 or mx > 7 or my < 0 or my > 7) break
      los[mx][my] = true
      if (blocked(mx * 16, my * 16)) break
    end
  end
end

-- marks map squares with shortest distance to the player
function genpathlens()
  pathlens = {}
  for i = 0, 7 do pathlens[i] = {} end
  local q={
    {
      x = flr(pl.x / 16),
      y = flr(pl.y / 16),
      d = 0
    }
  }
  while true do
    local nxt = unvisited(q)
    if (nxt == nil) return
    local x, y = nxt.x, nxt.y
    if nxt.d > 0 and solid(x, y) then
      pathlens[x][y] = -1
    else
      pathlens[x][y] = nxt.d
      local d = nxt.d + 1
      if (x > 0) add(q, {x = x-1, y =   y, d = d})
      if (x < 7) add(q, {x = x+1, y =   y, d = d})
      if (y > 0) add(q, {x =   x, y = y-1, d = d})
      if (y < 7) add(q, {x =   x, y = y+1, d = d})
    end
  end
end

-- generates a floor of the dungeon, saved in global `floor`
-- numeric indices in the floor table are a grid of room seeds, -1 when there
-- isn't a room in that square
function genfloor()
  ::retry::
  f += 1
  cls() spr(6+f/2%3, 60, 60) flip()
  floor = { visited = {}, sz = 48 }
  local sz = floor.sz
  -- make room in the floor table for the map contents
  for x = 1, sz * 2 do
    floor[x], floor.visited[x] = {}, {}
    for y=1, sz * 2 do
      floor[x][y], floor.visited[x][y] = -1, false
    end
  end
  -- start at the middle, do a random walk and mark rooms
  local x, y, md = sz, sz, 0
  for i=1, sz do
    while floor[x][y] ~= -1 do
      local j = flr(rnd(4)) + 1
      local dx, dy = {-1, 1, 0, 0}, {0, 0, -1, 1}
      x += dx[j]
      y += dy[j]
    end
    floor[x][y] = rnd() -- this will be used to seed the room later
    -- mark the exit if this is furthest from start
    local d = mdst(sz, sz, x, y)
    if d > md then
      floor.e = { x = x, y = y }
      md = d
    end
  end

  if md < 24 then
    goto retry
  end
end

function loadchunk(x, y, sx, sy, sz)
  local origin = 0x2000 + sx + 128 * sy
  local dst = 0x2000 + x + 128 * y
  for i = 0, sz - 1 do
    reload(dst + 128 * i, origin + 128 * i, sz)
  end
end

function solid(x, y)
  return fget(mget(x, y), 1)
end

function particle(x, y, dx, dy, r, c, z)
  local p = { x = x, y = y, dx = dx, dy = dy, r = r, c = c, z = z, up = particleupdate, d = particledraw }
  spawn(p)
  return p
end

function freezekill(a)
  lag = true
  pl.score += a.value
  moneyshake = 8
  kill(a)
  for i=1, 6 do
    local c = rnd() < .5 and 7 or 12
    local p = particle(a.x + rnd(8) + rnd(8), a.y + 15, 0, 0, 0.5, c, 1)
    p.save = true
  end
end

-- lizard pulls player towards them
function pull(a)
  genlos()
  local dst = mdst(a.mx, a.my, pl.x/16, pl.y/16)
  if playerinlos(a.mx, a.my) and dst > 1 and dst <= 2  then
    if pl.puller == nil or pathlens[a.mx][a.my] > pathlens[pl.puller.mx][pl.puller.my] then
      pl.puller = a
      pl.f = 0
      pl.px, pl.py = pl.x, pl.y
      pl.x, pl.y = a.x, a.y
      if pl.px < a.x then
        pl.x -= 16
        a.flip = false
      end
      if pl.px > a.x then
        a.flip = true
        pl.x += 16
      end
      if (pl.py < a.y) pl.y -= 16
      if (pl.py > a.y) pl.y += 16
      hurt()
      statetuck 'pulling'
      sfx(17)
      return true
    end
  end
  return false
end

-- lizard tries to avoid player and keep a steady distance to set up pulls
function kite(a)
  local fn
  local dst = mdst(pl.x/16, pl.y/16, a.mx, a.my)
  if (dst < 2) fn = longestpath
  if (dst > 4) fn = shortestpath
  if fn ~= nil then
    local mx, my = fn(a.mx, a.my)
    if mx ~= -1 and my ~= -1 and not blocked(mx * 16, my * 16) then
      a.px, a.py = a.x, a.y
      a.x, a.y = mx * 16, my * 16
      a.f = 0
      if (a.x > a.px) a.flip = true
      if (a.x < a.px) a.flip = false
    end
  end
end

function lizardup(a)
  a.f += 1
  a.mx, a.my = flr(a.x/16), flr(a.y/16)
  if framestate == 'enemy' then
    if (not pull(a)) kite(a)
  end
end

function lizarddraw(a)
  local s = 12
  if (framestate == 'pulling' and pl.puller == a) s = 13
  if (s == 12 and (f + a.bf) % 141 <= 8) s = 11
  local e = ease(a.f/6)
  local x, y = lerp(a.px, a.x, e), lerp(a.py, a.y, e)
  drawscaled(s, x, y, a.flip)
end

function burnkill(a)
  spawn(corpse(a.x + 8, a.y + 8, 0, 0))
  kill(a)
  pl.score += a.value
  moneyshake = 8
end

function lizard(mx,my)
  spawn {
    x = mx * 16, y = my * 16,
    px = mx * 16, py = my * 16, f = 0, bf = rnd(60),
    up = lizardup, d = lizarddraw,
    z = 2, save = true, blocking = true, killable = true,
    flip = false,
    burn = burnkill, freeze = freezekill, value = 5
  }
end

function ant(x,y)
  spawn {
    sp=25, sf=0,
    flp=false,
    up=antupdate,
    d=antdraw,
    x=x*16, px=x*16,
    y=y*16, py=y*16,
    mx = x, my = y,
    z=2,
    f=0,
    killable=true,
    save=true,
    blocking=true,
    freeze=freezekill, value = 5
  }
end

function shuf(t)
  for i = #t, 1, -1 do
    local j = flr(rnd(i)) + 1
    t[j], t[i] = t[i], t[j]
  end
end

function randomsquare()
  local sqs = {}
  for i = 1, 6 do
    for j = 1, 6 do
      if not blocked(i * 16, j * 16) then
        add(sqs, {x = i * 16, y = j * 16})
      end
    end
  end
  shuf(sqs)
  return sqs[1].x, sqs[1].y
end

function tp(a)
  if a.tp >= a.tpa then
    a.tp = 0
    local sqs = {}
    for i = 1, 6 do
      for j = 1, 6 do
        if not blocked(i * 16, j * 16) and mdst(pl.x / 16, pl.y / 16, i, j) <= 1 then
          add(sqs, {x = i * 16, y = j * 16})
        end
      end
    end

    shuf(sqs)
    
    local nx, ny
    if #sqs > 0 then
      nx, ny = sqs[1].x, sqs[1].y
    else
      nx, ny = randomsquare()
    end
    
    tppart(a.x, a.y, nx, ny)
    a.x, a.y = nx, ny
    if (a.x > pl.x) a.flip = false
    if (a.x < pl.x) a.flip = true
    
    a.st = 'tp'
    a.sf = 0
    
    sfx(18)
  end
end

function playertp(a)
  a.st, a.sf = 'playertp', 0
  local nx, ny = randomsquare()
  if (pathlens[nx / 16][ny / 16] == nil) return
  tppart(pl.x, pl.y, nx, ny)
  pl.x, pl.y, pl.f, pl.fy, pl.tped = nx, ny, 0, 0, true
  statetuck('teleported')
  ss = 4
  sfx(20)
end

function stab(a)
  hurt()
  local dx, dy = 0, 0
  if a.x > pl.x then
    dx = -1
    a.flip = false
  elseif a.x < pl.x then
    dx = 1
    a.flip = true
  elseif a.y > pl.y then
    dy = -1
  elseif a.y < pl.y then
    dy = 1
  end
  blood(pl.x + 8, pl.y + 8, dx * 4, dy * 4)
  a.st = 'stab'
  a.sf = 0
end

function cultistup(a)
  a.f += 1
  a.sf += 1

  if a.st == 'stab' and a.sf > 24 then
    a.st = 'idle'
    a.sf = 0
  end

  if (a.st == 'tp' or a.st == 'playertp') and a.sf > 36 then
    a.st = 'idle'
    a.sf = 0
  end

  if framestate == 'enemy' then
    if a.st ~= 'idle' then
      a.st = 'idle'
      a.sf = 0
    end

    local d = mdst(pl.x, pl.y, a.x, a.y) / 16
    a.tp += 1
    if d <= 1 then
      stab(a)
    else
      tp(a)
    end
  end
  
  if framestate == 'entered' and not pl.tped then
    playertp(a)
  end
end

function cultistdraw(a)
  local s, flip
  local dx, dy = pl.x - a.x, pl.y - a.y

  if a.st == 'idle' then
    s = 41
    if (a.f % 173 <= 4) s = 44
    drawscaled(s, a.x, a.y, a.flip)
  elseif a.st == 'tp' or a.st == 'playertp' then
    local y = lerp(a.y - 8, a.y, ease(a.sf / 36))
    s = 43
    if (f % 2 == 0) s = 27
    if (a.sf > 28) s = 42
    if (a.sf > 32) s = 41
    if (a.sf > 20 or a.st == 'playertp') drawscaled(s, a.x, y, a.flip)
  elseif a.st == 'stab' then
    if (dx < 0) s, flip = 45, false
    if (dx > 0) s, flip = 45, true
    if (dy < 0) s, flip = 28, false
    if (dy > 0) s, flip = 29, false
    drawscaled(s, a.x, a.y, flip)
  end
  
  if a.st == 'stab' then
    local p = a.sf > 3 and 1 or 0
    -- draw sword
    if dx < 0 then
      drawscaled(46 + p, a.x - 14, a.y + 4)
    elseif dx > 0 then
      drawscaled(46 + p, a.x + 14, a.y + 4, true, true)
    elseif dy < 0 then
      drawscaled(30 + p, a.x, a.y - 14, true, true)
    elseif dy > 0 then
      drawscaled(30 + p, a.x, a.y + 14)
    end
  end
end

function cultist(x, y)
  spawn {
    st = 'idle', sf = 0,
    flip = false, f = 0, tp = 0, tpa = flr(rnd(3)) + 4,
    up = cultistup,
    d = cultistdraw,
    x = x * 16, y = y * 16,
    px = x * 16, py = y * 16,
    z = 2,
    killable = true,
    save = true,
    blocking = true,
    freeze = freezekill, burn = burnkill, value = 10
  }
end

local tpcs = {0, 1, 1, 2, 2, 2, 15, 15, 15, 15, 15, 15, 7, 7, 7, 7, 7, 7, 7, 7, 15, 15, 15, 2, 2, 1}

function tppartup(a)
  a.f += 1
  if (a.f > #tpcs) kill(a)
  a.x += a.dx
  a.y += a.dy
  local n = atan2(a.tx - a.x, a.ty - a.y)
  a.dx, a.dy = lerp(a.dx, cos(n) * 4, 0.8), lerp(a.dy, sin(n) * 4, 0.1)
end

function tppartd(a)
  rectfill(a.x-1, a.y-1, a.x+1, a.y+1, tpcs[a.f])
end

function tppart(px, py, x, y)
  for i = 1, 16 do
    local a = atan2(x - px, y - py) + (rnd() * .2 - .1)
    local dx, dy = cos(a) * 4, sin(a) * 4
    spawn {
      f = 0, z = 3,
      x = rnd(8) + px + 4, y = rnd(8) + py + 4,
      tx = x + 8, ty = y + 8,
      dx = dx, dy = dy,
      up = tppartup, d = tppartd
    }
  end
end

function doorway(mx, my)
  if ((mx == 1 or mx == 6) and (my == 3 or my == 4)) return true
  if ((mx == 3 or mx == 4) and (my == 1 or my == 6)) return true
  return false
end

function genbadguys()
  local bag = { 0, 0, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 6 }
  shuf(bag)
  local n = bag[1]
  if (mdst(pl.rx, pl.ry, floor.sz, floor.sz) <= 4) n = 2
  if (mdst(pl.rx, pl.ry, floor.sz, floor.sz) <= 2) n = 1
  local spawns = {}
  for x = 1, 6 do
    for y = 1, 6 do
      if not solid(x, y) and not doorway(x, y) then
        add(spawns, {x = x, y = y})
      end
    end
  end
  shuf(spawns)
  local bag = { ant, ant, ant, cultist, cultist, lizard, lizard }
  shuf(bag)
  for i = 1, n do
    bag[i](spawns[i].x, spawns[i].y)
  end
end

function genexit()
  local x, y
  repeat
    x, y = flr(rnd(6)+1), flr(rnd(6)+1)
  until not solid(x, y)
  mset(x, y, 37)
end

function incenseup(a)
  a.f += 1
  if a.f % 16 == 0 then
    local p = particle(a.x, a.y, rnd(0.25) - 0.125, -0.25, 0.5, 2, 1)
    p.l = 60
  end
end

function incense(mx, my)
  spawn {
    f = flr(rnd(8)),
    x = mx * 16 + 9, y = my * 16 + 7,
    up = incenseup
  }
end

function moneyup(a)
  if pl.x == flr(a.x / 16) * 16 and pl.y == flr(a.y / 16) * 16 then
    sfx(16)
    pl.score += a.val
    kill(a)
    moneyshake = 8
  end
end

function moneydraw(a)
  drawscaled(a.s, a.x, a.y)
end

function goldbars(mx, my)
  spawn {
    val = 40, s = 40, z = 1,
    x = mx * 16, y = my * 16,
    up = moneyup, d = moneydraw, save = true
  }
end

--[[
function coindraw(a)
  sspr(a.s.x, a.s.y, 4, 4, a.x, a.y)
end

function coin(mx, my)
  local n = flr(rnd(4)) + 1
  local vals = {1, 2, 5, 20}
  local sprs = {{x = 56, y = 16}, {x = 60, y = 16}, {x = 56, y = 20}, {x = 60, y = 20}}
  local x = flr(rnd(12))
  spawn {
    val = vals[n], s = sprs[n], z = 1,
    x = mx * 16 + x, y = my * 16 + 12,
    up = moneyup, d = coindraw, save = true
  }
end
--]]

function genmoney()
  for x = 2, 5 do
    for y = 2, 5 do
      if not blocked(x * 16, y * 16) then
        if rnd() < 1/64 then
          goldbars(x, y)
--[[
        elseif rnd() < 1/32 then
          coin(x, y)
--]]
        end
      end
    end
  end
end

function pickupup(a)
  if pl.x == flr(a.x / 16) * 16 and pl.y == flr(a.y / 16) * 16 then
    sfx(16)
    add(pl.potions, a.pot)
    kill(a)
  end
end

function pickupdraw(a)
  pal(12, a.pot.c)
  spr(21, a.x, a.y)
  pal()
end

function pickup(mx, my)
  local bag = {
    potiondata(11, 'healing', healpot),
    potiondata(11, 'healing', healpot),
    potiondata(11, 'healing', healpot),
    potiondata(12, 'ice', icepot),
    potiondata(9, 'fire', firepot),
    potiondata(9, 'fire', firepot),
  }
  shuf(bag)
  local x = flr(rnd(8))
  spawn {
    pot = bag[1],
    x = mx * 16 + x, y = my * 16 + 8, z = 1,
    up = pickupup, d = pickupdraw, save = true
  }
end

function genpickups()
  for x = 1, 6 do
    for y = 1, 6 do
      if not solid(x, y) and rnd() < 0.008 then
        pickup(x, y)
      end
    end
  end
end

function genroom()
  srand(floor[pl.rx][pl.ry])

  for i=0,127 do
    for j=0,31 do
      mset(i, j, 0)
    end
  end

  -- outer room template
  local si, sj
  if pl.rx == floor.sz and pl.ry == floor.sz then
    si, sj = 0, 2
  else
    si, sj = flr(rnd(10)), flr(rnd(4))
  end
  if rnd() < 0.002 then
    si, sj = flr(rnd(2)) + 10, flr(rnd(4))
  end
  local sx, sy = 8 * si, 8 * sj
  loadchunk(0,0, sx,sy, 8)

  for i = 0, 7 do
    for j = 0, 7 do
      -- inner room template
      if mget(i,j)==61 then
        local si, sj =  flr(rnd(7)), flr(rnd(8))
        if (rnd() < 0.002) si = 7
        local sx, sy  = 4 * si + 96, 4 * sj
        loadchunk(i,j, sx,sy, 4)
      end
      -- decoration
      if mget(i, j) == 0 then
        if rnd() < 0.05 then
          local s = flr(rnd(3)) + 77 + (16 * flr(rnd(4)))
          mset(i, j, s)
        else
          mset(i, j, 0)
        end
      end
      -- incense
      if (mget(i, j) == 78) incense(i, j)
    end
  end

  if floor.e.x == pl.rx and floor.e.y == pl.ry then
    genexit()
  end

  if floor[pl.rx - 1][pl.ry] ~= -1 then
    mset(0, 3, 35)
    mset(0, 4, 35)
  end
  if floor[pl.rx + 1][pl.ry] ~= -1 then
    mset(7, 3, 35)
    mset(7, 4, 35)
  end
  if floor[pl.rx][pl.ry - 1] ~= -1 then
    mset(3, 0, 35)
    mset(4, 0, 35)
  end
  if floor[pl.rx][pl.ry + 1] ~= -1 then
    mset(3, 7, 35)
    mset(4, 7, 35)
  end

  if not floor.visited[pl.rx][pl.ry] and not (pl.rx == floor.sz and pl.ry == floor.sz) then
    genbadguys()
    genmoney()
    genpickups()
  end
  floor.visited[pl.rx][pl.ry] = true
end

function potiondata(c, n, effect)
  return {
    c = c,
    n = n,
    e = effect
  }
end

function healpot(e)
  if e.life ~= nil then
    e.life += 2
    sfx(13)
  end
  if (e.soak ~= nil) e:soak()
end

function icepot(e)
  if (e.soak ~= nil) e:soak()
  if (e.freeze ~= nil) e:freeze()
end

function firepot(e)
  if (e.burn ~= nil) e:burn()
end

function playerupdate(a)
  pl.f += 1

  if framestate ~= 'enemy' and framestate ~= 'gameover' then
    if pl.life <= 0 then
      gameover(false)
    end
    pl.life = min(pl.life, 4)
  end
  
  if framestate == 'idle' then
    idleupdate()
  elseif framestate == 'aiming' then
    aimupdate()
  elseif framestate == 'pulling' then
    if pl.f > 16 then
      statepop()
      pl.puller = nil
    end
  elseif framestate == 'teleported' then
    if pl.f > 25 then
      statepop()
    end
  end
end

function lerp(from,to,t)
  return from + t * (to - from)
end

function ease(t)
  t = mid(0, t, 1)
  if t >= 0.5 then
    return (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
  else
    return 4 * t * t * t
  end
end

function playerdraw(a)
  local s
  if a.fy == -1 then
    s = 2
  else
    s = 1
  end
  if a.f < 3 then
    s += 16
  end
  if s == 1 then
    if (a.f > 30 and f % 141 == 0) s = 4
    if (a.f > 30 and (f + 300) % 900 <= 16) s = 5
    if (framestate == 'bullet') s = 4
  end
  if framestate == 'gameover' and not won then
    s = 176
    if (gameoverframes > 2) s = 177
    if (gameoverframes > 6) s = 178
  end
  if framestate == 'teleported' and pl.f < 20 then
    return
  end
  if framestate == 'teleported' and pl.f < 25 then
    s = 179
  end
  if framestate == 'aiming' and f % 6 == 0 then
    for i = 1, 15 do pal(i, 7) end
  end
  local frames = 4
  if (framestate == 'pulling') frames = 16
  local x = lerp(a.px, a.x, ease(a.f / frames))
  local y = lerp(a.py, a.y, ease(a.f / frames))
  drawscaled(s, x, y, a.fx == -1)
  pal()

  if framestate == 'pulling' then
    local tx, ty = lerp(pl.puller.x, x, ease(a.f / 4)), lerp(pl.puller.y, y, ease(a.f / 4))
    rectfill(tx + 6, ty + 6, pl.puller.x + 10, pl.puller.y + 10, 8)
    circfill(tx + 8, ty + 8, 4)
  end
end

function hurt()
  lag = true
  hitfx()
  pl.life -= 1
  ss = 2
end

function player()
  pl = {
    x = 16,
    y = 64,
    px = 16,
    py = 64,
    f = 999,
    fx = 1,
    fy = 0,
    life = 4,
    shots = 4,
    rx = floor.sz,
    ry = floor.sz,
    potions = {
      potiondata(11, 'healing', healpot),
      potiondata(12, 'ice', icepot)
    },
    z = 2,
    up = playerupdate,
    d = playerdraw,
    keep = true,
    blocking = true,
    score = 0
  }
  spawn(pl)
end

function _init()
  _actors = {}
  -- screenshake
  ss = 0
  moneyshake = 0
  lag = false
  -- frame
  f = 0
  stack = {'title'}
  framestate = 'title'
  music(0)
end

-- save info about the rooms entities
function histsave()
  local saved = {}
  for a in all(_actors) do
    if (a.save) add(saved, a)
  end
  hist[pl.rx][pl.ry] = saved
end

-- load a rooms entities
function histload()
  for a in all(_actors) do
    if (not a.keep) kill(a)
  end
  local x, y = pl.rx, pl.ry
  if hist[x] ~= nil and hist[x][y] ~= nil then
    for a in all(hist[x][y]) do
      spawn(a)
    end
  end
end

function genblocking()
  blockingactors = {}
  for a in all(_actors) do
    if (a.blocking) add(blockingactors, a)
  end
end

function blocked(x, y)
  -- check for solid map tile
  if (solid(x / 16, y / 16)) return true

  -- check for blocking actor
  for a in all(blockingactors) do
    if (a.blocking and a.x == x and a.y == y) return true
  end

  return false
end

function particleupdate(a)
  a.x += a.dx
  a.y += a.dy
  if type(a.cs) == 'table' and #a.cs > 0 then
    a.c = a.cs[1]
    del(a.cs, a.cs[1])
  end
  if a.l ~= nil then
    if a.l <= 0 then
      kill(a)
    else
      a.l -= 1
    end
  end
end

function particledraw(a)
  if (a.shadow) circfill(a.x + 1,a.y + 1, a.r, 0)
  circfill(a.x, a.y, a.r, a.c)
end

function aimcharges()
  for i = 1, 8 do
    local a = i / 8
    local p = particle(pl.x + 6 + cos(a) * 16, pl.y + 8 + sin(a) * 16,
                       -cos(a), -sin(a),
                       1, 7, 3)
    p.l = 8
  end
end

function gameover(w)
  music(-1)
  if w then sfx(1) else sfx(7) end
  statepush('gameover')
  won = w
  gameoverframes = 0
end

function menuselup(a)
  a.f += 1
  if (btnp(0)) a.i -= 1
  if (btnp(1)) a.i += 1
  a.i = mid(1, a.i, #pl.potions)
  if a.f>4 and btnp(4) then
    statepop()
    statepush('potaim')
    sfx(0)
    aimer(a.i)
    kill(a)
  elseif a.f>4 and btnp(5) then
    sfx(12)
    statepop()
    kill(a)
  end
end

function explpartup(a)
  a.dx *= .7
  a.dy *= .7
  if (rnd() < .5) a.y -= 1
  particleupdate(a)
end

function explode(p)
  for i = 1, 8 do
    local a = i / 8
    local p = particle(p.drx, p.dry, cos(a)*4, sin(a) * 4, 6, p.p.c, 3)
    p.l = 32 + rnd(16)
    p.up = explpartup
    p.shadow = true
  end
  for i = 1, 16 do
    local a = i / 16
    local p = particle(p.drx, p.dry, cos(a)*8, sin(a) * 8, 6, p.p.c, 3)
    p.l = 32 + rnd(16)
    p.up = explpartup
    p.shadow = true
  end
  local area = {}
  area.l = flr(p.drx / 16) * 16 - 16
  area.r = area.l + 47
  area.t = flr(p.dry / 16) * 16 - 16
  area.b = area.t + 47
  for a in all(_actors) do
    if (a.x ~= nil and a.y ~= nil and overlap(r(a.y, a.y, a.x, a.x), area)) p.p.e(a)
  end
  ss += 3
  sfx(2)
  sfx(10)
end

function potionup(a)
  a.drx = lerp(pl.x + 8, a.x, ease(a.f / 16))
  a.dry = lerp(pl.y + 8, a.y, ease(a.f / 16))
  local p = particle(a.drx + rnd(6) - 2, a.dry + rnd(6) - 2, 0, -0.5, 2, a.p.c, 2)
  p.shadow = true
  p.l = 8
  if solid(a.drx / 16, a.dry / 16) or a.f > 16 then
    explode(a)
    statepop()
    kill(a)
  end
  a.f += 1
end

function potiondraw(a)
  circfill(a.drx, a.dry, 3, a.p.c)
  circ(a.drx, a.dry, 3, 7)
end

-- spawns a potion flying towards x,y
function potion(x, y, i)
  local a = {
    x = x,
    y = y,
    f = 0,
    z = 3,
    up = potionup,
    d = potiondraw,
    p = pl.potions[i]
  }
  spawn(a)
  del(pl.potions, a.p)
end

function aimerup(a)
  a.f += 1
  local mx, my = a.l / 16, a.t / 16
  if (btnp(0)) mx -= 1
  if (btnp(1)) mx += 1
  if (btnp(2)) my -= 1
  if (btnp(3)) my += 1
  if a.f > 4 and btnp(4) then
    statepop()
    statepush('enemy')
    statepush('potion')
    sfx(9)
    potion(a.l + 8, a.t + 8, a.i)
    kill(a)
  elseif a.f>4 and btnp(5) then
    statepop()
    kill(a)
  end
  mx = mid(1, mx, 6)
  my = mid(1, my, 6)
  a.l = mx * 16
  a.r = a.l + 15
  a.t = my * 16
  a.b = a.t + 15
end

function aimerdraw(a)
  for x = a.l, a.r do
    if (rnd()<.6) pset(x, a.t, a.c)
    if (rnd()<.3) pset(x, a.t, 7)
    if (rnd()<.6) pset(x, a.b, a.c)
    if (rnd()<.3) pset(x, a.b, 7)
  end
  for y = a.t, a.b do
    if (rnd()<.6) pset(a.l, y, a.c)
    if (rnd()<.3) pset(a.l, y, 7)
    if (rnd()<.6) pset(a.r, y, a.c)
    if (rnd()<.3) pset(a.r, y, 7)
  end
end

function aimer(i)
  local mx = pl.x / 16
  local my = pl.y / 16
  if (pl.fy==0) mx += pl.fx * 2
  my += pl.fy * 2
  local a = {
    c = pl.potions[i].c,
    i = i,
    f = 0,
    l = mx * 16,
    t = my * 16,
    r = mx * 16 + 15,
    b = my * 16 + 15,
    up = aimerup,
    d = aimerdraw,
    z = 4
  }
  spawn(a)
end

-- prints text with a black outline
-- borrowed from collab16 cart? can't find it now
function printol(pstring,px,py,pcol)
  for printx = 0, 2 do
    for printy = 0, 2 do
      print(pstring, px + printx, py + printy, 0)
    end
  end
  print(pstring, px + 1, py + 1, pcol)
end

function sprol(s, x, y)
  shadowpal()
  for dx = 0, 2 do
    for dy = 0, 2 do
      spr(s, x + dx, y + dy)
    end
  end
  pal()
  spr(s, x + 1, y + 1)
end

function menuseldraw(a)
  local pot = pl.potions[a.i]
  local x = (a.i) * 11 + 6
  local p = particle(x, 120, rnd(2) - 1, -1, 1, pot.c, 4)
  p.l = 8 p.shadow = true
  printol(pot.n, 2, 104, 7)
end

function menu()
  if (#pl.potions < 1) return
  local sel = { f = 0, i = 1, up = menuselup, d = menuseldraw, z = 5 }
  spawn(sel)
  sfx(8)
  statepush('menu')
end

function idleupdate()
  -- check if on amulet
  if mget(pl.x / 16, pl.y / 16) == 37 then
    pl.score += 10000
    gameover(true)
    return
  end

  local x = pl.x
  local y = pl.y
  if btnp(0) then
    x -= 16
  elseif btnp(1) then
    x += 16
  elseif btnp(2) then
    y -= 16
  elseif btnp(3) then
    y += 16
  elseif btnp(4) then
    statepush('aiming')
    statepush('enemy')
    sfx(0)
    aimcharges()
  elseif btnp(5) then
    menu()
  end

  if (x == pl.x and y == pl.y) return
  if (blocked(x,y)) return

  if (x - pl.x ~= 0) pl.fx = (x-pl.x) / 16
  pl.fy = (y - pl.y) / 16

  histsave()

  local newroom = false
  if x < 0 then
    pl.x = 112
    pl.px, pl.py = 128, pl.y
    pl.rx -= 1
    newroom = true
  end
  if x>= 128 then
    pl.x=0
    pl.px, pl.py = -16, pl.y
    pl.rx += 1
    newroom = true
  end
  if y < 0 then
    pl.y = 112
    pl.px, pl.py = pl.x, 128
    pl.ry -= 1
    newroom = true
  end
  if y >= 128 then
    pl.y = 0
    pl.px, pl.py = pl.x, -16
    pl.ry += 1
    newroom = true
  end
  if newroom then
    histload()
    genroom()
    statepush('entered')
  else
    pl.px, pl.py = pl.x, pl.y
    pl.x, pl.y = x, y
    statepush('enemy')
  end

  sfx(5)

  pl.f = 0
end

function spawn(a)
  add(_actors ,a)
end

function kill(a)
  del(_actors, a)
end

function dustupdate(a)
  a.f += 1
  if (a.f > a.l) kill(a)
  a.x += a.dx / a.f / 3
  a.y += a.dy / a.f / 3
  if (a.f>8) a.r = 1
end

function dust(x, y, dx, dy)
  local p = particle(x, y,
                     -dx + (rnd() - .5) * 8, -dy + (rnd() - .5) * 8,
                     0.5, pget(x, y), 3)
  p.l = 70 + (rnd() - .5) * 30
  p.up = dustupdate
  p.f = 0
  p.shadow = true
end

function corpseupdate(a)
  if (a.f > 1) a.c = 1
  a.f += 1
  if (a.f > 8) return
  a.x += a.dx / a.f / 4
  a.y += a.dy / a.f / 4
end

function corpse(x, y, dx, dy)
  local p = particle(x, y, dx, dy, 4, 10, 1)
  p.f = 0
  p.save = true
  p.up = corpseupdate
end

function bloodupdate(a)
  a.f += 1
  if (a.f > a.l) return
  a.x += a.dx / a.f
  a.y += a.dy / a.f
  if (a.f > 8) a.r = 1
  if (solid(a.x / 16,a.y / 16)) a.f = a.l
end

function blood(x, y, dx, dy)
  for i=1,32 do
    local p = particle(x, y,
                       dx + (rnd() - 0.5) * 8, dy + (rnd() - 0.5) * 8,
                       0.5, 8, 1)
    p.up = bloodupdate
    p.l = 8 + (rnd() - 0.5) * 15
    p.f = 0
    p.save = true
  end
end

function bullethit(a)
  local hit = false
  for b in all(_actors) do
    if b.killable then
      local ar = r(a.y, a.y, a.x, a.x)
      local br = r(b.y, b.y + 15, b.x, b.x + 15)
      if overlap(ar, br) then
        kill(b)
        pl.score += b.value
        moneyshake = 8
        blood(b.x+8, b.y+8, a.dx, a.dy)
        corpse(b.x+8, b.y+8, a.dx, a.dy)
        hit = true
      end
    end
  end
  return hit
end

function bulletupdate(a)
  if (a.x < 0 or a.x > 128 or a.y < 0 or a.y > 128) then
    kill(a)
    statepop()
    return
  end
  a.x += a.dx
  a.y += a.dy
  if bullethit(a) then
    lag = true
    kill(a)
    statepop()
  elseif solid(a.x / 16,a.y / 16) then
    kill(a)
    statepop()
    for i = 1, 16 do
      dust(a.x, a.y, a.dx, a.dy)
    end
  end
  a.f += 1
end

function bulletdraw(a)
  if a.f == 1 then
    circfill(a.x, a.y, 8, 7)
  else
    circfill(a.x - .4 * a.dx, a.y - .4 * a.dy, 4, 9)
    circfill(a.x - .2 * a.dx, a.y - .2 * a.dy, 4, 9)
    circfill(a.x, a.y, 4, 10)
  end
end

function bullet(dx, dy)
  local a={
    x = pl.x + 8,
    y = pl.y + 8,
    dx = dx * 2,
    dy = dy * 2,
    z = 3,
    f = 0,
    up = bulletupdate,
    d = bulletdraw
  }
  spawn(a)
end

function casingupdate(a)
  if a.y >= a.floor then
    a.y = a.floor
  else
    if (solid(a.x / 16, a.y / 16)) kill(a)
    a.x += a.dx
    a.y += a.dy
    a.dy += a.ddy
  end
end

function casing()
  local dx = pl.fx < 0 and 1 or -1
  local p = particle(dx < 0 and pl.x or pl.x + 16, pl.y + 6,
                     dx * (1 + rnd(0.05)), -1,
                     0.5, 10, 1)
  p.floor = pl.y + 12 + rnd(4)
  p.ddy = 0.4
  p.up = casingupdate
  p.save = true
end

function smokeupdate(a)
  a.x += a.dx
  a.y += flr(a.dy)
  a.x += rnd(2) - 1
  a.dy -= 0.2
  if (a.dy < -2) a.dy = 0
  if a.dx > 0 then
    a.dx = flr(a.dx / 2)
  else
    a.dx = -flr(-a.dx / 2)
  end
  a.l -= 1
  if (a.l < 0) kill(a)
end

function smoke(dx,dy)
  for i = 1, 10 do
    local p = particle(pl.x + dx + 8, pl.y + dy + 8,
                       4 * sgn(dx), rnd(2) - 1,
                       2, 6, 3)
    p.l = 20 + rnd(15)
    p.up = smokeupdate
    p.shadow = true
  end
end

function aimupdate()
  local dx = 0
  local dy = 0
  if btnp(0) then
    dx = -8
  elseif btnp(1) then
    dx = 8
  elseif btnp(2) then
    dy = -8
  elseif btnp(3) then
    dy = 8
  elseif btnp(5) then
    sfx(12)
    statepop()
  end

  if (dx == 0 and dy == 0) return

  pl.fx = dx / 8
  pl.fy = dy / 8

  sfx(2)
  sfx(3)

  bullet(dx, dy)
  casing()
  smoke(dx, dy)
  ss += 6

  statepop()
  statepush('enemy')
  statepush('bullet')
end

function shortestpath(x,y)
  local n = 99
  local i = -1
  local j = -1
  function checkbest(x, y)
    local l = pathlens[x][y]
    if (l ~= nil and l >= 0 and l < n and not blocked(x * 16, y * 16)) i, j, n = x, y, l
  end
  if rnd() < 0.5 then
    if (x > 1) checkbest(x - 1, y)
    if (x < 6) checkbest(x + 1, y)
    if (y > 1) checkbest(x, y - 1)
    if (y < 6) checkbest(x, y + 1)
  else
    if (y < 6) checkbest(x, y + 1)
    if (y > 1) checkbest(x, y - 1)
    if (x < 6) checkbest(x + 1, y)
    if (x > 1) checkbest(x - 1, y)
  end
  return i, j, n
end

function longestpath(x,y)
  local n = -1
  local i = -1
  local j = -1
  function checkbest(x, y)
    if (n == nil) return
    local l = pathlens[x][y]
    if (playerinlos(x, y)) l += 2
    if (l == nil or l > n) i, j, n = x, y, l
  end
  if rnd() < 0.5 then
    if (x > 1) checkbest(x - 1, y)
    if (x < 6) checkbest(x + 1, y)
    if (y > 1) checkbest(x, y - 1)
    if (y < 6) checkbest(x, y + 1)
  else
    if (y < 6) checkbest(x, y + 1)
    if (y > 1) checkbest(x, y - 1)
    if (x < 6) checkbest(x + 1, y)
    if (x > 1) checkbest(x - 1, y)
  end
  return i, j, n
end

function hitfx()
  sfx(3)
  ss = 10
  for i = 1, 10 do
    local p = particle(pl.px + rnd(24) - 4, pl.py + rnd(24) - 4,
                       0, 0,
                       0.5, 8, 1)
    p.save = true
    if (solid(p.x/16,p.y/16)) kill(p)
  end
end

-- check if player is in sight
-- true if on same row or col and there's nothing in the way
-- barriers are detected by looking at pathlen vs an unobstructed path
function playerinlos(mx, my)
  return los[mx][my]
end

function flameupdate(a)
  if framestate == 'enemy' then
    if (a.x == pl.x and a.y == pl.y) flamedmg = true
    if a.l <= 0 then
      local x = a.x + a.dx * 16
      local y = a.y + a.dy * 16
      local valid = not solid(x / 16,y / 16)
        and  x >= 0 and x < 128
        and  y >= 0 and y < 128
      if (valid) flame(a.x, a.y, a.dx, a.dy)
      kill(a)
      return
    end
    a.l -= 1
    if (a.x == pl.x and a.y == pl.y) flamedmg = true
  end
end

function flamedraw(e)
  if (f % 2 ~= 0) return
  local p = particle(rnd(8) + rnd(8) + e.x, e.y + 12,
                     rnd() - 0.5, -(rnd() + 0.25),
                     2, 7, 3)
  p.cs = { 10, 10, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 6, 6, 6, 6, 5, 5 }
  p.l = 16
  p.shadow = true
end

function flame(x, y, dx, dy)
  local a = {
    x = x, y = y,
    dx = dx, dy = dy,
    z = 3,
    l = 1,
    up  =  flameupdate,
    d = flamedraw,
    save = true,
    soak = kill
  }
  a.x += a.dx * 16
  a.y += a.dy * 16
  spawn(a)
end

function movetoplayer(e)
  local mx, my = flr(e.x / 16), flr(e.y / 16)
  local nx, ny, d = shortestpath(mx, my)
  if (nx == -1 or ny == -1 or d == 0) return
  if (blocked(nx * 16, ny * 16)) return
  if (nx < 1 or nx > 6 or ny < 1 or ny > 6) return
  e.px, e.py = e.x, e.y
  e.x, e.y = nx * 16, ny * 16
  if (e.x > e.px) e.flp = true
  e.f = 0
end

function antupdate(a)
  genlos()
  a.f += 1
  a.sf += 1
  if (a.sf >= 8) a.sp = 25
  if framestate == 'enemy' then
    local mx, my = flr(a.x / 16), flr(a.y / 16)
    if playerinlos(mx, my) then
      local dx, dy = 0, 0
      if (a.x > pl.x) dx = -1
      if (a.x < pl.x) dx = 1
      if (a.y > pl.y) dy = -1
      if (a.y < pl.y) dy = 1
      flame(mx * 16, my * 16, dx, dy)
      sfx(11)
      a.sf = 0
      a.sp = 26
    else
      movetoplayer(a)
      a.sp = 25
    end
  end
end

function antdraw(a)
  local e = ease(a.f / 8)
  local x = lerp(a.px, a.x, e)
  local y = lerp(a.py, a.y, e)
  drawscaled(a.sp, x, y, a.flp)
end

function statepush(s)
  add(stack, s)
end

function statepop()
  if (#stack ~= 0) stack[#stack] = nil
end

function statetuck(s)
  local top = stack[#stack]
  statepop()
  statepush(s)
  statepush(top)
end

function _update()
  -- clear some old history if we're over 95% of mem
  if stat(0) > 972 then
    for i = 1, floor.sz * 2 do
      for j = 1, floor.sz * 2 do
        local saved = hist[i][j]
        if saved ~= nil then
          for a in all(saved) do
            if (rnd()<0.5 and not a.killable) del(saved, a)
          end
        end
      end
    end
  end

  if (framestate == 'gameover') gameoverframes += 1
  
  if framestate == 'title' then
    if btnp'4' or btnp'5' then
      music(-1)
      sfx(14)
      genfloor()
      player()
      genroom()
      hist = {}
      for i = 1, floor.sz * 2 do hist[i] = {} end
      statepop()
      music(10)
    end
  else
    if framestate == 'gameover' and gameoverframes > 8 then
      if (btnp(4) or btnp(5)) _init()
    end
  
    pl.tped = false
  
    flamedmg = false
  
    genblocking()
    genpathlens()

    for a in all(_actors) do
      a:up()
    end

    if (framestate == 'enemy') statepop()
    if (framestate == 'entered') statepop()
    
    if flamedmg == true then
      hurt()
      flamedmg = false
    end
  end

  framestate = stack[#stack] or 'idle'
end

function drawscaled(sp, x, y, fx, fy)
  sspr(sp % 16 * 8, flr(sp / 16) * 8, 8, 8, x, y, 16, 16, fx, fy)
end

function shadowpal()
  for i = 0, 15 do pal(i, 0) end
end

function drawtitle()
  spr(202, 42, 16, 6, 2)
  print("of", 40, 30, 5)
  print("of", 40, 29, 6)
  print("el dorado", 51, 30, 4)
  print("el dorado", 51, 29, 10)

  spr(111, 35, 118)
  print('tom wright', 45, 121, 5)
  print('tom wright', 45, 120, 6)

  print('press \x8e or \x97 to start', 18, 63, 5)
  print('press \x8e or \x97 to start', 18, 62, 7)
end

function _draw()
  f += 1

  camera()
  cls()
  pal()

  if framestate == 'title' then
    drawtitle()
    return
  end

  -- print a dumb message on gameover for now
  if framestate == 'gameover' and gameoverframes > 60 then
    if won then
      print('you win', 50, 51, 5)
      print('you win', 50, 50, 7)
    else
      print('you lose', 50, 51 , 5)
      print('you lose', 50, 50 , 7)
    end
    local x = 64 - ((scoredigits + 7) * 4) / 2
    print('score: '..pl.score, x, 63, 4)
    print('score: '..pl.score, x, 62, 10)
    print('press \x8e or \x97 to restart', 14, 93, 5)
    print('press \x8e or \x97 to restart', 14, 92, 7)
    return
  end

  -- screen shake!!!!!!!!
  if ss > 0 then
    camera(rnd(ss * 2) - ss, rnd(ss * 2) - ss)
    ss -= 1
  end

  -- draw level
  for x = 0,7 do
    for y = 0,7 do
      local s = mget(x, y)
      if s ~= 0 then
        drawscaled(s, x * 16, y * 16)
      end
    end
  end

  -- draw actors
  for z = 1, 5 do
    for a in all(_actors) do
      if (a.z == z) a:d()
    end
  end

  -- draw life
  for i = 1, 4 do
    local s = 50
    if (pl.life >= i) s = 51
    sprol(s, 8 * i - 6, 1)
  end

  -- draw score
  local dx, dy = 0, 0
  if moneyshake > 0 then
    moneyshake -= 1
    dx, dy = rnd(2) - 1, rnd(2) - 1
  end
  scoredigits = 1
  local n = pl.score
  while n >= 10 do
    scoredigits += 1
    n /= 10
  end
  printol(pl.score, dx + 115 - 4 * scoredigits, dy + 120, 10)
  if pl.score > 0 then
    local sprites = {192, 193, 194, 195, 196}
    local s = sprites[scoredigits]
    sprol(s, 117, 117)
  end

  -- draw potions
  if #pl.potions > 0 then
    local x = 2
    local sym = '\x97'
    if (framestate == 'menu' or framestate == 'potaim') sym = '\x8e'
    printol(sym, x, 120, 7)
    x += 10
    for p in all(pl.potions) do
      local s = 21
      if (f % 210 == x + 1) s = 22
      if (f % 210 == x + 2) s = 23
      if (f % 210 == x + 3) s = 24
      shadowpal()
      sprol(s, x, 117)
      pal()
      pal(12, p.c)
      spr(s, x + 1, 118)
      x += 11
    end
    pal()
  end

  if lag then
    lag = false
    flip()
  end

--[[ pathlen debug
  for x=0,7 do
    for y=0,7 do
      local c = 12
      if (playerinlos(x, y)) c = 11
      print(pathlens[x][y], x*16, y*16, c)
    end
  end
--]]

--[[ doorway debug
  for x=0,7 do
    for y=0,7 do
      print(doorway(x,y) and 1 or 0, x*16, y*16, 12)
    end
  end
--]]
  
--[[ state debug
  printol(framestate, 64, 121, 12)
--]]

--[[ actors / stat debug
  printol(#_actors .. '  ' .. stat(1) .. '  ' .. stat(0), 0, 109, 12)
--]]

--[[ minimap debug
  rectfill(128-floor.sz*2-2,0,127,floor.sz*2+1,7)
  for x=1,floor.sz*2 do
    for y=1,floor.sz*2 do
      local c=0
      if (floor[x][y]~=-1) c=7
      if (pl.rx==x and pl.ry==y) c=11
      pset(128-floor.sz*2-2+x,y,c)
    end
  end
--]]
end

__gfx__
00000000004442000444400004442000004442000444200000000000000000000000000009009000000000000000000000000000000000000000000000000000
00000000004f44200444200004f44200004f4420444f20000002ee00000200200000000000900909090090090000000000000000aaa820000000000000000000
007007000ff1f10004442000ff1f10000fffff0001f1f0000000ee0000000ee00ee0002009909090099090990088820000888200a1a882000000000000000000
0007700000ffff000fffe0000ffff06000ffff000ffff0000020000000000ee00ee00000099909900090990902888880aaa88880aaac88800000000000000700
00077000068f806608778500068f8f60068f8066068f8066000000200ee00000002000209999999009909aa9cccccc88a1accc8888cccc82eeeeeeee000078ee
00700700f7878e50f8778e0007878f50f7878e50f7878e5000ee00000ee0000000000ee099a99a9999a99a99ccccccc8aaacccc8ccc9ccc88888888800008888
00000000044440000444400004444000044440000444400000ee20000200200002000ee09aaa9aa99aa9aaa9ccc99c9cccc99c9c00c19c9c0000000000002820
0000000004002000040020000400200004002000040020000000000000000000000000009a7777a99a7777a900c00c0000c00c0000000c0c0000000000000000
110000110044420004444000070c70c0007c0c700777777007777770077777700777777000000000080000000e121e0000000000000000000005070000050000
1c1001c1004f442004442000007cc70070070c70007cc700007cc700007cc700007777000000000000200000ee7e7ee000111100011110000007077000070000
01c11c100ff1f100044420000c7ccc0ccc0ccc00007cc700007cc700007c77000077c70000000000078000002777772000111100055251000007077000070000
001cc10000ffff660fffe500c7ccc7700ccccc00077cc770077cc77007777770077cc7708000000008800000ee7e7ee000111100085851000007077000070000
001cc100f68f8e50f8778e007cccccc700ccc0007cccccc77cccccc77c77777777ccccc7020000000002000000e2e10000111100055251000007777000070000
01c11c1007878000087780007ccccc007ccccc007cccccc77ccccc77777777c77cccccc778000888000808880001100000022000001110000007777000070000
1c1001c14444440004444000cccc0cccc7ccc77c7cccccc77cccc7c777777cc77cccccc788282822008028220001100000011000001100000007700000070000
1100001100000000000000000c770c700ccc0cc00777777007777770077777700777777000808200000082000000000000011000001100000007000000070000
77777776000000000000000000000000000000005666666507aaaaa007a00880000000000000000000222100e0e2e1e000000000000000000000000000000000
766666650001310000000000000000000000000065500006a944449a97a98788000000000111100002cec2100e7e7e1001111000111100000000000000000000
766666650003030000000000001001000110011006665556a447644a9aa9888800000000055251002c7c7c202777772005525100552510000000000000000000
766666650313000000000000000000000010010000066065aaa66aa909900880000000000656510002cec2100e7e7e1005525100858510007777777577777775
76666665030301310000000000000000000000007aaa6556a445544907c000000077aa000552510000222100e0e2e1e005525100552510007777000500000000
7666666500030303000600000010010000111100ae890656a24444290cc007b000a9940000111000000110000001100000111000011100000777770000000000
7666666503030300000600000000000000000000a8890666a22222290cc0bbb37aaaaaaa00110000000110000001100000110000001100000000777000000000
6555555513131310505605550000000000000000a99900009999999901100330a994a99400110000000000000000000000110000001100000000077700000000
77777776000000b00770770007707700000006607777777777777777777777767777777722222222eee0eee0e000e0e011000011000000000000000000000000
7666666500000e83700700707e878870000066667666666666666666666666656666666627777772e0e000e0eee0e0ee1c1001c10080880000cccc0009999000
755665550000e18370000070788882700000a7a9765555555555556666655665555555552777777200eee0ee00e0eee001c11c100088008000c000c009000900
76566565000e888307000700078827000000a7a9765856666659a56666655565b6666665277777720000e00000e0e0e0001cc1000080000000c000c009000900
7666666500e8188300707000007270000000aaa976555666665aa566666585653366666b27777772eeeee00000e0e0e0001cc1000080000000cccc0009000900
765555650e18888300070000000700000006aaa97665566666555555555555653555553327777772e00000eeeee0e0ee01c11c100080000000c0c00009000900
76666665b888883000000000000000006666a9997666666666666666666666653666666327777772eeeee0e0e000e0001c1001c10080000000c00c0009999000
65555555033333000000000000000000000000006555555555555555555555553555555322222222e000e0eeeeeee0ee11000011000000000000000000000000
7777777aaaa9aaa90000000000000000000000066666666666666666000000007777777777777777777777760010011001100000000000000000000000000000
7aaaaaa9a994a9940000000000000000000006656666666666666665666000007666666666666666666666650110010100001110000000000000000000000000
7aaaaaa9a994a9940000000000000000000666656666666666666665666600007666666666666666666666650000000000000110000200000000000000111000
7aaaaaa9944494440000000000000000006666656666666666666665666660007666666666666666666666651011100000000110006220000000000001010010
7aaaaaa9aaa9aaa90000000000000000006666665666666666676656666666007666666666666666666666650001000000010000002220000004900010000001
7aaaaaa9a994a9940000000000000000006666666565666666766566666666007666666666666666666666651000000000000001002220004441100000001000
7aaaaaa9a994a9940000000000000000056666666566566666766566666666507666666666666666666666650000000000000011000500001110055000111100
a9999999944494440000000000000000067776666566577777666566666666606555555555555555555555550000000000000010000500000000011000000000
aaaaaaa9aa9499999999a94466510156077677777656666666665677777777707777777677777777777777760000000000000000000000000000000000000000
aaaaaa94aa9499999999a94466650156066666666656666666665666666666607666666576666666666666650000000000000000000000000000000000000000
aa999944aa9499999999a94455650056566666666665666666656666666666657666666576666666666666650100000000000011000000000000000000000111
aa999944aa9499999999a94466501056666666666555555555555555666666667666666576666666666666650110100000000010011000000000000000010010
aa999944aa9499999999a944665005665555555556666666666666665555565676666665766666666666666500000000000000000010100000b00b0000111000
aa999944aa9499999999a94466555555666666666655556666655565666666667666666576666666666666650010000000011010011110000030030000000000
a9444444aa9499999999a94466666666666666677777656666656777776666667666666576666666666666651011000000001110011000000011030000100000
94444444aa9499999999a9445555555566666678e8e86656665678e8e86666667666666576666665766666651001100001101010000000000000011000000000
aaaaaaaaaaaaaaa9aaaaaaaa99999999666667888e8886655567888e888666667666666576666665766666650011001000111011000000000000000011100000
aaaaaaaaaaaaaa94aaaaaaaa9999999966666668e8e86666666668e8e86666667666666576666666666666650110000001111110000000000000000012100010
aa999999999999449999999999999999666666666666556666666666666566667666666576666666666666650000000000000001000000000000000011111010
aa944444444449444444444499999999666666555555566666666555555666667666666576666666666666650000000000000000000000000000000001001110
aa9499999999a94499999999aaaaaaaa6666666666666766666666666666666676666665766666666666666511000000000000110000a000000000000101100b
aa9499999999a94499999999999999996666666666666766666656666666666676666665766666666666666511000000000000110a0030a00000000001100b03
aa9499999999a9449999999944444444666666666666766666666566666666667666666576666666666666651100000000000001030010300055050000000303
aa9499999999a9449999999944444444666666666666666666666666666666667666666565555555555555550000000000000000011000110000000000001311
aa9499999999a9444444444444444444666666666665665566655656666666667666666577777776777757770000000000000000000000000000000021000012
aa9499999999a9444666666a4eeeee8a666666666665555555555556666666657666666575555565666566561000000000000010000000000000000011110111
aa9499999999a9444556655a4e88882a6666665666666666666666666656666676666665756666655555665610000000000000110000000000000b0001000001
aa9499999999a9444656656a4e88882a666665666666666666666666666566667666666575666665665005660000000000000000020000000000030101011100
aa94aaaaaaaaa9444666666a4e88882a666656655555555555555555556656657666666575666665665010560100000000000000226002260000011000012100
aa999999999999444655556a4e88882a666656556666666666666666655656657666666575666665655100550000000000001001222002220b01101001011101
a9444444444444444666666a4822222a566656666666666666666666666666657666666576666665650001560010010100000011622000500311000111000001
94444444444444444aaaaaaa4aaaaaaa556666666666666666666666666555556555555565555555510101050011001100110111050000000100000021100111
77777777777777777777777777777777777777777777777777777777777770007777777777777777777777761111111111111111111111110000000000000000
6666666665556666655555556555566676666666666666666666666666665000766666666666666666666665111111c111111111111111c10000000000000000
6555565555655555556666656566555676666666666666666656666566665066765555555555555555555565111111cc11111111111cccc10000000000000000
65225556666666666665556555666666766666565666666666566656666566607656666666666666666667651111ccccc1111c11111cc1110000000000000000
65225666665556555565656666655566766665665666666666566656665666507656666666666666666667651111cc000c11ccccc1ccc1110000000000000000
655555555556555665556555555565567665566656666666666565666565556576577777777777777777776511111cc00cccc0000c00ccc10000000000000000
666666666666666666666666666666667656656566666666666656666566666576666666666666666666666511111c00000c0000000cc1c10000000000000000
55555555555555555555555555555555766566656666666666665666566666656555555555555555555555551111cc0000000000000c11110000000000000000
77777777777777761b1001310001000076116661660000000006660066666665eeeeeee2222222212222222111111c0000070000000c11110000e00000000000
7666666666666665b1b113030301000000010001000000101100000666666665e1111121211111102111111011111c00007c700000cc1111000e8e0000000000
7655555665555565b313bb1b03b1000010111101010110001110000616666665e122222121221110211122101111cc0007ccc70000c1111100e888e000000000
7656565565656565b31b33b033b0330001101000110111000000111111666665e122222121222210212222101111c000077c7700000c111100ee8ee000000000
7655566565655565b133bbb03b03300001100100110000000001111111566665e122222121121210212121101111c00007c7c70c000cc11180e8e8e000000000
7665666665665665b33bb3b3bb3bb10000000000000110001000111166656665e12222212122111021112210111c000007c7c7c00000cc1108e8e8e000000000
7665565556665665b3b3b3b0b3b10b0000000000000000001000000066656665e22222212111111021111110111cc000cc17c710000cc11102e8e28800000000
7666555a97655665b313b3b0b3b100000000000000011110000000006666566521111111100000001000000011111c0011c11c10000c11110282282200000000
7666665aa766666500000100000000000000000000001100010111006666666522222221222222212222222111111c0000000000000c11110000000000000000
76655567775556650000b11b000000000011001000000000000000116666556521111110211111102111111011111c000cc000000000c1110000000000000000
76656665666656650000bb1b00000000001101110000001001011011666566652111111021221110211122101ccccccccccc0ccccccccc110000000000000000
7655566565555565003333bb00000000001100000000000000011011665666652111111021121210212121101c1cc111111ccc11111ccc110000000000000000
7656556555656565003033bb00000000010000000000110011011000665666652111111021222210212222101111c111111cc111111ccc110000000000000000
76555666666555650000113b00000000000011010000110011000011665666652111111021221110211122101111cc1111111111111cccc10000000000000000
7666666666666665000301330000000000011000000011000000111065666665211111102111111021111110111111111111111111111cc100e0000000000000
6555555555555555000033130000000000000011000000001101110656666665100000001000000010000000111111111111111111111111e088800800000000
00000000000000000000000000404000077051116660060066660066655666607777777677777776000000000000000000000000000000000000000000000000
00444200000000000000000004444000766065666556666556556666666556007666666575555565000000000000000000000000000000000000000000000000
004f44200000000000000000ff1f1000766666555656666665666666666665007666666575eee865000000000000000000000000000000000000000000000000
0ff1f10000044420000000000ffff560766655566665666666555666666666657656656575e88265000000000000000000000000000000000000000000000000
00ffff060044444000000000068f8600765566566666666665666666666666657666666575e88265000000000000000007000000000000000000000000000000
f7878e500044444600000440f78785007666666566666666656666666666666576655665758222650000000000000000070007c0000000000000000000000000
04444000f784444044477442044440007666666666666666666666666666666576666665766666650000000000000000cc10c710000000700000000000000000
04002000022220002228f22204002000655555555555555555555555555555566555555565555555000000000000000011c11c1c07c000c00000000000000000
00000000000000000000000000000000a0a0090900000000000000000000000000000000000000009aaaaaaaaa90000000000000000000000000000000000000
00000000000000000000000000000b30a0a0090900000000000000000000000000000000000000000aa0000009a9000000000000000000000000000000000000
00000000000000000000000000077330a7aa999900000000000000000000000000000000000000000aa00000009a000000000000000000000000000000000000
00000000000000000000aa0000aaaa90e8ae89e800000000000000000000000000000000000000000aa00000000a000000000000000000a00000000000000000
000000000000000000a7aa90078aaa9988a8898800000000000000000000000000000000000000000aa00000009a000000000000000000900000000000000000
000000000000a00007aaa990788a9999a7aa999900000000000000000000000000000000000000000aa0000009a9000000000000000000000000000000000000
00000000000999000aa99999aa999999a7aa999900000000000000000000000000000000000000000aaaaaaaaa9009aa99a0aa0aa0aa90a09a0aa00aa9000000
0090090000a99900aa99999999999999aaaa999900000000000000000000000000000000000000000aa009a900000a00a0a90a90a0a0a0a00a90a0a000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0009a00000aaa00a00a00a0a0a0a00a00a009a0000000
000000000000000000000000000000000000000000000000000000000000000000000000000000009aa9000a90000a9000a00a00a0a0a0a00a00a0000a000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaa0009aaa900aaa0a00a00a09aa9090a00a90aa9000000
__map__
594a35383837485a59494a202048495a59494a202048495a30484a484a484a30594949494949495a3538383838383837594949494949495a2020202020202020594a79484a79485a594949494949495a73414150504141735835363838363758202121204b00004c000000002121212130000030000000000021210044454647
78212121212121786800000000000068687d4d000000006858000000000000587821212121212178580000000000005868000000000000682000000000000020680068000068006868212121212121684100000000000041680050000000006821212121004e4e00002000202120202100000000212121210021210054555657
3000000000000030780030000030007878003d3d3d3d007878003d3d3d3d0078383837000035383868003d3d3d3d0068680035383837006820300030003000207800780000780078682130212130216841003d3d3d3d0041680050505050006821212121004e4e00000000002120202100000000212121210021210064656667
5800000000000058200000000020002020003d3d3d3d002058003d3d3d3d0058580000000000005868003d3d3d3d0068680000000030006820000000000000205800000000000058682158212158216850003d3d3d3d00506800000000000068202121205b00005c0048494a2121212130000030000000000021210074757677
7800000000000078200020000000002020003d3d3d3d002078003d3d3d3d0078780000000000007868003d3d3d3d0068680030000000006820000000000000207800000000000078682178212178216850003d3d3d3d005068000000000000685821215800595a00580020000000000000005800000000000021210060626100
3000000000000030580030000030005858003d3d3d3d005858003d3d3d3d0058383837000035383868003d3d3d3d0068680035383837006820003000300030205800580000580058682130212130216841003d3d3d3d00416800505050500068680000685968495a68000000487a4a000000694a353838373021213051725200
582121212121215868000000000000687800000000000078780000000000007858212121212121587800000000000078680000000000006820000000000000206800680000680068682121212121216841000000000000416800000000500068680000686949686a68002000004c000058000000353838373021213070637100
694a35383837486a69494a202048496a353637202035363730484a484a484a30694949494949496a3538383838383837694949494949496a2020202020202020694a79484a79486a694949494949496a734141505041417378353638383637787821217800696a00780000000000484a694a0000000000000021210000000000
202020202020202059494a202030485a353637202035363759494a202048495a2121583030582121594949494949495a30303030303030302020302020302020594949494949495a594949494949495a505041414141505035363838383836372121212100595a00000000003536373000000000000000006f5e212100000000
2000000000000020680000000058006858000000000000587800000000000078212168000068212168212121212121683000000000000030200000212100002068212121212121686821212121212168500000000000005030000000000000305949495a00686800005800580000000000200020003000305e7e212100606261
200035363700002078005949496a007878003d3d3d3d007837213d3d3d3d213548496a000069494a68213d3d3d3d216830000000484a003030003d3d3d3d0030682130484a3021686821302021302168410050000050004130006062626100306949496a00686800006800680000000000000000000000002121212100517352
2000000000000020200078000000002020003d3d3d3d002030003d3d3d3d0030300000000000003068213d3d3d3d2168300020000000003020213d3d3d3d212068212121212121686821582121582168410000000000004130005172725200302121212100696a004849496a3035363700200020003000302121212100706371
2000000000000020200000000058002020003d3d3d3d002030003d3d3d3d0030300000000000003068213d3d3d3d2168300000000020003020213d3d3d3d2120682121212121216868217821217821684100000000000041300051727252003000484a00000000000059494a5800000020002000300030000079790084858687
200000353637002058005949496a005858003d3d3d3d005837213d3d3d3d213548495a000059494a68213d3d3d3d21683000484a0000003030003d3d3d3d0030682130484a3021686821302120302168410050000050004130007063637100300021210058000058006858006800000000000000000000000000580094959697
20000000000000206800780000000068680000000000006858000000000000582121680000682121682121212121216830000000000000302000002121000020682121212121216868212121212121685000000000000050300000000000003000212100780000780078680068000000200020003000300000006800a4a5a6a7
20202020202020204a4a30202048496a69494a202048496a69494a202048496a2121783030782121694949494949496a30303030303030302020302020302020694949494949496a694949494949496a5050414141415050353638383838363700484a000000000048496a007800484a000000000000000000007800b4b5b6b7
79484a484a484a79594949494949495a594949494949495a594949494949495a79888a484a888a798b8c8c8c8c8c8c8d8b8c8c8c8c8c8c8d8b8c8c8c8c8c8c8d8b8c78484a788c8d00ae9898988c8c8d6062615050606261606261505060626100353637353838376f00006f484a005800000000888a00000000000030494930
5821215e5e4d7d586800000000000068689293000000006868936d00005ea26858007e00000000589b0000000000009d9b9c00000000009d9b0000000000009d9b0000000000009dae9e98000000009d517352212151735251725224245172520000000024242424005e4d0000000068580000000000007900888a0068606168
78212121217e5d787900a292929300796800000000000068785e000000005e7878009200a29300789b009c9c009c009d9b00009c9c00009d8a009c00009c00884a009cbd009c0048989899009a00009d706371212170637170637124247063710000000024242424007e5e005800006869494a00790000000000000068707168
5821212121217e5868005e6d6d5e00686800a292929300685800936e6ea2005879009200000000799b000000009c009d9b000000009c009d580000000000005858000000000000589800009e000000985021212121212150502424242424245035363700353838376f00006f6949496a000000000000888a00888a0030494930
7821212121215e7868005e6d6d5e00686800a292929300687800936e4ea2007879000000009200799b0000000000009d9b000000009c009d780000000000007878000000000000789800a900aa9800985021212121212150502424242424245020000000357a3700353837009898009898980000000000009900009a00000000
58212121212121587900a292929300796800000000000068585e000000006d585800a293009200589b009c009c009c9d9b009c000000009d8a009c00009c00884a009c00bdbc00489b0000009800009d6062612121606261606261242460626100000020004b000000000000980000009898000000aaa900003b3b0000414100
7821216d5e21217868000000000000686800000000a2926868937d00005ea26878000000007e00789b0000000000009d9b00000000009c9d9b0000000000009d9b0000000000009d9b0000000000009d517352212151735251725224245172522000000000007c00000000000000009800009898009a9900003a3b0000414100
79484a484a484a79694949494949496a694949494949496a694949494949496a79888a484a888a79abacacacacacacadabacacacacacacadabacacacacacacadabac58484a58acadabacac9898acacad70637150507063717063715050706371000000200035533700353837980098980000989800000000a90000aa00000000
59494a484a208c8d594949494949495a597a494949497a5aa8a8a8a8a8a8a8a8594949494949495a000059494949495a59494a303048495a594949494949495a594949494949495a594a84989898485a594980818283495a98989898989898989900009a9c00bdbc4e4e4e4e2020007979002020002400247900484a00000000
680000000000009d68000000000000686800000000000068a8000000000098a87800000000000068000068000000006868000000000000686800000000000068680000000000006878989800009a0078683000000000306898999900009a9a98009eae00000000004e98984e2020000000002020240024000000000000000000
68000000009c9c9d680079797900006868003d3d3d3d00689b000000000000a8a80000000000006848496a00580000787800000000000078680041000041006868484a0000484a68580000000000005868004e4e4e4e006898999900009a9a9800aeae00bd9c9c004e98984e000000585800000000240024000000000000b800
6800000000000058680000007900006868003d3d3d3d00689b000000009800a8a80099a9009900685800000068000058300000000000003068000000000000686800b90000b90068680000980000006868004e90914e00689800000000000098a90000aa000000004e4e4e4e484a00787800202024002400484a007900000000
680088898a000078680000790000007868003d3d3d3d00689b00009e000000a8a8009a00009a0068780048496a000078300000000000003068000000000000686800000000000068680000000098006868004ea0a14e00689800000000000098304a0000000048307d4d7d4d00000000a2929293000000797900000000000000
6800000000000058680000000059494a68003d3d3d3d00689b9e0000000000a8a800aa00a9aa006858000000000000587979790000000058680041000041006868008889898a00687800a9000098007868004e4e4e4e006898a9a90000aaaa9878000000000000787d98987d0000000000000000007900000000790041414100
6800000000000068680000000068000068000000000000689b000000009800a8a8000000000000686800000000000068bd9c790000000068680000000000006868000000000000685800000000000058683000000000306898a9a90000aaaa9800000058580000007d98987d0000000000000000007900000000790041c44100
694949494949496a694949494a780000695349494949b96aabaca8a8a8a8a8a8a8a8a8a8a8a8a86a694949494949496aacac79303048496a694949494949496a694949494949496a694a4849494a486a694980818283496a989898989898989800004830304a00004d7d4d7da292929300000000000000797900000041414100
__gff__
0000000000000000000000000000000002000000000000000000000000000000020000000080000000000000000000000200000000020202020200000200000002020000020202020202020000000000020202020202020202020200000000000202020202020202020202000000000002020202020202020202020000000000
0202020202020202020202020202000002020202000000020202020202020200020202000000000202020202020200000000000002020202020200000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300002a0502b0502b0502c0502c0502d0502f0502f040310303403034010025000150002500015000150000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f355183551c355213551a3551d355233551c3551f355243551d355233552435024330243202432024320243202432024320303053030530305303050030500305003050030500305003050030500305
00020000026700266102650026400364003641046300463005620056210561005610056100561102610016102f7002f7012f7002f7002e7002e7012e7002e7003070030702307023070230702307023070230705
01160000181730910009100091000910009100091000910009100091000910009100091000910009100091000a1000a1000a1000a1000a1000a1000a1000a1000a1000a1000a1010a1010a1010a1000a1000a100
010200000e3700e3701137011370153701537018370183701a3701a3701a3701a3701c6001c6001c6001c6001c6001c6001c6001c6000e3000e3001130011300153001530018300183001a3001a3001a3001a300
010300001862300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b2301b2401b2501b2501b2501b2501b26018270182601826018260182601826018250182401824018230182301823018220182201822018220182201820018200000000000000000000000000000000
011000001f0501c0501a0501805018050180501805018050180001800018000180001800018000180001800000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000003620076300b6300f630156301c63023640396403c5503055034550375503c5503c5503c5503c5503c500000000000000000000002160000000000000000000000000000000000000000000000000000
01030000223511f3511f3511d3511b3411b331183211832118301013000b3000b3000a3000a300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002405324603000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001c35300620006110060100601006010060100601006010060100601006010060100601006010060100000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b32018320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000245502b5502d5502200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000185501f550245502450024530000002451000000245100000000000000002450018500000000000018500000000000000000185000000000000000000000000000000000000000000000000000000000
01080000183000c003305300c50030510000003050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00003553038550385003851038500385103850000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000600000b1500a1500a1500b150111500f1500e150111002210011100161001b10029100181001d1001d10000400004000040000400004000040000400004000040000400004000040000400004000040000400
010a0000272202722027220272312723027241272402724030550005510c551000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002c6702c6702c6702c6702c6402c6202c6102b6102a6002a6002a60029600296002960029600296002a6002a6002a6002a6002a6000000000000000000000000000000000000000000000000000000000
010a00000e4361043613436104360e446134460e4461044630550005510c551130060e0061000613006100060e006000060000600006000060000600006000060000600006000060000600006000060000600006
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002455024540245402b5502d55028500285502b5002b5502b5402b5422b542000000000000000000002455024540285502b5502d5502d50028550285002855028540285422854228500285000000000000
011000002455024540245402b5502d5502b500245502d500215502154021532215321f50028500215502950027550285412854226551265422654223552235422455024540245402453224500245001505015040
011000001305013040130401304010050100401305013040170501704017042170421704217042150501504013050130401304013040120501204012040120401305013040130421304213042130421205012040
01100000100501004010040100400c0500c040100501004013050130401304213042130421304513050130401505015040150401504012050120401305013040100501004010042100421c0001c0051f5501f540
014000000c7100c7100c7100c71013710137101371013710187030c7000c70030705307050c700307050c700187030070000700307053070500700307050c700187030c7000070030705307050c700307050c700
010400003060500000306053060530605306053060500000306050000000000306053060530605306050000000030000200001000010020000200002000020000003000020000100001000000000000000000000
01040000245502b550305503051030510305103051030510305002450024500245003050024500245002450021520215202152021520215202152021520215202353023530235302353023530235302353023530
011000000003500035040350703500035000350403507035000350003504035070350003500035070350403500035000350403507035000350003504035070350003500035040350703500035000350703504035
011000200003500035000350003507035070350003500035090350903509035090350903509035090350903507035070350003500035070350703500035000350903509035090350903507035070350403504035
011000200703300000000000000000000000000703300000246350060300000000000000000000070030000007033006030703300000000000000007033000002463500000070330000024635000000000000000
014000000713504100001050413507135001000410004135001350e1000e1000e1000e1000e1000e1000e100071350c1000c10004135071350c1000c100041350013500100001000010000100001000010000100
0120000024745277452970024745297402a7412974504105247450e1000e1000e1000e1000e1000e1000e10024745277450c10024745297402a74129745041052474500100001000010000100001000010000100
01200000297452b74529745247052e745307452e7453070530745297402a741297402974527745247451870524745277452970024745297402a741297450410524745297002a7012970029705277052470518705
011000102b515245052b515245052b515245052b515245052b515245052b515245052b515245052b515245052b505245050750500505005050050507505005052450500505075050050524505005050050500505
014000000a13504100001050513503135001000410005135061350e1000e10003135001350e1000e100031350513506135071350c1350f1350c1000c1000c1350a13500100001000c13500135001050010000100
__music__
01 1e1d5f44
01 181f5f44
00 191f4344
00 1a204344
02 1b204344
02 21224344
00 60424344
00 60424344
00 41424344
00 41424344
01 215f1f65
00 211f6244
00 211f6244
00 211f6544
00 211f5c65
00 211f6244
00 211f6544
02 211f6665
00 21622344
02 21652444
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000009aaaaaaaaa9000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000aa0000009a900000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000aa00000009a00000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000aa00000000a000000000000000000a0000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000aa00000009a00000000000000000090000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000aa0000009a900000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000aaaaaaaaa9009aa99a0aa0aa0aa90a09a0aa00aa900000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000aa009a900000a00a0a90a90a0a0a0a00a90a0a00000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000aa0009a00000aaa00a00a00a0a0a0a00a00a009a000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000009aa9000a90000a9000a00a00a0a0a0a00a00a0000a00000000000000000000000000000000000000000000
000000000000000000000000000000000000000000aaaa0009aaa900aaa0a00a00a09aa9090a00a90aa900000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000006606660000aaa0a0000000aa000aa0aaa0aaa0aa000aa000000000000000000000000000000000000000000
000000000000000000000000000000000000000065606550000a440a0000000a4a0a4a0a4a0a4a0a4a0a4a000000000000000000000000000000000000000000
000000000000000000000000000000000000000060606600000aa00a0000000a0a0a0a0aa40aaa0a0a0a0a000000000000000000000000000000000000000000
000000000000000000000000000000000000000060606500000a400a0000000a0a0a0a0a4a0a4a0a0a0a0a000000000000000000000000000000000000000000
000000000000000000000000000000000000000066506000000aaa0aaa00000aaa0aa40a0a0a0a0aaa0aa4000000000000000000000000000000000000000000
00000000000000000000000000000000000000005500500000044404440000044404400404040404440440000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077707770777007700770000007777700000007707770000007777700000077700770000007707770777077707770000000000000000000
00000000000000000075707570755075507550000077555770000075707570000077575770000057507570000075505750757075705750000000000000000000
00000000000000000077707750770077707770000077070770000070707750000077757770000007007070000077700700777077500700000000000000000000
00000000000000000075507570750055705570000077050770000070707570000077575770000007007070000055700700757075700700000000000000000000
00000000000000000070007070777077507750000057777750000077507070000057777750000007007750000077500700707070700700000000000000000000
00000000000000000050005050555055005500000005555500000055005050000005555500000005005500000055000500505050500500000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000121000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000111110100066600660666000006060666066600660606066600000000000000000000000000000000000000000000
00000000000000000000000000000000000010011100056506560666000006060656056506550606056500000000000000000000000000000000000000000000
000000000000000000000000000000000000101100b0006006060656000006060665006006000666006000000000000000000000000000000000000000000000
0000000000000000000000000000000000001100b030006006060606000006660656006006060656006000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003030006006650606000006660606066606660606006000000000000000000000000000000000000000000000
00000000000000000000000000000000000000013110005005500505000005550505055505550505005000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
