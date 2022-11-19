pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--main
function _init()
	state=0
	create_stars()
end

function _update60()
	if state==0 then
		updt_title()
	elseif state==1 then
	 updt_game()
	elseif state==2 then
	 updt_gameover()
	end
end

function _draw()
	if (state==0) draw_title()
	if (state==1) draw_game()
	if (state==2) draw_gameover()
end
-->8
--functions

--box collision pos
function abs_box(s)
	box={}
	box.x1 = flr(s.box.x1 + s.x)
	box.x2 = flr(s.box.x2 + s.x)
	box.y1 = flr(s.box.y1 + s.y)
	box.y2 = flr(s.box.y2 + s.y)
	return box
end

--detect collision
function coll(a,b)

	box_a = abs_box(a)
	box_b = abs_box(b)
	
	if box_a.x1 > box_b.x2
	or box_a.y1 > box_b.y2
	or box_a.x2 < box_b.x1
	or box_a.y2 < box_b.y1 then
		return false
	else
		return true
	end
end

-- horizontal text center
function h_txt_cntr(str)
	return 64-#str*2
end

-- vertical text center
function v_txt_cntr()
	return 61
end
-->8
--state functions

-- ** title **
function updt_title()
	if (btn(❎)) init_game()
end

function draw_title()
	cls()
	ttlstr="the recycler"
	strtstr="press ❎/x to start"
	print(
		ttlstr,
		h_txt_cntr(ttlstr),
		10,
		7
	)
	print(
		strtstr,
		h_txt_cntr(strtstr),
		v_txt_cntr()+40,
		6
	)
end

-- ** game **
function init_game()
	t=0
	score=0
	bullets={}
	enemies={}
	init_plyr()
	state=1
	expls={}
	timetogo=0
	init_vacumm_part()
 init_upgd()
	scraps={}
end

function updt_game()
	if hastochooseupgd==0 then
		t+=1
		
		updt_stars()
		updt_expls()
		updt_enemies()
		updt_scraps()
		updt_plyr()
		updt_vcm()
		updt_bullets()
		
		
		if timetogo<=0 
		and plyr.hp<=0 
		and chck_plyr_bllt()==0 then
			state=2
		end
		if (timetogo>0) timetogo-=1
		
		if #enemies==0 then
			spwn_enemies(flr(rnd(9))+1)
		end
	else--upgrade menu
		updt_upgd()
	end
end

function draw_game()
	cls()
	--stars
	for s in all(stars) do
		pset(s.x,s.y,s.col)
	end
	--scraps
	drw_scraps()
	--expls
	drw_expls()
	--enemies
	drw_enemies()
	--ship
	drw_plyr()
	--vacuum cleaner
	drw_vcm()
	--bullets
	for b in all(bullets) do 
		spr(b.sprt,b.x,b.y)
	end
	--** hud **
	drw_hud()
	--upgrade menu
	drw_upgd()
end

-- ** game over **
function updt_gameover()
	if btn(❎)
	and isshting==0 then
	 init_game()
	elseif btn(❎)==false
	   and isshting==1 then
		isshting=0
	end
end

function draw_gameover()
	cls()
	gmstr="game over"
	scrstr="score: "..score
	rstrtstr="press ❎/x to restart"
	print(
		gmstr,
		h_txt_cntr(gmstr),
		v_txt_cntr()-14,
		10
	)
	print(
		scrstr,
		h_txt_cntr(scrstr),
		v_txt_cntr(),
		7
	)
	print(
		rstrtstr,
		h_txt_cntr(rstrtstr),
		v_txt_cntr()+40,
		6
	)
end
-->8
--stars

function create_stars()
	stars={}
	for i=1,20 do
		star={
			x=rnd(128),
			y=rnd(128),
			col=13,
			speed=0.75
		}
		add(stars,star)
	end
	for i=1,10 do
		star={
			x=rnd(128),
			y=rnd(128),
			col=7,
			speed=3
		}
		add(stars,star)
	end
end

function updt_stars()
	for s in all(stars) do 
		s.y+=s.speed	
		if s.y >= 128 then
			s.y=-rnd(60)
			s.x=rnd(128)
		end
	end
end
-->8
--player

