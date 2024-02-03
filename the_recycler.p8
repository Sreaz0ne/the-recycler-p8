pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--the recycler
--by sreaz

--main
function _init()
	music(0)
	state=0
	display_instructions=false
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

-- format score
function format_score(s1,s2)
	local score1txt=""
	local score2txt=tostr(s2)
	if s1>0 then
	 score1txt=tostr(s1)
	 score2txt="000"..score2txt
	 score2txt=sub(score2txt,#score2txt-3,#score2txt)
	end
	return score1txt..score2txt
end
-->8
--state functions

-- ** title **
function updt_title()
	if btnp(❎)
	   and display_instructions==false then
		music(-1,1000)
		init_game()
	end
	if btnp(🅾️) then
		if display_instructions then
			display_instructions=false
		else
			display_instructions=true
		end
	end
end

function draw_title()
	cls()
	--stars
	spr(192,0,64,16,4,true,false)
	spr(192,0,96,16,4,false,true)
	if display_instructions then
		--stars
		spr(128,0,0,16,2)
		spr(192,0,32,16,4,true,false)
		-- instructions rect
		rect(9,9,117,111,6)
		rectfill(10,10,116,110,3)
		--instructions
		print(
			"instructions",
			h_txt_cntr("instructions"),
			16,
			6)
		line(40,22,86,22,6)
		print(
			"⬅️⬆️⬇️➡️ tO MOVE.",
			12,
			30,
			11)
		print(
			"❎/x tO SHOOT.",
			12,
			44,
			11)
		print(
			"🅾️/c tO VACUUM.",
			12,
			58,
			11)
		print(
			"yOU CAN VACUUM ENEMY",
			12,
			68,
			11)
		print(
			"BULLET TO REFILL YOUR AMMO",
			12,
			74,
			11)
		print(
			"OR VACUUM ENEMY SCRAPS",
			12,
			80,
			11)
		print(
			"TO RECYCLE THEM AND",
			12,
			86,
			11)
		print(
			"UPGRADE YOUR SPACE SHIP.",
			12,
			92,
			11)
		-- go back to title screen
		titlestr="🅾️/c back"
		print(
			titlestr,
			h_txt_cntr(titlestr),
			116,
			11
		)
	else
		--title
		spr(128,0,0,16,8)
		--ship
		spr(74,34,59,7,4)
		--plyr bullet
		spr(100,72,48)
		spr(100,88,40)
		--enemy bullet
		spr(116,40,110)
		spr(116,20,80)
		strtstr="❎/x start"
		inststr="🅾️/c instructions"
		print(
			strtstr,
			h_txt_cntr(strtstr),
			v_txt_cntr()+34,
			11
		)
		print(
			inststr,
			h_txt_cntr(inststr),
			v_txt_cntr()+42,
			11
		)
	end
end

-- ** game **
function init_game()
	t=0
	score1=0
	score2=0
	bullets={}
	enemies={}
	init_plyr()
	state=1
	expls={}
	timetogo=0
	init_vacumm_part()
 init_upgd()
	scraps={}
	init_dffclty()
	time_2_spwn=0
	impcts={}
	music_first_play=false
	music_isplaying=false
	
	spwn_enemies(dffclty.e_per_wave)
end

function updt_game()
	if hastochooseupgd==0 then
		
		updt_stars()
		updt_expls()
		updt_impcts()
		updt_enemies()
		updt_scraps()
		updt_plyr()
		updt_vcm()
		updt_bullets()
		updt_dffclty()
		
		if time_2_spwn>=dffclty.e_spwn_time
		   and need_increase_dffclty==false
		   and need_drw_dffclty==false then
			spwn_enemies(dffclty.e_per_wave)
			time_2_spwn=0		
		end
		
		if timetogo<=0 
		and plyr.hp<=0 
		and chck_plyr_bllt()==0 then
			state=2
			music(16)
		end
		
		t+=1
		if (t==32000) t=0
		
		if need_increase_dffclty==false
		   and need_drw_dffclty==false then
		   time_2_spwn+=1
		end
		
		if t==60 
		   and music_first_play==false then
		 music(8,20000)
		 music_first_play=true
		 music_isplaying=true
		end
		
		if music_first_play
		   and music_isplaying==false
		 		and need_drw_dffclty==false
		 		and need_increase_dffclty==false then
		 		music(8,5000)
					music_isplaying=true
		end
		
		if (time_to_drw_dffclty>0) time_to_drw_dffclty-=1
		if (timetogo>0) timetogo-=1
	else--upgrade menu
		if vcmsfx==1 then
			sfx(1,-2)
			vcmsfx=0
		end
		if dsfx==true then
			sfx(7,-2)
			dsfx=false
		end
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
	--impacts
	drw_impcts()
	--vacuum cleaner
	drw_vcm()
	--bullets
	drw_bullets()
	--dffclty
	drw_dffclty()
	--** hud **
	drw_hud()
	--vacummed object infos
	for i in all(vcminfos) do
		print(i.msg,i.x,i.y,i.col)
	end
	--upgrade menu
	drw_upgd()
end

-- ** game over **
function updt_gameover()
	
	if btn(❎)
	and isshting==0 then
		music(-1,1000)
	 init_game()
	elseif btn(❎)==false
	   and isshting==1 then
		isshting=0
	end
end

function draw_gameover()
	cls()
	for s in all(stars) do
		pset(s.x,s.y,s.col)
	end
	gmstr="game over"
	local score=format_score(score1,score2)
	scrstr="score: "..score
	rstrtstr="press ❎/x to restart"
	print(
		gmstr,
		h_txt_cntr(gmstr),
		v_txt_cntr()-14,
		11
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
	for i=1,60 do
		local s={
			x=flr(rnd(128)),
			y=rnd(128),
			col=7,
			speed=rnd(1.5)+0.5
		}
		if (s.speed < 1.2) s.col=13
		if (s.speed < 0.7) s.col=1
		add(stars,s)
	end
end

function updt_stars()
	for s in all(stars) do 
		s.y+=s.speed	
		if s.y >= 128 then
			s.y=-flr(rnd(128))
			s.x=flr(rnd(128))
			s.speed=rnd(1.5)+0.5
			s.col=7
			if (s.speed < 1) s.col=13
			if (s.speed < 0.7) s.col=1
		end
	end
end
-->8
--player

function init_plyr()
	isshting=0
	isvcm=0
	plyr={
		x=60,
		y=90,
		speed=1.4,
		vspeed=0.4,
		nspeed=1.4,
		hp=3,
		hpmax=3,
		box={x1=2,x2=5,y1=1,y2=6},
		sprt=0,
		flamespr=16,
		timetoshoot=12,
		invul=0,
		ammo=30,
		ammomax=30,
		scraps=0,
		smax=1,
		gun={
			{
				b=get_btype(48),
				x=3,
				y=0
			}
		},
		dmg=1,
		recycle=0
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
	
	ix=0
	iy=0
	
	if btn(➡️) 
	and btn(⬅️)==false then
		ix+=1
		plyr.sprt=2
		fsmax=23
		fsmin=20
	end
	if btn(⬅️)
	and btn(➡️)==false then
	 ix-=1
	 plyr.sprt=1
	 fsmax=23
	 fsmin=20
	end
	if btn(⬆️) then
		iy-=1
	end
	if btn(⬇️) then
		iy+=1
	end
	
	if (ix*ix+iy*iy>1) then
  dist=sqrt(ix*ix+iy*iy)
  ix/=dist
  iy/=dist
	end
	
	plyr.x+=ix*plyr.speed
	plyr.y+=iy*plyr.speed
	
	if (plyr.y >= 121) plyr.y=120
	if (plyr.y < 0) plyr.y=0
	if (plyr.x >= 121) plyr.x=120
	if (plyr.x < 0) plyr.x=0
	
	if btn(❎)
	and plyr.timetoshoot==0
	and isvcm==0 
	and plyr.ammo>0 then
		shoot(plyr,0)
		plyr.timetoshoot=12
		isshting=1
	elseif plyr.ammo<=0 
	   and btn(❎)
	   and plyr.timetoshoot==0 then
		sfx(9)
		plyr.timetoshoot=12
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
		sfx(3)
		if plyr.hp <= 0 then
			if vcmsfx==1 then
				sfx(1,-2)
			end
			explod_shp(plyr.x+4,plyr.y+4)
			sfx(2)
			--time to game over
			timetogo=100
			music(-1,2000)
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
function get_e()
	local e={
			x=0,
			y=-flr(rnd(61)+7),
			box={x1=0,x2=7,y1=0,y2=7},
			flamespr=24,
			flsh=0,
			firerate=flr(rnd(151))+100,
			timetosht=flr(rnd(51))+50,
			speed,hp,scre=0,0,0,
			sprt=nil,
			gun={}
	}
	local e_found=false
	while e_found==false do
		local r=flr(rnd(100))
		if r>=0
		and r<20
		and dffclty_lvl >= 3 then
			e_found=true
			e.speed=0.3
			e.hp=3+dffclty.e_hp
			e.sprt=36
			e.scre=300
			add(e.gun,{
				b=get_btype(49),
				x=3,
				y=8
			})
			add(e.gun,{
				b=get_btype(56),
				x=0,
				y=3
			})
			e.gun[2].b.angl=60
			add(e.gun,{
				b=get_btype(56),
				x=1,
				y=5
			})
			e.gun[3].b.angl=30
			add(e.gun,{
				b=get_btype(56),
				x=5,
				y=3
			})
			e.gun[4].b.angl=300
			add(e.gun,{
				b=get_btype(56),
				x=4,
				y=5
			})
			e.gun[5].b.angl=330
		elseif r>=20
		and r<40 then
			e_found=true
			e.speed=0.4
			e.hp=2+dffclty.e_hp
			e.sprt=32
			e.scre=50
			add(e.gun,{
				b=get_btype(49),
				x=3,
				y=8
			})
		elseif r>=40
		and r<65 then
			e_found=true
			e.speed=0.3
			e.hp=3+dffclty.e_hp
			e.sprt=33
			e.scre=100
			add(e.gun,{
				b=get_btype(49),
				x=1,
				y=8
			})
			add(e.gun,{
				b=get_btype(49),
				x=6,
				y=8
			})
	 elseif r>=65
		and r<85
		and dffclty_lvl >= 1 then
			e_found=true
			e.speed=0.2
			e.hp=5+dffclty.e_hp
			e.sprt=34
			e.scre=200
			add(e.gun,{
				b=get_btype(54),
				x=2,
				y=8
			})
		elseif r>=85
		and r<100
		and dffclty_lvl >= 2 then
			e_found=true
			e.speed=0.5
			e.hp=3+dffclty.e_hp
			e.sprt=35
			e.scre=150
			add(e.gun,{
				b=get_btype(55),
				x=2,
				y=0
			})
		end
	end
	return e
end

function spwn_enemies(nb)
	gap=(128-8*nb)/(nb+1)
	for i=1,nb do
		e=get_e()
		e.x=flr(gap*i+8*(i-1))
		add(enemies,e)
	end
end

function updt_enemies()
	for e in all(enemies) do
		e.y+=e.speed
		e.flsh-=1
		if (e.x>0) e.timetosht-=1
		
		if e.timetosht==0
		and e.x>0 then
			shoot(e,nil)
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
	sfx(4)
	if e.hp <= 0 then
		sfx(5)
		explod_shp(e.x+4,e.y+4)
		add_scrap(e.x,e.y,e.speed)
		score2+=e.scre
		if score2>=10000 then
			score2-=10000
			score1+=1
		end
		del(enemies,e)
	end
end

function drw_enemies()
	for e in all(enemies) do
		if e.flsh>0 then
			for i=1,15 do
				pal(i,7)
			end
		end
		spr(e.sprt,e.x,e.y)
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

function get_btype(sprt)
	local b={}
	if sprt==48 then
		b={
		 btype="p",
			sprt=48,
			box={x1=3,x2=4,y1=0,y2=2},
			speed=2.5,
			ammo=1,
			angl=180
		}
	elseif sprt==49 then
		b={
			btype="e",
			sprt=49,
			box={x1=3,x2=4,y1=5,y2=7},
			speed=1.05,
			ammo=4,
			angl=0
		}
	elseif sprt==54 then
		b={
			btype="e",
			sprt=54,
			box={x1=2,x2=5,y1=4,y2=7},
			speed=1.15,
			ammo=8,
			angl=0
		}
	elseif sprt==55 then
		b={
			btype="b",
			sprt=55,
			box={x1=2,x2=5,y1=2,y2=5},
			speed=0.05,
			ammo=15,
			time_2_expld=240,
			angl=0
		}
	elseif sprt==56 then
		b={
			btype="e",
			sprt=56,
			box={x1=2,x2=5,y1=2,y2=5},
			speed=1.05,
			ammo=2
		}
	end
	return b
end

function shoot(s,ssfx)
	for g in all(s.gun) do
		bullet={
			btype=g.b.btype,
			x=s.x+g.x-g.b.box.x1,
			y=s.y+g.y-g.b.box.y1,
			speed=g.b.speed,
			box=g.b.box,
			sprt=g.b.sprt,
			ammo=g.b.ammo,
			angl=g.b.angl
		}
		if (g.b.btype=="b") bullet.time_2_expld=g.b.time_2_expld
		add(bullets, bullet)
		if (g.b.btype=="p") s.ammo-=g.b.ammo
	end 
	
	if (ssfx!=nil) sfx(ssfx)
end

function updt_bullets()
	for b in all(bullets) do
		if coll(b,vcm) 
			  and isvcm==1
			  and (b.btype=="e" 
			      or b.btype=="b") then
			  local sd=1
			  if b.angl>90
			  and b.angl<270 then
			  	sd=2.4
			  else
			  	sd=2
			  end
			b.x += b.speed/sd * sin(b.angl/360)
			b.y += b.speed/sd * cos(b.angl/360)
		else
			b.x += b.speed * sin(b.angl/360)
			b.y += b.speed * cos(b.angl/360)
		end
		if b.y<-7 
		or b.y>135
		or b.x<-7 
		or b.x>135 then
			del(bullets,b)
		end
		
		if coll(b,vcm) 
		  and isvcm==1
		  and (b.btype=="e" 
			     or b.btype=="b") then
			local vacuumed=vacuum(b)
			if vacuumed==1 then
				local ammogiven=0
				local diffammo=plyr.ammomax-plyr.ammo
				if diffammo>b.ammo+plyr.recycle then
					ammogiven=b.ammo+plyr.recycle
				else
					ammogiven=diffammo
				end
				if ammogiven>0 then
					plyr.ammo+=ammogiven
					add(vcminfos,{
						msg="+"..tostr(ammogiven),
						x=1,
						y=56,
						col=3,
						speed=-0.15,
						t=0
					})
				end
				del(bullets,b)
			end
		else
			if b.btype=="p" then
				for e in all(enemies) do
					if coll(b,e) then
						del(bullets,b)
						add_impct(e,b)
						e_take_dmg(e,plyr.dmg)
					end
				end
			elseif b.btype=="e" 
			    or b.btype=="b" then
				if coll(b,plyr) 
				and plyr.hp>0 
				and plyr.invul<=0
				and b.btype=="e" then
					del(bullets,b)
					add_impct(plyr,b)
					plyr_take_dmg(1+dffclty.e_dmg)
				end
				
				if b.btype=="b" then
					b.time_2_expld-=1
					if b.time_2_expld<=0 then
						bomb_expld(b)
						explod_bomb(b.x+3.5,b.y+3.5)
					end
				end
			end
		end
	end
end

function chck_plyr_bllt()
	for b in all(bullets) do
		if (b.btype=="p") return 1
	end
	return 0
end

function bomb_expld(b)
	bb=get_btype(56)
	local angle=0
	for i=1,12 do
		local bullet={
				btype=bb.btype,
				x=b.x,
				y=b.y,
				speed=bb.speed,
				box=bb.box,
				sprt=bb.sprt,
				ammo=bb.ammo,
				angl=angle
			}
			add(bullets, bullet)
			angle+=30
	end
	del(bullets,b)
end

function drw_bullets()
	for b in all(bullets) do
			if b.btype=="b"
				  and sin(b.time_2_expld/30)<0.1 
				  and b.time_2_expld>60 then
				  pal(10,9)
			elseif b.btype=="b"
		 and b.time_2_expld<=60 then
		 	pal(10,8)
			end
			spr(b.sprt,b.x,b.y)
			pal()
	end
end
-->8
--hud
function drw_hud() 
	--score
	local score=format_score(score1,score2)
	print(
		score,
		h_txt_cntr(score),
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
	elseif plyr.ammo/plyr.ammomax<=0.4 then
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
		elseif vcm.energy/vcm.gemax<=0.4 then
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
function explod_shp(ex,ey)
	local expl={
		etype="s",
		prts={}
	}
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
	
	add(expl.prts,prt)
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
		
		add(expl.prts,prt)
	end
	add(expls,expl)
end

function explod_bomb(ex,ey)
	local expl={
		etype="b",
		x=ex,
		y=ey,
		timer=0
	}
	add(expls,expl)
end

function updt_expls()
	for e in all(expls) do
		if e.etype=="s" then
			for p in all(e.prts) do
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
					if (p.sz<=0) del(e.prts,p)
				end
			end
			if (#e.prts==0) del(expls,e)
		end
		if e.etype=="b" then
			e.timer+=1
			if e.timer==16 then
				del(expls,e)
			end
		end
	end
end

function drw_expls()
	for e in all(expls) do
		if e.etype=="s" then
			for p in all(e.prts) do
				circfill(p.x,p.y,p.sz,p.colr)
			end
		end
		if e.etype=="b" then
			circ(e.x,e.y,e.timer/3,8+e.timer%3)
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
	vcminfos={}
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
	vcmsfx=0
end

function updt_vcm()
	if (plyr.hp<=0) isvcm=0
	
	if (isvcm==0) then
		plyr.speed=plyr.nspeed
		if vcmsfx==1 then
		 sfx(1,-2)
		 vcmsfx=0
		end
	end
	
	if isvcm==0 
	and vcm.energy<vcm.gemax then
		vcm.energy+=vcm.chargspeed
		if vcm.energy>=vcm.gemax then
		 vcm.energy=vcm.gemax
		 vcm.needfullcharg=0
		end
	end
	
	if isvcm==1 then
		
		if (vcmsfx==0) then
		 sfx(1)
		 vcmsfx=1
		end
		plyr.speed=plyr.vspeed
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
	
	for i in all(vcminfos) do
		i.y+=i.speed
		i.t+=1
		if (i.t>18) i.col=6
		if (i.t>28) i.col=7
		if(i.t==40) del(vcminfos,i)
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
		sfx(6)
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
				local scrpgiven=1+plyr.recycle
				if scrpgiven+plyr.scraps>plyr.smax then
					scrpgiven=plyr.smax-plyr.scraps
				end
				plyr.scraps+=scrpgiven
				add(vcminfos,{
						msg="+"..tostr(scrpgiven),
						x=120,
						y=8,
						col=5,
						speed=0.15,
						t=0
					})
				if s.typ=="h"
				and plyr.hp<plyr.hpmax then
				 plyr.hp+=1
					add(vcminfos,{
						msg="+1",
						x=1,
						y=8,
						col=8,
						speed=0.15,
						t=0
					})
				end
				if plyr.scraps>=plyr.smax then
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
	local r=flr(rnd(120))
	if r>=0
	and r<=14 then
		u={
			typ="h",
			sprt=64,
		 val=1,
			txt1="sHIELD MAX +1",
			txt2="cURRENT: "..plyr.hpmax
		}
	elseif r>=15
	   and r<=34 then
		u={
			typ="cs",
			sprt=70,
		 val=0.05,
			txt1="cHARGING SPEED +0.05",
			txt2="cURRENT: "..vcm.chargspeed
		}
	elseif r>=35
	   and r<=54 then
		u={
			typ="ec",
			sprt=66,
		 val=5,
			txt1="eNERGY MAX +5",
			txt2="cURRENT: "..vcm.gemax
		}
	elseif r>=55
	   and r<=74 then
		u={
			typ="dmg",
			sprt=72,
		 val=1,
			txt1="dAMAGE +1",
			txt2="cURRENT: "..plyr.dmg
		}
	elseif r>=75
	   and r<=99 then
		u={
			typ="rec",
			sprt=102,
		 val=1,
			txt1="rECYLE +1 SCRAP/AMMO",
			txt2="cURRENT: "..plyr.recycle
		}
	else
		u={
			typ="ac",
			sprt=68,
		 val=10,
			txt1="aMMO MAX +10",
			txt2="cURRENT: "..plyr.ammomax
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
	
	if btn(❎)
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
			rect(7,29,120,69,7)
		end
		rect(10,32,117,66,11)
		rectfill(11,33,116,65,3)
		spr(up1.sprt,16,41,2,2)
		print(up1.txt1,34,44,11)
		print(up1.txt2,34,50,6)
		
		--up2
		if curspos==2 then
			rect(7,74,120,114,7)
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
	
	sfx(8)
	
	if up.typ=="h" then
		plyr.hpmax+=up.val
	elseif up.typ=="cs" then
		vcm.chargspeed+=up.val
	elseif up.typ=="ec" then
		vcm.gemax+=up.val
	elseif up.typ=="ac" then
		plyr.ammomax+=up.val
	elseif up.typ=="dmg" then
		plyr.dmg+=up.val
	elseif up.typ=="rec" then
		plyr.recycle+=up.val
	end
	
	plyr.scraps=0
	plyr.timetoshoot=11
	plyr.smax=plyr.smax+scraptoaddonmax
	local s_to_add=flr(scraptoaddonmax/2)
	if (s_to_add==0) s_to_add=1
	scraptoaddonmax+=s_to_add
	
	hastochooseupgd=0
	up1=nil
	up2=nil
	curspos=nil
end
-->8
--difficulty
function init_dffclty()
	need_increase_dffclty=false
	need_drw_dffclty=false
	t_2_increase_dffclty=0
	dffclty_duration=2000
	min_e_spwn_t=100
	max_e_per_wave=10
	dfflty_msg=nil
	warning_duration=280
	crrent_wrnng_time=0
	dffclty={
		e_spwn_time=600,
		e_per_wave=3,
		e_hp=0,
		e_dmg=0
	}
	dffclty_lvl=0
	dsfx=false
	time_to_drw_dffclty=-1
end

function updt_dffclty()

	if time_to_drw_dffclty==0
	  and need_increase_dffclty==true then
	  need_increase_dffclty=false
	  need_drw_dffclty=true
	  time_to_drw_dffclty=-1
	end

	if t_2_increase_dffclty==dffclty_duration
	   and plyr.hp>0 then
		need_increase_dffclty=true
		t_2_increase_dffclty=0
	end
	
	if need_drw_dffclty==false
	   and need_increase_dffclty==false then
		t_2_increase_dffclty+=1
	end
		
	if need_drw_dffclty then
		crrent_wrnng_time+=1
		if dsfx==false then
			sfx(7)
			dsfx=true
		end
		if crrent_wrnng_time==warning_duration then
			sfx(7,-2)
			dsfx=false
			need_drw_dffclty=false
			crrent_wrnng_time=0
			dfflty_msg=nil
			time_2_spwn=dffclty.e_spwn_time-60
		end
	end
	
	if need_increase_dffclty
	   and time_to_drw_dffclty==-1
	   and #enemies==0
	   and plyr.hp>0  then
	   local be=false
	   for b in all(bullets) do
	   	if b.btype=="b"
	   	   or b.btype=="e" then
	   	   be=true
	   	   break
	   	end
	   end
	   
	   if (be==false) increase_dffclty()
	end
end

function drw_dffclty()
	
	if need_drw_dffclty 
				and sin(crrent_wrnng_time/60)<0.4 then
		spr(96,02,23,2,2)
		spr(98,16,23,2,2)
		spr(96,30,23,2,2,true)
		print(
			"warning",
			h_txt_cntr("warning"),
			29,
			8
		)
		print(
			dfflty_msg,
			h_txt_cntr(dfflty_msg),
			42,
			8
		)
		spr(96,81,23,2,2)
		spr(98,95,23,2,2)
		spr(96,109,23,2,2,true)
	end
end

function increase_dffclty()
	music(-1,1000)
	music_isplaying=false
	local dtype=nil
	while dtype==nil do
		dtype=flr(rnd(4))+1
		if dtype==1
				 and dffclty.e_spwn_time==min_e_spwn_t then
				 dtype=nil
		end
		
		if dtype==2
				 and dffclty.e_per_wave==max_e_per_wave then
				 dtype=nil
		end
	end
	
	if dtype==1 then
		dfflty_msg="ENEMIES COME MORE OFTEN"
		dffclty.e_spwn_time-=100
		if (dffclty.e_spwn_time<min_e_spwn_t) dffclty.e_spwn_time=min_e_spwn_t
	elseif dtype==2 then
		dfflty_msg="MORE ENEMIES COME"
		dffclty.e_per_wave+=1
		if (dffclty.e_per_wave>max_e_per_wave) dffclty.e_per_wave=max_e_per_wave
	elseif dtype==3 then
		dfflty_msg="ENEMIES ARE MORE RESISTANT"
		dffclty.e_hp+=2
	elseif dtype==4 then
		dfflty_msg="ENEMIES ARE STRONGER"
		dffclty.e_dmg+=1
	end
	
	dffclty_lvl+=1
	
	time_to_drw_dffclty=60
end

-->8
--impacts
function add_impct(s,b) 
	local pos_s=abs_box(s)
	local pos_b=abs_box(b)
	
	
	local dcol=3
	if (b.btype=="e") dcol=8
	
	local pmax=flr(rnd(10))+10
	for p=1,pmax do
		local ix,iy=0
		local xdir,ydir=nil
		--impact from top/bot
		if pos_b.x1>=pos_s.x1
		   and pos_b.x2<=pos_s.x2 then
   ix=rnd(b.box.x2+0.00001)+pos_b.x1
   if pos_b.y1<=pos_s.y2
   		 and pos_b.y1>pos_s.y1 then
   	iy=pos_s.y2+0.1
   	ydir=2
   else
   	iy=pos_s.y1-0.1
   	ydir=-1
   end
		else
			--impact from left/right
			if pos_b.y1>=pos_s.y1
			   and pos_b.y2<=pos_s.y2 then
	   iy=rnd(b.box.y2+0.00001)+pos_b.y1
	   if pos_b.x1<=pos_s.x2
	   		 and pos_b.x1>pos_s.x1 then
	   	ix=pos_s.x2+0.1
	   	xdir=1
	   else
	   	ix=pos_s.x1-0.1
	   	xdir=-1
	   end
			else
				--impact from both side
				--top/left
				if pos_b.x2>=pos_s.x1
	   		 and pos_b.y2>=pos_s.y1
	   		 and pos_b.x1<=pos_s.x1
	   		 and pos_b.y1<=pos_s.y1 then
	   	if p%2==0 then
	   		ix=rnd(pos_b.x2-pos_s.x1+0.00001)+pos_s.x1
	   		iy=pos_s.y1
	   		ydir=-1
	   	else
	   		ix=pos_s.x1
	   		iy=rnd(pos_b.y2-pos_s.y1+0.00001)+pos_s.y1
	   		xdir=-1
	   	end
				end
				--top/right
				if pos_b.x1<=pos_s.x2
	   		 and pos_b.y2>=pos_s.y1
	   		 and pos_b.x2>=pos_s.x2
	   		 and pos_b.y1<=pos_s.y1 then
	   	if p%2==0 then
	   		ix=rnd(pos_s.x2-pos_b.x1+0.00001)+pos_b.x1
	   		iy=pos_s.y1
	   		ydir=-1
	   	else
	   		ix=pos_s.x2
	   		iy=rnd(pos_b.y2-pos_s.y1+0.00001)+pos_s.y1
	   		xdir=1
	   	end
				end
				--bot/right
				if pos_b.x1<=pos_s.x2
	   		 and pos_b.y2>=pos_s.y2
	   		 and pos_b.x2>=pos_s.x2
	   		 and pos_b.y1<=pos_s.y2 then
	   	if p%2==0 then
	   		ix=rnd(pos_s.x2-pos_b.x1+0.00001)+pos_b.x1
	   		iy=pos_s.y2
	   		ydir=2
	   	else
	   		ix=pos_s.x2
	   		iy=rnd(pos_s.y2-pos_b.y1+0.00001)+pos_b.y1
	   		xdir=1
	   	end
				end
				--bot/left
				if pos_b.x2>=pos_s.x1
	   		 and pos_b.y1<=pos_s.y2
	   		 and pos_b.x1<=pos_s.x1
	   		 and pos_b.y2>=pos_s.y2 then
	   	if p%2==0 then
	   		ix=rnd(pos_b.x2-pos_s.x1+0.00001)+pos_s.x1
	   		iy=pos_s.y2
	   		ydir=2
	   	else
	   		ix=pos_s.x1
	   		iy=rnd(pos_s.y2-pos_b.y1+0.00001)+pos_b.y1
	   		xdir=-1
	   	end
				end
			end
		end
		if (xdir==nil) then
			xdir=flr(rnd(2))
			if (xdir==0) xdir=-1
		end
		if (ydir==nil) then
			ydir=flr(rnd(2))
			if (ydir==0) ydir=-1
		end
		local impct={
			x=ix,
			y=iy,
			xs=rnd(0.2)+0.2,
			xd=xdir,
			ys=rnd(0.2)+0.2,
			yd=ydir,
			lt=flr(rnd(6))+12,
			colr=dcol
		}
		add(impcts,impct)
	end
end

function updt_impcts() 
	for i in all(impcts) do
		i.x+=i.xs*i.xd
		i.y+=i.ys*i.yd
		i.lt-=1
		if (i.lt<10) i.colr=10
		if (i.lt<7) i.colr=9
		if (i.lt<5) i.colr=4
		if (i.lt<2) i.colr=5
		
		if (i.lt==0) del(impcts,i)
	end
end

function drw_impcts() 
	for i in all(impcts) do
		pset(i.x,i.y,i.colr)
	end
end
__gfx__
00066000000066000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006ddd00000dd600006dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006ddd00000dd600006dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0067bd0000b7dd0000dd7b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03dbbd3000bbd300003dbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63dbbd3d0dbbd3d00d3dbbd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
633dd33d0d3d33d00d33d3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050dd050005dd500005dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777007777770077777700777c7c00c7c0777777007777770077777700c7cc7c00000000000000000000000000000000000000000000000000000000000000000
c7c00c7c77700777c7c00c7c0c0000c00c7cc7c0077777700c7cc7c000c00c000000000000000000000000000000000000000000000000000000000000000000
0c0000c0c7c00c7c0c0000c00000000000c00c000c7cc7c000c00c00000000000000000000000000000000000000000000000000000000000000000000000000
000000000c0000c000000000000000000000000000c00c0000000000000000000000000000008000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008000000088000000800000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008800000877800000880000000800000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000087780000777700008778000008800000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000077770000777700007777000087780000000000000000000000000000000000
0005500000055000e00550020005500000e112000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01e1121000e22200e1e2221200e22200000e20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e12112120e178120e117811200022000001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e1288212e128821200188100000110000e1781200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01288210e122221200188100ee178122e02882020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00178100e11001120012210001288210002882000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001221000e10012000e22200002222000e0220200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000220000e00002000dddd0000022000000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb000000000005555555500dd000005650065d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb0000000000056766665000d00000056006660033d0000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb0000000000056766665d006d555000005550063b66000000000000660000000000000000000000000000000000000000000000000000000000000000000
000000000000000055766655dd666d55565000000333b6d600088000006aa5000008800000000000000000000000000000000000000000000000000000000000
00000000000000000576665000d666dd5660005003bbbbbd008ee800006aa5000008800000000000000000000000000000000000000000000000000000000000
000000000008800005566550000d600d057505500663b6d000e77e00000550000000000000000000000000000000000000000000000000000000000000000000
0000000000088000005555000000d000056606500063b60d008ee800000000000000000000000000000000000000000000000000000000000000000000000000
0000000000088000000550000000dd00005505500000060600088000000000000000000000000000000000000000000000000000000000000000000000000000
555555555555555500000666666000000000000000000000000000600600000000000044d0000000000000000000000000000000000000005060010000000000
55555555555555550000066666600000000000000000000000000060060000000000004440000000000000000000000000000000000000000000850000000000
55667676666666550000dddddddd000000000444444444440000006006000000000004444d000000000000000000000000000000000006000608786000000000
5566767666666655000ddccccccdd000000045555555555400000dddddd00000000004444d000000000000000000000000000000000000060087501000000000
5566667666666655000ddccccccdd0000004d4454454455400000dddcdd00000000004444d000000000000000000000000000000000005000578050000000000
5566766666666655000dddddddddd0000046aa699699535400000ddcddd000000000999999900000000000000000000000000000000007008780000000000000
5566767666666655000ddccccccdd000046aa6aa699d355400000ddccdd000000000977999400000000000000000000000000000000060008570600000000000
5566767666666655000ddccccccdd00046aa6aa6aad3535400000dddcdd0000000009a7999400000000000000000000000000000006000500000000000000000
5555767666665555000dddddddddd0004666666666343554000000dcdd0000000000aa9999400000000000000000000000000000000010000600000000000000
0055767666665500000ddccccccdd000463333333d4333540000000dd00000000000aa9994900000000000000000000000000000000707050000000000000000
0055557666555500000ddccccccdd000463343344d343540dddd000dd00000000000a99999400000000000000000000000000555550000000000000000000000
0055557666555500000dddddddddd000463333333d435400000d0000ddddd00000009a999990000000000000000000000000d555555006500000000000000000
0000557666550000000ddccccccdd00046636333dd354000000d00000000d0000000a9999440000000000000000000000ddd5555555500000000000000000000
0000557666550000000ddccccccdd000463333333dd40000000dd0000000d00000009999994000000000000000000000dd555555ddd500000000000000000000
0000555555550000000dddddddddd0004666dddddd4000000000d0000000d000000004444400000000000000000000ddd555555ddd5500000000000000000000
00000055550000000000dddddddd000044444444440000000000ddddddddd00000009999994000000000005555555d3333555ddddd5d00000000000000000000
00000088000000880000008888000000000000000000000000005555555000000000000000000000005555555555d333bb35ddddd55000000000000000000000
0000008800000088000000888800000000000bb0000000000005333bbbb5000000000000000000000555555555d33bb33b3ddddd655000000000000000000000
000008880000088800000880088000000000b7b0000000000053333bbbbb500000000000000000005555555dd6333bbb33dddddd550000000000000000000000
00000880000008800000080000800000000b7b000000000005333333bbbbb5500000000000000000555555d6633bb3333dddd6d5600000000000000000000000
0000888000008880000088088088000000b7b0000000000000533333bbbbbbb5000000000000000006665d6663bbbbb3dddd6d56500000000000000000000000
000088000000880000008808808800000b7b000000000000000533555bbbbb50000000000000000000665d6666333333dd66d666600000000000000000000000
000888000008880000088808808880000bb000000000000055555555bbbbbb5000000000000000000c77d5d566666666666d6666500000000000000000000000
0008800000088000000880088008800000000000000000005bbbbb5055bbb50000000000000000000cccd6ddddd6666d56d66633530000000000000000000000
0088800000888000008880088008880000000000000000005bbbbb500055535000000000000000000000d656656dd6656dd63333665000000000000000000000
00880000008800000088000880008800000008800000000055bbbb50055333350000000000000000000066d656656dd66d633336666600000000000000000000
0888000008880000088800000000888000008780000000005bbbbb505b5333350000000000000000000006566d65d556d6333666666650000000000000000000
0880000008800000088000088000088000087800000000005bbb5b55bbbb3350000000000000000000000006565665dd63336666666665000000000000000000
0880000008800000088000088000088000878000000000005bb3335bbbbbbb500000000000000000000000000665d66d63366666666666000000000000000000
88000000880000008800000000000088087800000000000005333355bbbbb5000000000000000000000000000000650000655566666660000000000000000000
880000008800000088008888888888880880000000000000005333505b5550000000000000000000000000000000000000c77c50666600000000000000000000
80000000800000008008888888888888000000000000000000055550050000000000000000000000000000000000000000ccc000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006660000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000
00000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000c00000000000000000000000000000
00000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000
00000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000003333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333330000000
0000003bbbbb3bb33bb3333bb33bbbbbbbb33333333bbbbbbb333bbbbbbbb33bbbbbbbb33bb3333bb33bbbbbbbb33bb33333333bbbbbbbb33bbbbbbb33000000
0000003bbbbb3bb33bb3333bb33bbbbbbbb33333333bbbbbbbb33bbbbbbbb33bbbbbbbb33bb3333bb33bbbbbbbb33bb33333333bbbbbbbb33bbbbbbbb3000000
0000003333bb33333bb3333bb33bb33333333333333bb3333bb33bb33333333bb33333333bb3333bb33bb33333333bb33333333bb33333333bb3333bb3000000
0000003333bb33333bb3333bb33bb33333333333333bb3333bb33bb33333333bb33333333bb3333bb33bb33333333bb33333333bb33333333bb3333bb3000000
0000003333bb33333bb3bbbbb33bbbbbb3333333333bb3bbbbb33bb3bbb3333bb33333333bb3bbbbb33bb33333333bb33333333bb3bbb3333bb3bbbbb3000000
0000003333bb33333bb3bbbbb33bbbbbb3333333333bb3bbbbb33bb3bbb3333bb333333333b3bbbbb33bb33333333bb33333333bb3bbb3333bb3bbbbb3000000
0000003333bb33333bb3333bb33bb33333333333333bb33bb3333bb33333333bb33333333333333bb33bb33333333bb33333333bb33333333bb33bb333000000
0000003333bb33333bb3333bb33bb33333333333333bb33bb3333bb33333333bb33333333333333bb33bb33333333bb33333333bb33333333bb33bb333000000
0000003333bb33333bb3333bb33bbbbbbbb33333333bb3333bb33bbbbbbbb33bb3bbbbb33bbbbbbbb33bb3bbbbb33bb3bbbbb33bbbbbbbb33bb3333bb3000000
00000033333b333333b3333bb333bbbbbbb333333333b3333bb333bbbbbbb333b3bbbbb333bbbbbbb333b3bbbbb333b3bbbbb333bbbbbbb333b3333bb3000000
00000003333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333330000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000006000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000
000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000070000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006660000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000
00000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000c00000000000000000000000000000
00000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000
00000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000003333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333330000000
0000003bbbbb3bb33bb3333bb33bbbbbbbb33333333bbbbbbb333bbbbbbbb33bbbbbbbb33bb3333bb33bbbbbbbb33bb33333333bbbbbbbb33bbbbbbb33000000
0000003bbbbb3bb33bb3333bb33bbbbbbbb33333333bbbbbbbb33bbbbbbbb33bbbbbbbb33bb3333bb33bbbbbbbb33bb33333333bbbbbbbb33bbbbbbbb3000000
0000003333bb33333bb3333bb33bb33333333333333bb3333bb33bb33333333bb33333333bb3333bb33bb33333333bb33333333bb33333333bb3333bb3000000
0000003333bb33333bb3333bb33bb33333333333333bb3333bb33bb33333333bb33333333bb3333bb33bb33333333bb33333333bb33333333bb3333bb3000000
0000003333bb33333bb3bbbbb33bbbbbb3333333333bb3bbbbb33bb3bbb3333bb33333333bb3bbbbb33bb33333333bb33333333bb3bbb3333bb3bbbbb3000000
0000003333bb33333bb3bbbbb33bbbbbb3333333333bb3bbbbb33bb3bbb3333bb333333333b3bbbbb33bb33333333bb33333333bb3bbb3333bb3bbbbb3000000
0000003333bb33333bb3333bb33bb33333333333333bb33bb3333bb33333333bb33333333333333bb33bb33333333bb33333333bb33333333bb33bb333000000
0000003333bb33333bb3333bb33bb33333333333333bb33bb3333bb33333333bb33333333333333bb33bb33333333bb33333333bb33333333bb33bb333000000
0000003333bb33333bb3333bb33bbbbbbbb33333333bb3333bb33bbbbbbbb33bb3bbbbb33bbbbbbbb33bb3bbbbb33bb3bbbbb33bbbbbbbb33bb3333bb3000000
00000033333b333333b3333bb333bbbbbbb333333333b3333bb333bbbbbbb333b3bbbbb333bbbbbbb333b3bbbbb333b3bbbbb333bbbbbbb333b3333bb3000000
00000003333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333330000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb000000000000000000000000000000000
00000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000b7b070000000000000000000006000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b7b0000000000000000000000000000000000
000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000b7b00000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b7b000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000001000bb0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000bb0000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000b7b0000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000b7b00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000b7b000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000b7b0000000000000000000000000000000000000000000000000000
0000000000700000000000000000000000000000000000000000000000000000000000000bb00000000000000000000000050000000000000000000000000000
000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000070000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000050600100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000008500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000060006087860000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000600875010000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000050005780500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000070087800000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000600085706000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000060005000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000100006000000000000000000000000000000000000000000000000000000000000
0000000000000000000d000000000000000000000000000000000000000007070500000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000d05555500000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000d5555550065000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000ddd55555555000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000dd555555ddd5000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ddd555555ddd55000000000000000000000000000000000000000000000000000000000000000000
00000000060000000000000000000007000000005555555d3333555ddddd5d000000000000000000000000000000000000000000000000001000000000000000
0000000000000000000000000000000000005555555555d333bb35ddddd550000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000555555555d33bb33b3ddddd6550000000000000000000000000000000000000000500000000000000000000000000
00000000000000000000000000000000005555555dd6333bbb33dddddd5500000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000555555d6633bb3333dddd6d56000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000006665d6663bbbbb3dddd6d565000000000005000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000665d6666333333dd66d6666000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000008800000000c77d5d566666666666d66665000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000087800000000cccd6ddddd6666d56d666335300000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000878000000000000d656656dd6656dd633336650000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000878000000000000066d656656dd66d6333366666000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000008780000000000000006566d65d556d63336666666500000000000000000000000000000000000000000000000000000000000000000
000000000000000000000880000050000000000006565665dd633366666666650000000000000000000000000000000000000000000000000000070000000000
0000000000000700000000000000000000000000000665d66d63366666666666000000000000000000d000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000006500006555666666600000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000c77c506666000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000ccc0000000000000000000000000000000000000000000000000000000000000000000000000
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
000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000070000000000000
00000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000878000000000050000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008780000000000000000000000000000000000000001000000000000000000000000000000000000000000
00000000000000000000000000000000000000000087800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000500000000000000878000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000006000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
000100003916035160311502e1502a150261401f1401e1301510001100021001a10015100111000c1000810004100011001b10000100011000010000100031000110005100021000010001100011000110000100
000a0020036400d640086400e6400a640096400664009640036400b6400f640076400b640026400f6400664007640066400d640126400b6400e640096400764006640096400b6400c64007640066401064006640
00080000396723665235652336522e6422b6422a6322963226632246222362219622176120f602096020260200602006020060200602006020060200602006020060200602006020060200602006020060200602
00050000336602c6502964025630216201d6201661000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200001366211662126620060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602006020060200602
000f0000306622b662246521c642156220c6120760204602000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
010200002905227052240022200220002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
00070110070010c05112051180511d05124051280512a0512a0512805125051200511b05118051130510e0010d001080010a0010d00110001130011b00121001290012a0012a0012a001250011c0011800106001
000500001a3201e330223402a35033300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000307572c747287372d7070c707007070070700707007071970700707007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707007070070700707
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c0530300003000030000c0530300003000030000c0530300003000030000c0530300003000030000c0530300003000030000c0530300003000030000c0530300003000030000c053030000000000000
011000000305003020030200305003020030200305003020030200305003020030200305003020030500302003050030200302003050030200302003050030200302003050030200302003050030200305003020
011000000305003020031250305003020031250305003020031250305003020031250305003120030500312503050030200312503050030200312503050030200312503050030200312503050031200305003125
011000000c0330300003000030000c0330300003000030000c0330300003000030000c0330300003000030000c0330300003000030000c0330300003000030000c0330300003000030000c033030000300003000
011000000303003010031150303003010031150303003010031150303003010031150303003110030300311503030030100311503030030100311503030030100311503030030100311503030031100303003115
0110000009700097000c0000300003000030000c0000300003000030000c0000300003000030000c000030000c0330000000000030000c0330000000000030000c0330000000000030000c033000000000003000
011000000003000010000150003000010000150003000010000150003000010000150003000010000300001500030000100001500030000100001500030000100001500030000100001500030000100003000015
011000000303003010030150303003010030150303003010030150303003010030150303003010030300301503030030100301503030030100301503030030100301503030030100301503030030100303003015
011000000003000010001150003000010001150003000010001150003000010001150003000110000300011500030000100011500030000100011500030000100011500030000100011500030001100003000115
011000000005000020000250005000020000250005000020000250005000020000250005000020000500002500050000200002500050000200002500050000200002500050000200002500050000200005000025
000f0000155501255011550125500f55012550105500e550105500f5500c5500e5500c55008550065500555004550035500155000500005000050000500005000050000500005000050000500005000050000500
010f0000150451204511025120450f04512025100450e045100250f0450c0450e0250c04508025060450502504045030250104500005000050000500005000050000500005000050000500005000050000500005
__music__
00 15555644
00 14155644
01 14165744
02 171d5744
01 57585744
00 57585944
00 575c4344
00 5b594344
01 17185744
00 17581a44
00 17185944
00 571c4344
00 1b594344
02 1a194344
00 41424344
00 41424344
01 1e1f5744
00 57585a44
00 57585944
00 575c4344
00 5b594344
02 5a594344

