$patch = @'

[SEARCH]
function player_collision()
	local c = pget(player_x + 2 + player_spr, player_y + 4)

	if c ~= 11 then
[REPLACE]
function player_collision()
	local hit=false
	local px=player_x+2+player_spr
	local py=player_y+4
	for i=1,eb_count do
		local dx=eb_x[i]-px
		local dy=eb_y[i]-py
		if dx*dx+dy*dy<16 then hit=true break end
	end
	if not hit then
		local dx=enemy_x-px
		local dy=enemy_y-py
		if dx*dx+dy*dy<100 then hit=true end
	end
	if hit then
[/]
'@
$patch = $patch -replace "\r\n", "
"
Add-Content -NoNewline -Path "carts/unh-3.p8t" -Value "
$patch"