function init_plyr()
	isshting=0
	isvcm=0
	plyr={
		stype="p",
		x=60,
		y=90,
		speed=1,
		hp=3,
		hpmax=3,
		box={x1=2,x2=5,y1=1,y2=6},
		sprt=0,
		flamespr=16,
		timetoshoot=11,
		invul=0,
		ammo=30,
		ammomax=30,
		scraps=0,
		smax=2
	}
end

function updt_plyr()
	
	if (plyr.hp<=0) return

	fsmax=19
	fsmin=16
	plyr.sprt=0
	
	if plyr.timetoshoot>0 then
		plyr.timetoshoot-=1
	end
	if plyr.invul>0 then
		plyr.invul-=1
	end
	
	if btn(➡️) 
	and plyr.x+plyr.speed<=120
	and btn(⬅️)==false then
		plyr.x+=plyr.speed
		plyr.sprt=2
		fsmax=23
		fsmin=20
	end
	if btn(⬅️)
	and plyr.x-plyr.speed>=0 
	and btn(➡️)==false then
	 plyr.x-=plyr.speed
	 plyr.sprt=1
	 fsmax=23
	 fsmin=20
	end
	if btn(⬆️)
	and plyr.y-plyr.speed>=0 then
		plyr.y-=plyr.speed
	end
	if btn(⬇️)
	and plyr.y+plyr.speed<=120 then
		plyr.y+=plyr.speed
	end
	
	if btn(❎)
	and plyr.timetoshoot==0
	and isvcm==0 
	and plyr.ammo>0 then
		shoot(plyr)
		plyr.timetoshoot=8
		plyr.ammo-=1
		isshting=1
	end
	if (btn(❎)==false) isshting=0
	
	if btn(🅾️)
	and isshting==0
	and vcm.needfullcharg==0 then
		isvcm=1
	else
		isvcm=0
	end
	
	--animate player flame
	if (t%4==0) then
		if (plyr.flamespr>=fsmax)
		or (plyr.flamespr<fsmin) then
			plyr.flamespr=fsmin
		else
		 plyr.flamespr+=1
		end
	end
	
	--check collisions
	for e in all(enemies) do
		if coll(e,plyr) then
			plyr_take_dmg(1)
		end
	end	
end

function plyr_take_dmg(dmg)
	if plyr.invul<=0 then
		plyr.hp-=dmg
		if plyr.hp <= 0 then
			explod(plyr.x+4,plyr.y+4)
			--time to game over
			timetogo=80
		else
			plyr.invul=120
		end
	end
end

function drw_plyr()

	if (plyr.hp<=0) return
	
	if plyr.invul>0 then
		if sin(t/10)<0.1 then
			draw=true
		else
			draw=false
		end
	else
		draw=true
	end
	
	if draw then
		spr(plyr.sprt,plyr.x,plyr.y)
		spr(
			plyr.flamespr,
			plyr.x,
			plyr.y+8
		)
	end
end
-->8
--enemies

function spwn_enemies(nb)
	gap=(128-8*nb)/(nb+1)
	for i=1,nb do
		enemy={
			stype="e",
			x=flr(gap*i+8*(i-1)),
			y=-flr(rnd(49)),
			life=3,
			speed=0.2,
			hp=3,
			box={x1=0,x2=7,y1=0,y2=7},
			flamespr=24,
			flsh=0,
			firerate=flr(rnd(111))+80,
			timetosht=flr(rnd(101))+30
		}
		add(enemies,enemy)
	end
end

function updt_enemies()
	for e in all(enemies) do
		e.y+=e.speed
		e.flsh-=1
		if (e.x>0) e.timetosht-=1
		
		if e.timetosht==0
		and e.x>0 then
			shoot(e)
			e.timetosht=e.firerate
		end
		
		--animate enemy flame
		if (t%4==0) then
			if e.flamespr == 27 then
				e.flamespr=24
			else
			 e.flamespr+=1
			end
		end
		
		--del enemy out of the screen
		if e.y >= 135 then
			del(enemies,e)
		end
	end
	
end

function e_take_dmg(e,dmg) 
	e.hp-=dmg
	e.flsh=4
	if e.hp <= 0 then
		explod(e.x+4,e.y+4)
		add_scrap(e.x,e.y,e.speed)
		del(enemies,e)
		score+=100
	end
end

function drw_enemies()
	for e in all(enemies) do
		if e.flsh>0 then
			for i=1,15 do
				pal(i,7)
			end
		end
		spr(32,e.x,e.y)
		spr(
			e.flamespr,
			e.x,
			e.y-8
		)
		pal()
	end
end
-->8
--bullets

function getbllttype(tp)
	local b={}
	if tp=="p" then
		b={
			sprt=48,
			box={x1=3,x2=4,y1=0,y2=2},
			speed=2.5,
			bsfx=0
		}
	elseif tp=="e" then
		b={
			sprt=49,
			box={x1=3,x2=4,y1=5,y2=7},
			speed=-0.5,
			bsfx=nil
		}
	end
	return b
end

function shoot(s)
	b=getbllttype(s.stype)
	bullet={
		btype=s.stype,
		x=s.x,
		y=s.y,
		speed=b.speed,
		box=b.box,
		sprt=b.sprt
	}
	add(bullets,bullet)
	if (b.bsfx!=nil) sfx(b.bsfx)
end

function updt_bullets()
	for b in all(bullets) do
		b.y-=b.speed
		if b.y < -7 
		or b.y > 135 then
			del(bullets,b)
		end
		
		if b.btype=="p" then
			for e in all(enemies) do
				if coll(b,e) then
					del(bullets,b)
					e_take_dmg(e,1)
				end
			end
		elseif b.btype=="e" then
			if coll(b,plyr) 
			and plyr.hp>0 
			and plyr.invul<=0 then
				del(bullets,b)
				plyr_take_dmg(1)
			end
			if coll(b,vcm) 
			and isvcm==1 then
				local vacuumed=vacuum(b)
				if vacuumed==1 then
					plyr.ammo+=5
					if (plyr.ammo>plyr.ammomax) plyr.ammo=plyr.ammomax
					del(bullets,b)
				end
			end
		end
		
	end
end

function chck_plyr_bllt()
	for b in all(bullets) do
		if (b.btype=="p") return 1
		return 0
	end
end
-->8
--hud
function drw_hud() 
	--score
	print(
		score,
		h_txt_cntr(tostr(score)),
		2,
		10
	)
	--hp bar
	rect(8,3,32,6,5)
	if plyr.hp>0 then
		rectfill(
			9,
			4,
			9+(plyr.hp*22/plyr.hpmax),
			5,
			8
		)
	end
	spr(50,1,1)
	--scraps bar
	rect(102,3,126,6,5)
	if plyr.scraps>0 then
		rectfill(
			103,
			4,
			103+(plyr.scraps*22/plyr.smax),
			5,
			6
		)
	end
	spr(51,95,1)
	--ammo bar
	if plyr.ammo==0 then
		pal(3,8)
		pal(11,9)
	elseif plyr.ammo/plyr.ammomax<=0.3 then
		pal(3,9)
		pal(11,10)
	end
	rect(1,60,3,126,3)
	if plyr.ammo>0 then
		rectfill(
			2,
			61+(65-(plyr.ammo*65/plyr.ammomax)),
			2,
			125,
			11
		)
	end
	print("ammo",5,122,3)
	pal()
	--energy bar
	if vcm.energy<vcm.gemax then
		if vcm.needfullcharg==1 then
			pal(1,8)
			pal(12,14)
		elseif vcm.energy/vcm.gemax<=0.3 then
			pal(1,9)
			pal(12,10)
		end
		rect(5,60,7,120,1)
		if vcm.energy>0 then
			rectfill(
				6,
				61+(59-(vcm.energy*59/vcm.gemax)),
				6,
				119,
				12
			)
		end
		print("ge",9,116,1)
		pal()
	end
end
-->8
--explosions
function explod(ex,ey)
	local expl={}
	local prt={
		x=ex,
		y=ey,
		sx=0,
		sy=0,
		age=0,
		mxage=0,
		colr=7,
		sz=9
	}
	
	add(expl,prt)
	for i=1,30 do
		local prt={
			x=ex,
			y=ey,
			sx=rnd()*4-2,
			sy=rnd()*4-2,
			age=rnd(3),
			mxage=10+rnd(15),
			colr=7,
			sz=rnd(4)+1
		}
		
		add(expl,prt)
	end
	add(expls,expl)
end

function updt_expls()
	for e in all(expls) do
		for p in all(e) do
			p.x+=p.sx
			p.y+=p.sy
			p.sx=p.sx*0.87
			p.sy=p.sy*0.87
			
			if (p.age>4) p.colr=10
			if (p.age>7) p.colr=9
			if (p.age>11) p.colr=8
			if (p.age>16) p.colr=2
			if (p.age>20) p.colr=5
			
			p.age+=1
			if p.age>p.mxage then
				p.sz-=0.2
				if (p.sz<=0) del(e,p)
			end
		end
		if (#e==0) del(expls,e)
	end
end

function drw_expls()
	for e in all(expls) do
		for p in all(e) do
			circfill(p.x,p.y,p.sz,p.colr)
		end
	end
end
-->8
--vacuum cleaner
function init_vacumm_part()
	vcm={
		x=plyr.x,
		y=nil,
		box={x1=0,x2=7,y1=0,y2=14},
		vspeed=0.6,
		energy=nil,
		gemax=45,
		chargspeed=0.15,
		dischargspeed=0.55,
		needfullcharg=0
	}
	vcmpart={}
	vcm.y=plyr.y-vcm.box.y2-1
	vcm.energy=vcm.gemax
	for i=1,25 do
	
		local prt={
			px=rnd(vcm.box.x2),
			py=rnd(vcm.box.y2),
			x=0,
			y=0,
			colr=flr(rnd(3))+5
		}
		
		add(vcmpart,prt)
	end
end

function updt_vcm()
	if (plyr.hp<=0) isvcm=0
	
	if isvcm==0 
	and vcm.energy<vcm.gemax then
		vcm.energy+=vcm.chargspeed
		if vcm.energy>=vcm.gemax then
		 vcm.energy=vcm.gemax
		 vcm.needfullcharg=0
		end
	end
	
	if isvcm==1 then
		vcm.energy-=vcm.dischargspeed
		vcm.x=plyr.x
		vcm.y=plyr.y-vcm.box.y2-1
		for v in all(vcmpart) do
			v.py+=vcm.vspeed
			v.y=plyr.y-vcm.box.y2-1+v.py
			if v.px<3.3 then
				v.px+=0.07
			elseif v.px>3.7 then
				v.px-=0.07
			end
			v.x=plyr.x+v.px
			if (v.py>=vcm.box.y2) then
				v.py=rnd(2)
				v.px=rnd(vcm.box.x2)
				v.colr=flr(rnd(3))+5
			end
		end
		
		if vcm.energy<=0 then
			vcm.energy=0
			vcm.needfullcharg=1
		end
	end
end

function drw_vcm()
	if isvcm==1 then
		for v in all(vcmpart) do
			pset(v.x,v.y,v.colr)
		end
	end
end

function vacuum(o)
	o.y+=vcm.vspeed
	if (o.x+o.box.x2
					<
					plyr.x+(vcm.box.x2/2)) then
 	o.x+=0.2
 else if (o.x+o.box.x1
					>
					plyr.x+(vcm.box.x2/2))	then
		o.x-=0.2
	end end 							
	if (o.y+o.box.y2)>=(plyr.y-1) then
		--return 1 if is vacuumed
		return 1
	end
	return 0
end
-->8
--scraps
function getscrptype(x,y,spd)
	local s={}
	local r=flr(rnd(100))
	if r>=0
	and r<19 then
		s={
			typ="h",
			sprt=53,
		 x=x,
		 y=y,
		 speed=spd,
		 box={x1=0,x2=7,y1=0,y2=7}
		}
	else
		s={
			typ="n",
			sprt=52,
		 x=x,
		 y=y,
		 speed=spd,
		 box={x1=0,x2=7,y1=0,y2=7}
		}
	end
	return s
end

function add_scrap(x,y,spd)
	
	local scrap=getscrptype(x,y,spd)
	
	add(scraps,scrap)
end

function updt_scraps()
	for s in all(scraps) do
		s.y+=s.speed
		if coll(s,vcm) 
		and isvcm==1 then
			local vacuumed=vacuum(s)
			if vacuumed==1 then
				plyr.scraps+=1
				if s.typ=="h"
				and plyr.hp<plyr.hpmax then
				 plyr.hp+=1
				end
				if plyr.scraps==plyr.smax then
					lvl_up()
				end
				del(scraps,s)
			end
		end
			
		--del scrap out of the screen
		if s.y >= 135 then
			del(scraps,s)
		end
	end
end

function drw_scraps()
	for s in all(scraps) do
		spr(s.sprt,s.x,s.y)
	end
end
-->8
--upgrade
function getupgd()
	local u={}
	local r=flr(rnd(100))
	if r>=0
	and r<19 then
		u={
			typ="h",
			sprt=64,
		 val=1,
			txt1="shield max +1",
			txt2="current: "..plyr.hpmax
		}
	elseif r>=20
	   and r<39 then
		u={
			typ="cs",
			sprt=70,
		 val=0.05,
			txt1="charging speed +0.05",
			txt2="current: "..vcm.chargspeed
		}
	elseif r>=40
	   and r<69 then
		u={
			typ="ec",
			sprt=66,
		 val=5,
			txt1="energy max +5",
			txt2="current: "..vcm.gemax
		}
	else
		u={
			typ="ac",
			sprt=68,
		 val=10,
			txt1="ammo max +10",
			txt2="current: "..plyr.ammomax
		}
	end
	return u
end

function init_upgd()
	hastochooseupgd=0
	scraptoaddonmax=1
	up1=nil
	up2=nil
	curspos=nil
end

function updt_upgd()
	if (curspos==nil) curspos=1
	
	if curspos==1
	and btn(⬇️) then
		curspos=2
	end
	
	if curspos==2
	and btn(⬆️) then
		curspos=1
	end
	
	if (btn(❎) 
		or btn(🅾️)) 
	and isshting==0
	and isvcm==0 then
		if (curspos==1) apply_upgd(up1)
		if (curspos==2) apply_upgd(up2)
	elseif btn(❎)==false
	   and isshting==1 then
	   isshting=0
	elseif btn(🅾️)==false
	   and isvcm==1 then
	   isvcm=0 
	end
end

function drw_upgd()
	if hastochooseupgd==1 then
		local title="choose an upgrade"
		print(
			title,
			h_txt_cntr(tostr(title)),
			16,
			7
		)
		--up1
		if curspos==1 then
			rect(8,30,119,68,7)
		end
		rect(10,32,117,66,11)
		rectfill(11,33,116,65,3)
		spr(up1.sprt,16,41,2,2)
		print(up1.txt1,34,44,11)
		print(up1.txt2,34,50,6)
		
		--up2
		if curspos==2 then
			rect(8,75,119,113,7)
		end
		rect(10,77,117,111,11)
		rectfill(11,78,116,110,3)
		spr(up2.sprt,16,86,2,2)
		print(up2.txt1,34,89,11)
		print(up2.txt2,34,95,6)
	end
end

function lvl_up()
	hastochooseupgd=1
	
	up1=getupgd()
	up2=getupgd()
	while up1.typ==up2.typ do
	 up2=getupgd()
	end
end

function apply_upgd(up)
	
	if up.typ=="h" then
		plyr.hpmax+=up.val
	elseif up.typ=="cs" then
		vcm.chargspeed+=up.val
	elseif up.typ=="ec" then
		vcm.gemax+=up.val
	elseif up.typ=="ac" then
		plyr.ammomax+=up.val
	end
	
	plyr.scraps=0
	plyr.timetoshoot=11
	plyr.smax=plyr.smax+scraptoaddonmax
	scraptoaddonmax+=scraptoaddonmax
	
	hastochooseupgd=0
	up1=nil
	up2=nil
	curspos=nil
end
__gfx__
00066000000066000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd00000ddd0000ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd00000ddd0000ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80d7cd0808c7dd8008dd7c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d9dccd9d0dccd9d00d9dccd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d9dccd9d0dccd9d00d9dccd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d99dd99d0d9d99d00d99d9d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050dd050005dd500005dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777007777770077777700777c7c00c7c0777777007777770077777700c7cc7c00000000000000000000000000000000000000000000000000000000000000000
c7c00c7c77700777c7c00c7c0c0000c00c7cc7c0077777700c7cc7c000c00c000000000000000000000000000000000000000000000000000000000000000000
0c0000c0c7c00c7c0c0000c00000000000c00c000c7cc7c000c00c00000000000000000000000000000000000000000000000000000000000000000000000000
000000000c0000c000000000000000000000000000c00c0000000000000000000000000000008000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008000000088000000800000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008800000877800000880000000800000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000087780000777700008778000008800000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000077770000777700007777000087780000000000000000000000000000000000
00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01211210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21211212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21288212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01288210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00187100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00122100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb000000000005555555500dd000005650065d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb0000000000056766665000d0000005600666006dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000
000330000000000056766665d006d555000005550063b96000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000055766655dd666d55565000000d93b9d600000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000576665000d666dd5660005003bbbbbd00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000008800005566550000d600d057505500693b9d000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ee000005555000000d000056606500063b90d00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000ee000000550000000dd00005505500000060900000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000066666600000000000555500000000000060060000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000066666600000000005666650000000000060060000000000000000000000000000000000000000000000000000000000000000000000
55667676666666550000dddddddd0000000005666650000000000060060000000000000000000000000000000000000000000000000000000000000000000000
5566767666666655000ddccccccdd000000056666665000000000dddddd000000000000000000000000000000000000000000000000000000000000000000000
5566667666666655000ddccccccdd000000056666665000000000dddddd000000000000000000000000000000000000000000000000000000000000000000000
5566766666666655000dddddddddd000000055666655000000000dddddd000000000000000000000000000000000000000000000000000000000000000000000
5566767666666655000ddccccccdd00000009a5555a9000000000dddddd000000000000000000000000000000000000000000000000000000000000000000000
5566767666666655000ddccccccdd00000009aaaaaa9000000000dddddd000000000000000000000000000000000000000000000000000000000000000000000
5555767666665555000dddddddddd00000009a9aaaa90000000000dddd0000000000000000000000000000000000000000000000000000000000000000000000
0055767666665500000ddccccccdd00000009a9aaaa900000000000dd00000000000000000000000000000000000000000000000000000000000000000000000
0055557666555500000ddccccccdd00000009a9aaaa90000dddd000dd00000000000000000000000000000000000000000000000000000000000000000000000
0055557666555500000dddddddddd00000009aaaaaa90000000d0000ddddd0000000000000000000000000000000000000000000000000000000000000000000
0000557666550000000ddccccccdd00000009a9aaaa90000000d00000000d0000000000000000000000000000000000000000000000000000000000000000000
0000557666550000000ddccccccdd000000009aaaa900000000dd0000000d0000000000000000000000000000000000000000000000000000000000000000000
0000555555550000000dddddddddd00000009aaaaaa900000000d0000000d0000000000000000000000000000000000000000000000000000000000000000000
00000055550000000000dddddddd000000009999999900000000ddddddddd0000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000
0555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd00000000000000000000000000000
0567666650000000000000000000000000000000000000000000000000aaa0aaa0aaa00000000000000000000000000000d00000000000000000000000000000
056766665555555555555555555555555000000000000000000000000000a0a0a0a0a00000000000000000000000000d006d5555555555555555555555555550
05576665588888888888888888888888570000000000000000000000000aa0a0a0a0a00000000000000000000000000dd666d550000000000000000000000050
005766655888888888888888888888885000000000000000000000000000a0a0a0a0a0000000000000000000000000000d666dd0000000000000000000000050
0055665555555555555555555555555550000000000000000000000000aaa0aaa0aaa00000000000000000000000000000d600d5555555555555555555555550
00055550000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000
000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000
00000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000
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
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000
09990111000000000000000000000000000000000000000000000000000000000000000000000000000000000000880000000000000000000000000000000000
09090101000000000000000000000000000000000000000000000000000000000000000000000000000000000008778000000000000000000000000000000000
09090101000000000000000000000000000000000000000000000000000000000000000000000000000000000000550000000000000000000000000000000000
09090101000000000000000000000000000000000000000000000000000000000000000000000000000000000012112100000000000000000000000000000000
09090101000000000000000000000000000000000000000000000000000000000000000000000000000000000212112120000000000000000000000000000000
0909010100000000000000000000000000000000000000000005650065000000d000000000000000000000000212882120000000000000000000000000000000
09090101000000080000000000000005650065000000000000005600660000000000000000000000000000000012882100000000000000000000000000000000
09090101000000880000000000000000560066000000000000000005550000000000000000000000000000000001871000000000000000000000000000000000
09090101000008778000000000000000000555000000000000565000000000000000000000000000000000000001221000000000000000000000000000000000
09090101000000550000000000000056500000000000000000566000500000000000000000000000000000000000220000000000000000000000000000000000
090901010000121121000000000000566000500000000000000575055000000000000000000d0000000000000000000000000000000000000000000000000000
09090101000212112120000000000005750550000000000000056606500000000000000000000000000000000000000000000000000000000000000000000000
09090101000212882120000000000005660650000000000000005505500000000000000000000000000000000000000000000000000000000000000000000000
09090101000012882100000000000000550550000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000
09090101000001871000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000000000000000
09090101000001221000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000877800000000000000
09090101000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055000000000000000
09090101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001211210000000000000
09090101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021211212000000000000
09090101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021288212000000000000
090901010000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000001288210000000000000
09090101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000187100000000000000
09090101000000000000000000000000000000000000000000000000000000000000005650065000000000000000000000000000000000122100000000000000
09090101000000000000000000000000000000000000000000000000000000000070000560066000000000000000000000000000000000022000000000000000
09090101000000000d00000000000000000000000000000000000000000000000000000000555000000000000000000000000000000000000000000000000000
09090101000000000000000000000000000000000000000000000000000000000000056500000000000000000000000000000000000000000000000000000000
09090101000000000000000000000000000000000000000000000000000000000000056600050000000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000005750550000000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000005660650000000000000000000000000000000000000000000000000000
090901c1000000000000000000000d00000000000000000000000d00000000000000000550550000000000000000000000000000000000088000000000000000
090901c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000000000000
090901c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000050005000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000507000000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000006000000000000000880000000000000000000000000000000000
090901c1000000000000000000000000d00000000000000000000000000000000000000000707000000000000000ee0000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee0000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000075050000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000
090901c1000000880000000000000000000000000000000000000000000000000000000000057060000000000000000000000000000000000000000000000000
090901c1000000ee0000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000
090901c1000000ee0000000000000000000000000000000000000000000000000000000000005050000000000000000000000000000000000000000000000000
090901c1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090901c10000000000000000000000000000000000000000000000000000000000d000000000660000000000000000000000000000000000000000d000000000
09a901c10000000000000000000000000000000000000000000000000000000000000000000dddd00000000d0000000000000000000000000000000000000000
09a901c10000000000000000000000000000000000000000000000000000000000000000000dddd0000000000000000000000000000000000000000000000000
09a901c1000000000000000000000000000000000000000d000000000000000000000000080d7cd0800000000000000000000000000000000000000000000000
09a901c100000000000000000000000000000000000000000000000000000000000000000d9dccd9d00000000000000000000000000000000000000000000000
09a901c100000000000000000000000000000000000000000000000000000000000000000d9dccd9d00000000000000000000000000000088000000000000000
09a901c100000000000000000000000000000000000000000000000000000000000000000d99dd99d000000000000000000000000000000ee000000000000000
09a901c100110111000000000000000000000000000000000000000000000000000000000050dd050000000000000000000000000000000ee000000000000000
09a901c101000100000000000000000000000000000000000000000000000000000000000c7c00c7c00000000000000000000000000000000000000000000000
09a901c1010001100000000000000000000000000000000000000000000000000000000000c0000c000000000000000000000000000000000000000000000000
09a901c1010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09a90111011101110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09a90999099909990099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09a90909099909990909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09a90999090909090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09a90909090909090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0999090909090909099000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00010000375503c5503d5503b55037550325502c5502855025550215501d5501a55015550115500c5500855004550015501b50000500015000050000500035000150005500025000050001500015000150000500
