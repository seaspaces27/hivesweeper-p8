pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
 set_plrs(1)
 poke(0x5f2d, 1) --mouse mode
 debug=false--true
 unopened=0 total_bees=0
 level=1
 titlecards={}
 plrs={0,0,0,0,0,0,0,0,0}
 ents={}
 cols={7,10,11,12,13,14,15,8,
	6, 9,4,5,3,2,1,0}
	cols_shade={6,4,3,5,5,4,4,5,
	4, 3,5,1,1,1,0,5}
 init_menu()
end

function init_menu()
	menu={}menu.mode="menu"
	menu.screen=0 menu.offset=0 
	--menu.tiles={"play","options"}
	--menu.history={}
 menu.active=true
 menu.reset=function(s)
  s.mode="menu"
		s.screen=0 s.offset=0 level=1
	 s.active=true s:init()
 end
 menu.init=function(s)
  for i,v in pairs(players)do
   v.alive=true
  end
  if s.screen==0 then
   s.tiles={"play","options"}--,"tutorial"}
   for p in all(players)do
    p.no_inp=false
    debuff(p)
   end
   --players[1].no_inp=false
  end
  if s.screen==1 then
   s.tiles={"classic","regular","vs"}
   if(#players>0)players[1].id=3
  end
  --set_new_hive(function()new_hive(1,#menu.tiles+8,nil,
  --32,32)end,0)
  if level==1 then
	  if s.mode=="options"then
	   new_hive(4,8)
	   for i=1,16 do
	    mines[i]=false
			  hives_screen_pos[i].col=i
			  --numbers[i]=1
			  for p in all(players)do
			   if p.c==i then
			    revealed[i]=true
			    break
			   end
			  end
			  
			 end
			 end_bits(1)
			 s.tiles=""
	  else
	   new_hive(1,#menu.tiles+8,nil,
	   32,32)
	   for i=1,#menu.tiles do
			  hives_screen_pos[i].act=i
			 end
	  end
	 else
	  new_lvl_menu()
	  sfx(0)
	 end
  --gamerunning=false
  --end_bits()
 end
-- menu.tut=function(s)
--  new_hive(3,3,0)honeyjar.ui_pos=false
--  hidden[1]=true
--  hidden[7]=true
--  if #players>0 then
--	  players[1].no_inp=true
--	  players[1].togo=1
--	  players[1].id=1
--  end
--  s.tut_frame=0
--  numbers[5]=1
--  new_titlecard("get honey",90,-1)
-- end
-- menu.updtut=function(s)
--  honeyjar.x=lerp(honeyjar.x,60,.1)
--  honeyjar.y=lerp(honeyjar.y,48+48,.1)
--  if(#titlecards==0)s.tut_frame+=1
--  if s.tut_frame==60 then
--   //players[1].hin=1
--   players[1].id=2
--   sfx(5)
--  elseif s.tut_frame==80 then
--   //players[1].hin=1
--   players[1].id=5
--   sfx(7)
--  elseif s.tut_frame==90 then
--   players[1].a=true
--  elseif s.tut_frame==100 then
--   players[1].a=false
--   music(2)
--  elseif s.tut_frame==110 then
--   players[1].id=8
--  elseif s.tut_frame==200 and #titlecards==0 then
--   new_titlecard("avoid bees",90,-1)
--  elseif s.tut_frame==230 then
--   players[1].id=7
--   debug=true
--  elseif s.tut_frame==260 then
--   mines[2]=true
--   sfx(11)
--  elseif s.tut_frame==290 then
--   relocate_bee(2,3)
--   sfx(11)
--  elseif s.tut_frame==320 then
--   relocate_bee(3,6)
--   sfx(11)
--  end
--  --players[1].hin=1
-- end
 menu:init()
 menu.call=function(s,id)
  for i,v in pairs(players)do
   v.alive=true
  end
  if not id or (id and id>s.offset and id<=#s.tiles+s.offset)then
	  s.mode=(id and s.tiles[id+s.offset])or s.mode
	  if(s.mode=="menu")then
	   menu:init()
	  elseif(s.mode=="options")then
	  	menu.screen=2
	  	menu:init()
	  elseif(s.mode=="play")then
	  	menu.screen=1
	  	menu:init()
	  elseif(s.mode=="classic")then
	  	menu.active=false
	   new_lvl_classic()
	  elseif(s.mode=="regular")then
	  	menu.active=false
	   new_lvl_regular()
	  elseif(s.mode=="vs")then
	  	menu.active=false
	   new_lvl_vs()
	  --elseif(s.mode=="tutorial")then
	   --s:tut()
	  end
	  if not gamerunning then
	   --s.offset=#beehive
	  end
	 end
 end
 menu.next=function(s)
  --go to the next level
  level+=1
  s:call()
 end
 menu.upd=function(s)
--  if s.mode=="tutorial"then
--   s:updtut()
--  end
  --mouse join (player 9)
  if stat(34)~=0then --any mouse clicj
   if(plrs[9]==0)join_plr(8)
  end
  for p=0,8 do --join
   for b=0,6 do
    if btnp(b,p) then
     --[[
     if s.mode=="tutorial"then
      s.mode="menu"
      menu.screen=0 music(-1)
      set_new_hive(function()menu:init()end,1)
	  	  --menu:init()
      break
     end 
     ]]--
     --print(b, b*5 + 10, p*7, p+1)
     if plrs[p+1]==0then
      join_plr(p)
     end
    end
   end
  end
 end
 menu.drw=function(s)
  if level==1 and s.mode~="tutorial"then
	  for i=1,#s.tiles do
	   local ox=9
	   local cell=hives_screen_pos[i]
	   print(s.tiles[i],
	   cell[1]+ox,cell[2],7)
	  end
  end
  //pal(1,0)
  palt(1,1)
  sspr(8,32,8*12,8*2,16,8)
  pal()
 end
end

function join_plr(p)
 local id=p+1
 if(plrs[id]~=0)return
 plrs[id]=1
 
 local np=add_plr(id)
 np.id,np.togo=3+p
 np.stun=20
 
 local finding=true
 while finding do
  finding=false
	 for v in all(players) do
	  if v.c==np.c then
	   finding=true
	   np.c+=1
	  end 
	 end
 end
 
 if(id==9)np.mouse=true
 add(players,np)
 sfx(27,2,0,
 #players*2)
end

function setchr(s,i,c)
 return sub(s,1,i-1)..c..sub(s,i+1)
end
num_cols={12,11,8,12,14,13,5}
--cols={8,9,10,11,12,13,14,15,6,7}
--cols_shade={4,2,9,3,5,5,4,4,13,6}
function part(id,x,y,t)
 pa={}pa.tag=nil pa.id=id or 0
 pa.x=x or 64 pa.y=y or 64
 pa.t=t or -1 pa.flicker=nil
 pa.recol={}
 pa.upd=function(s)
  s.t-=1
  if s.t<=0 then
   del(parts,s)
  end
 end
 pa.drw=function(s)
  if s.flicker then
   if s.t%s.flicker<(min(s.flicker,4))then
    return
   end
  end
  if s.recol then
   for i=1,#s.recol do
    pal(s.recol[i][1],s.recol[i][2])
   end
  end
  spr(s.id,s.x,s.y)
  pal()
 end
 add(parts,pa)
 return pa
end
function sp_part(id,x,y,dx,dy,ang_change,t)
 pa=part(id,x,y)pa.t=t or pa.t
 pa.ang_change=ang_change
 pa.dx=dx or rnd(4)-8 pa.dy=dy or rnd(1)
 pa.gx=.94 pa.gy=.1 
 pa.ang=0
 pa.upd=function(s)
  s.t-=1
  s.x+=s.dx s.y+=s.dy
  s.dx*=s.gx s.dy+=s.gy
  if(s.ang_change)s.ang+=s.dx/2
  if s.y>128 or s.t==0 then
   del(parts,s)
  end
 end
 pa.drw=function(s)
  if s.flicker then
   if s.t%s.flicker*2<(min(s.flicker,4))then
    return
   end
  end
  if s.recol then
   for i=1,#s.recol do
    pal(s.recol[i][1],s.recol[i][2])
   end
  end
  if flr(s.ang)%2==0 then
   spr(s.id,s.x,s.y)
  elseif flr(s.ang)%2==1 then
   spr(s.id,s.x,s.y,1,1,true,true)
  end
  pal()
 end
 return pa
end
function set_flag(id,plr)
 fl={} fl.from=plr
 fl.c=plr.c
 local cell=hives_screen_pos[id]
 fl.x=cell[1]
 fl.y=cell[2] --cell.temp_press=true
 fl.dx=0 fl.dy=0 fl.id=id
 sfx(9)
 if flagfield[fl.id]then
  flagfield[fl.id]+=1
 else
  flagfield[fl.id]=1
 end
 fl.upd=function(s)
	 if(not s.dying)then
	  local cell=hives_screen_pos[id]
  	s.x=lerp(s.x,cell[1],.4)
  	s.y=lerp(s.y,cell[2],.4)
  end
 end
 fl.drw=function(s)
  if not s.dying then
  if(s.from)then
   pal(6,cols[s.c])
   pal(13,cols_shade[s.c])
   if(cols[s.c]==2)pal(2,0)
  end
  local oy=is_pressed(s.id)
  spr(7,s.x,s.y+oy)pal() end
 end
 fl.remove=function(s)
  local corpse=sp_part(7,s.x,s.y,
  rrnd(1.5),-1.5,true)
  if(s.from)then
   add(corpse.recol,{6,cols[s.c]})
   add(corpse.recol,{13,cols_shade[s.c]})
   if(cols[s.c]==2)add(corpse.recol,{2,0})
  end
  
  sfx(10)
 	s.dx=rrnd(4)
 	s.dy=-3-rnd(1) 
  if(flagfield[s.id])then
   flagfield[s.id]=(flagfield[s.id]>1 and flagfield[s.id]-1) or nil
  else
   --flagfield[s.id]=nil
  end
  s.id=nil
  del(flags,s)
 end
 add(flags,fl)
 return fl
end
function rrnd(n)return(-n+rnd(n*2))end
function set_plrs(ppl)
 players={}
 for i=1,ppl do
  local plr=add_plr(i)
  --players[i]=plr
 end
end
function new_cell(i)i=i or #hives_screen_pos+1
	--beehive=beehive.."#"
	mines[i]=false
	revealed[i]=false
	hex_pos(i-1,x_os,y_os)
	return hives_screen_pos[i]
end
function hex_pos(i)
 local offset=0local y=flr(i/hive_wi)
 if(y%2==1)offset=.5
	local x=((i+offset)%hive_wi)
	
	local pos={x_os+(x*8),y_os+(y*7)}
	if menu.active then
		while pos[2]>120 do
			pos[2]-=120-32
			pos[1]+=16
		end
	end
	
	add(hives_screen_pos,pos)
end
function new_hive(wi,hi,bees,x,y)
 honeyjar:init()
 mines={} sz=wi hi=hi or wi
	--hive_size=sz --beehive=""
	hive_wi=wi or 8
	hive_hi=hi or wi
	hexs=wi*hi
	
	hidden={} -- hidden cells
	revealed={} --cells shown
	reveal_que={} --cells to be shown
	shockwaves={} 
	--generate hive position on screen
	hives_screen_pos={}
	x_os=x or 64-(hive_wi*4)-3
	y_os=y or 64-(hive_hi*4)+6
	for i=1,wi*hi do --map
	 new_cell(i)
	end
	mines[hexs]=false
	all_bees=0
	bees=bees or flr(hexs*.2)
	bees_left=min(bees,hexs-1) or sz*2 --add bees to map
	unopened=0 total_bees=bees_left
	while bees_left>0 do
	 local id=ceil(rnd(hexs))
	 if not mines[id] then
	  --beehive=setchr(beehive,id,"b")
	  mines[id]=true
	  bees_left-=1 all_bees+=1
	 end
	end
	
	for i=1,sz do
	 revealed[i]=false --unopened+=1
	end
	parts={} --particles
	for i=#ents,1,-1 do --kill other entities
	 if(ents[i].class~="plr")ents[i]:die()
	end
	if(flags)then --remove flags
		for i=#flags,1,-1 do
		 flags[i]:remove()
		end
	else
		flags={} --cells flagged
	end
	flagfield={}
	numbers={} --no. of adjacents
	numbers=load_bees()
	
 for i,v in pairs(players) do
  v.id=flr((hexs/4)+(hexs/3)*(i/#players))
  v.togo=v.id
  v.clicks=0
 end
 --first click should be free
 --if(not menu.active)sfx(4)
 if menu.mode~="vs"then
 	first_call=true
 else
  --set_powerup(first_call,false,"plr")
  --set_powerup(no_inp,0,"plr")
  for e in all(players)do
   e.no_inp=true
  end
 end
 gamerunning=true
 timer_reset()
end

function _update60()
 for i=#ents,1,-1 do
  local e=ents[i]
  if(e.class=="plr")e:get_input()
  if #titlecards==0 and not transition.active then
  	if e.stun~=nil then
  	 e.stun-=1
  	 if(e.stun==0)e.stun=nil
  	else
  	 if e.dizzy then
  	  e.dizzy-=1
  	  if(e.dizzy==0)e.dizzy=nil
  	 end
  	 e:upd()
  	end
  else
   e:move()
  end
 end
 
 --validate plr movements
 validate_moves(ents) 
 --if(move_sfx and #players<=2)print(default_tile..rnd(footsteps))

 --update flags
 for i=#flags,1,-1 do
  flags[i]:upd()
 end
 --update particles
 for i=#parts,1,-1 do
  parts[i]:upd()
 end
 --update honeyblobs
 for i=#hblobs,1,-1 do
  hblobs[i]:upd()
 end
 --update screen transitions
 if transition.active then
  transition:upd()
 end
 --menu
 if(menu.active)menu:upd()
 
 --update cells in reveal que
 if #reveal_que>=0 then
	 for i,check in pairs(reveal_que)do--#reveal_que,1,-1 do
	  if(check)then
	   check:upd()
	   if check.t==0 or check.done then
	    check:set()
	   end
	  end
	 end
 end
 --update shockwaves
 upd_waves()
 
 --draw titlecard
 if #titlecards>0 then
  titlecards[1]:upd()
 end
end

function _draw()cls()
 os=64-sz*4
 --draw cells
 for i=1,#hives_screen_pos do
  local cell=hives_screen_pos[i]
  local id=1
  if(revealed[i]==true)id=2
  if(hidden[i]==true)id=3
  if mines[i] then
   id=debug and 5
   or revealed[i] and 6 or id
  end
  if cell.act then
   if(cell.act=="back")id=49
   if(cell.act=="again")id=50
   if(cell.act=="next")id=51
   pal(1,5)
   pal(9,6)pal(2,13)pal(15,6)
  end
  local oy=0
  if cell.pressing then oy=1 end
  if cell.temp_press then oy=1 end
  local sh=shockwaves[i]
  if sh then
   if(sh[1]>=0)oy+=rrnd(2)
  end
  if cell.col then
   pal(9,cols[cell.col])
   pal(2,cols_shade[cell.col])
  end
  spr(id,cell[1],cell[2]+oy)pal()
  --if(sh)print(sh[3],cell[1]+2,cell[2]+1,7)
  if debug or revealed[i]then
   local txt=(not mines[i] and numbers[i]) or ""
	  print(txt,cell[1]+2,cell[2]+1+oy,
	  num_cols[numbers[i]])
  end
  //print(beehive[i],cell[1],cell[2],7)
 end

 --menu
 if(menu.active)menu:drw()

 for i=1,#reveal_que do
  reveal_que[i]:drw()
 end
 for i=1,#flags do
  local fl=flags[i]
  fl:drw()
 end
 for i=#parts,1,-1 do
  local pa=parts[i]
  pa:drw()
 end
 for i=#hblobs,1,-1 do
  hblobs[i]:drw_outline()
 end for i=#hblobs,1,-1 do
  hblobs[i]:drw()
 end
 --draw entities
 for i=1,#ents do
  ents[i]:drw()
 end
 --draw ui
 ui_draw()
 --draw mouse
 pal(1,0)
 for i=1,#players do
  local plr=players[i]
  plr:drw()
 end
 pal()
 --draw titlecard
 if #titlecards>0 then
  titlecards[1]:drw()
 end
 --clear temp_presses
 for v in all(hives_screen_pos)do
  v.temp_press=nil
 end
end

function mark_hex(id,t,plr)
 local mark={id=id,t=t or 0,
 full_t=t or 0, done=false,
 lose_all=true}--[[
 local mark={}
 mark.id=id
 mark.t=mark.full_t or t or 0
 mark.full_t=mark.full_t or t
 mark.done=false
 mark.lose_all=true ]]--
 hives_screen_pos[id].pressing=true
 mark.set=function(s)
  --if cell isnt already revealed
  if not revealed[s.id] then
   --if cell has no bees near
   if ((numbers[s.id] or 0)==0 and (flagfield[s.id]==nil)) and (not mines[s.id])then
    local m_adj=neighbours(s.id)
	   for i=1,#m_adj do
	    local n_id=m_adj[i]
	    --not_unique=hives_screen_pos[id].act
	    if revealed[n_id]==false and (flagfield[n_id]==nil or flagfield[n_id]==0)then
	     --put new mark for cell 
	     --on que, inherit stats
	     local new_mark=mark_hex(n_id,s.full_t)
	     for j,val in pairs(s) do
	      new_mark[j]=val
	     end
	     --reset delay as by now its 0
	     new_mark.id=n_id
	     new_mark.t=s.full_t
	    end
	   end
   end
   revealed[s.id]=true
	  s.done=true sfx(2,0,0,4)
	  if not mines[s.id] and 
	  s.id<hexs then
	   honeyblob(s.id,plr)
	  end
	  local lost=mines[s.id]
	  if gamerunning then
	   if lost and (plr and plr.bubble)then
	    lost=false
	    plr:die()
	   end
	   winlose(lost,plr)
	  end
	  if(lost)add_bee(s.id)
  end
	 hives_screen_pos[s.id].pressing=nil
	 del(reveal_que,s)
 end
 mark.upd=function(s)
  --hives_screen_pos[s.id].pressing=nil
  if s.t>1 then
   s.t-=1
  else
   s.set(s)
  end
 end
 mark.drw=function(s)
  if false then
   color(7)
   local cell=hives_screen_pos[s.id]
   circ(cell[1]+4,cell[2]+4,(1-(s.t/s.full_t))*8,9)
   --circfill(cell[1]+4,cell[2]+4,(1-(s.t/s.full_t))*8)
  end
 end
 add(reveal_que,mark)
 return mark
end

--highlight
function hilight(cell)
 spr(3,cell[1],cell[2])
end

function swap_bee(id,t_id)
 mines[id]=false
 mines[t_id]=true
end

function relocate_bee(id,t_id)
	if mines[id]then
	 mines[id]=false
	 --target id exists
	 if t_id then 
	  mines[t_id]=true return
	 end 
	 
	 for i=1,#mines do --swap with earliest non-mine cell
	  if(i~=id and (mines[i]==nil or mines[i]==false))then
	   --move bee
	   mines[i]=true
	   --beehive=setchr(beehive,id,"#")
	   --beehive=setchr(beehive,i,"b")
	   --update number list
	   local adj=neighbours(id)
	   for j=1,#adj do
	    if numbers[adj[j]]then
		    numbers[adj[j]]-=1
		    if(numbers[adj[j]]==0)numbers[adj[j]]=nil
	    end
	   end
	   local adj=neighbours(i)
	   for j=1,#adj do
	    new_num=numbers[adj[j]]
	    numbers[adj[j]]=
	    new_num and new_num+1 or 1
	   end
	   break
	  end
	 end
	end
end

function load_bees()
 numbers={}
 --for every bee/mine
	for i=1,#mines do
	 if mines[i]==true then
		 local adj=neighbours(i)
		 --explore all bees neighbourhoods
		 for j=1,#adj do
		  local n_id=adj[j]
		  if numbers[n_id] then--if exists
		   numbers[n_id]+=1
		  else --first bee/mine near it
		   numbers[n_id]=1
		  end
		 end
	 end
	end
	return numbers
end

function cprint(txt,x,y,c)
 local ox=(print(txt)-x)
 print(txt,x+ox,y,c)
end
-->8
function timer_reset()
 t_start=nil t_end=nil
 game_length=nil
end
function timer_start()
 t_start=time()
 game_length=0
end
function timer_end()
 t_end=time()
 game_length=t_end-(t_start or t_end)
end

function shake_cells(amt,frames)
 for i,v in pairs(hives_screen_pos)do
  v[1]+=rrnd(amt)
  v[2]+=rrnd(amt)
 end
end

function winlose(gameover,plr)
 local all_dead=true
 for p in all(players)do
  if(p.alive)all_dead=false break
  --[[idea, dead players'
   honey should go back to
   the board, and repopulate
   the hive, relocating the
   bees within that area?
  ]]--
 end
 if gameover then--unopened<(total_bees or 0) then
  --lost
  if(plr)plr:die()
 	sfx(3)
  shake_cells(1,2)
  
  if true then--menu.mode~="vs"or all_dead then
	  gamerunning=false
	  local offset=0
	  for j=1,#mines do
	  --mark all mines
	   if mines[j]==true and revealed[j]==false then
	    offset+=1
	    local mark=mark_hex(j,offset)
	    --avoid recursion
	    mark.lose_all=false
	   end
  	end
  end
 else
  --detect win
  local complete=true
  for i,v in pairs(revealed)do
   if v==false and not mines[i]then
    complete=false break
   end
  end
  if complete then
	  --win
	  gamerunning=false
	  if not menu.active then music(1)
	  else sfx(20)end
  end
 end
 
 if not gamerunning then
 	--menu.active=true
 	end_bits(gameover)
 	timer_end()
 end
end
function end_bits(gameover)
	new_cell().act=gameover and "back"or"next"
	if(gameover)new_cell().act="again"
end

function neighbours(id,range,outer)
 local dirs={"tl","tr","l","r","bl","br"}
 local adj={}
 range=range or 1
 for i=1,#dirs do
  local n_id=transpose(id,dirs[i])
  if range>1 then
   for j=1,range-1 do
    if n_id then
    n_id=transpose(n_id,dirs[i])
    end
   end
  end
  if(n_id)add(adj,n_id)
 end
 return adj
end

function is_pressed(id)
 if(not hives_screen_pos[id])return 0
 return(hives_screen_pos[id].pressing or hives_screen_pos[id].temp_press)and 1 or 0
end

dirs={"tl","tr","r","br","bl","l"}
function transpose(id,os)
 if(id==nil)return
 local mod_x=id%hive_wi
	--odd row or not
	local y_=ceil(id/hive_wi)
	local odd=(y_%2==0) and 1 or 0
	--corner fixing
	if(mod_x==0 and y_%2==0)odd=1
	if(mod_x==0 and y_%2==1)odd=0
	--dir to id number conversion
	local n_id=
	os=="tl"and -hive_wi-1+odd or
	//os=="u"and -hive_size-1+odd or
	os=="tr"and -hive_wi+odd or
	os=="l"and -1 or
	os=="r"and 1 or
	os=="bl"and hive_wi-1+odd or
	os=="br"and hive_wi+odd or 0
 --get new position
 n_id+=id
 if (n_id>0 and 
 n_id<=#hives_screen_pos) then
  ty=((os=="tl"or os=="tr")and -1
  or((os=="bl"or os=="br")and 1
  or 0))+y_
  if ceil((n_id)/hive_wi)==ty
  and n_id<=#hives_screen_pos then
   return n_id
  end
 end
 return nil --id
end

function open_cell(i,plr)
	if first_call then --first click is safe
  first_call=false sfx(12,2)
  relocate_bee(i)
  for i=1,#players do
   players[i].first_call=false
  end
  timer_start()
 else
  sfx(13,nil,0,8)
 end
 if hives_screen_pos[i].col then
  plr.c=i
 end
 local dur=5
 if plr and plr.broom then
  dur=0
 end
 local check=mark_hex(i,dur,plr)
 check.t=0
end

function chord_cell(i,perform,plr)
 local adj=neighbours(i)
 local nonflags={}
 local flags_near=0
 for j=1,#adj do --get flags
  if(flagfield[adj[j]]or 0)>0then
  	flags_near+=1
  elseif revealed[adj[j]]==false then
  	add(nonflags,adj[j])
  end
 end
 if flags_near==numbers[i]then
	 for j=1,#nonflags do
		 if perform then
		 	open_cell(nonflags[j],plr)
	  else --sfx(3)
	 		hives_screen_pos[nonflags[j]].temp_press=true
	 	end
 	end
	end
end

function flag_cell(i,plr)
 --is a flag already there?
 local occupied=false
 for j=1,#flags do
  local fl=flags[j]
  if fl then
	  if fl.id==i then
	   occupied=true
	   --delete own flag
	   if fl.from==plr or menu.mode=="vs"then
	    fl:remove()
	   end
	  end
  end
 end
 if not occupied then--free cell
  set_flag(i,plr)
 end
end

function release_cell(i,plr)
 if hives_screen_pos[i] then
  hives_screen_pos[i].pressing=nil
 end
 selecting=nil
end

function perform_act(id)
 local cell=get_cell(id)
 if cell.act=="back"then
  menu:reset()--menu.call(menu,i)
 elseif cell.act=="again"then
  --menu:init()--menu.call(menu,i)
  menu.call(menu)
 elseif cell.act=="next"then
  menu.next(menu)
 elseif tonum(cell.act)then
  menu.call(menu,tonum(cell.act))
 end
end

function set_sw(id)
 
 for e in all(ents)do
  if e.id==id and e.pot==nil then
   e.stun=stun
  end
	end
end

function upd_waves()
	for i,v in pairs(shockwaves)do
		if v then
		 v[1]-=1--tick down
		 if v[1]==0 then
		  --propagate
		  if v[2]~=0 then--iterating
			  for j,id in pairs(neighbours(i))do
			   shockwave(id,v[4],v[2]-1,v[3],v[5])
			  end
		  end
		  --and stun
		  for e in all(ents)do
			  if e.id==i and e.pot==nil then
			   e.stun=v[5]
			  end
				end
				sfx(13,3,8,8)
		 end
		 if v[1]<=-60 or v[1]==nil then --delete
		  --del(shockwaves,v)
		  shockwaves[i]=nil
		  --v={}
		 end
		end
	end
end
function shockwave(id,t,loops,ic,stun_time)
 local p=shockwaves[id]
 local w={t,loops or -1,
 ic or rnd(),t,stun_time or t*32}
 if p then
  if w[3]==p[3] then
   return p
  end
 end
 shockwaves[id]=w
 return w
end

function new_titlecard(title,t,sf)
 cs={}cs.t=t or 90cs.title=title or "h"
 cs.init=false
 
 cs.upd=function(s)
  if not s.init then
   if(#titlecards==0)sfx(-1)
   if(sf==nil)then sfx(15,3,0,16)
   else sfx(sf)end
   s.init=true
  end
  
  s.t-=1
  if s.t<=0 then
   if(s.sf~=nil)sfx(4)
   del(titlecards,s)
  end
 end
 cs.drw=function(s)
  color(7)
 	ox=print("\#0"..s.title,0,-8)
 	print("\#0"..s.title,64-ox/2,64)
 end
 add(titlecards,cs)
 return cs
end

function get_cell(id)
 return hives_screen_pos[id] or {}
end

honeyjar={x=109,y=0,ui_pos=true}
honeyjar.init=function(s)
 honeyjar.open=true
 honeyjar.pips=0
 honeyjar.pressed=10
 honeyjar.ui_pos=true
end honeyjar:init()
honeyjar.leak=function(s)
 if s.pips>0 then
  for i=1,s.pips do
   local hb=honeyblob(nil)
   hb.phase=2 hb.alive=false
   hb.dy=i*.3 s.pips-=1 hb.dx=0
  end
 end
end
honeyjar.drw=function(s)
 local id=s.open and 25 or 26
 local oy=s.pressed==0 and 0 or 1
 
 local p=flr((s.pips/(#hives_screen_pos-total_bees))*4)--+(s.pressed>0 and 2 or 0)
 if(s.pips>0)rectfill(s.x+2,s.y+oy+5-p,s.x+5,s.y+oy+5,9)
 if(p>=4)s.open=false id=25
 spr(id,s.x,s.y+oy)
 s.pressed=max(s.pressed-1,0)
 --if(s.pressed>0)spr(27,s.x,s.y+oy-p-2)
 if not gamerunning then
  print("\#0"..s.pips,s.x+2,s.y+oy+9)
 end
end

hblobs={}
function honeyblob(id,plr)
 local c=hives_screen_pos[id]or {honeyjar.x+4,honeyjar.y}
 local hb={x=c[1],y=c[2],
	 phase=0,t=0,offset=0,id=id,
	 alive=gamerunning,
	 dy=-rnd(1),dx=rrnd(2),
	 target=menu.mode=="vs"
	 and plr
	 or honeyjar
 }
 hb.init=function(s)
 
 end
 hb.upd=function(s)
  local target=s.target
  s.t+=1
  if s.t==3 and s.phase==0 then
   if(mines[s.id]==true)del(hblobs,s)
   s.phase=1
   s.offset=s.x-16
   if(s.x>=64)s.offset=s.x+16
  end
  if s.phase==1then
   s.x=lerp(s.x,s.offset,.1)
   if(s.t>8)s.phase=2s.offset=y s.t=0
   s.y=lerp(s.y,s.y-3,.1)
  elseif s.phase==2then
   if s.alive then --go to jar
	   s.x=lerp(s.x,target.x,.12)
	   s.y=
	   lerp(s.y,target.y,--.05
	   (mid(.4,.24,abs(target.y-s.y)/64)*.4)
	   )
   else--fall away
    s.x+=s.dx
    s.y+=s.dy
    s.dy+=.07 --gravity
    s.dx*=.9
    if(s.y>130)del(hblobs,s)
   end
   --if(s.x==honeyjar.x)s.phase=3
  end
  if abs(s.y-target.y)<4
  and abs(s.x-target.x)<4 then
   target.pips+=1
   target.pressed=2
   del(hblobs,s)
  end
 end
 hb.drw=function(s)
  local target=s.target
	 if s.phase==0 then
	 	spr(40,s.x,s.y)
	 elseif s.phase<=2then
	  if s.phase==2 and not s.alive then
	   pal(9,13)pal(10,6)
	   if(s.t==0)sfx(11)target.pressed=2
	  end
	  spr(34,s.x,s.y)
	  pal()
	 end
 end
 hb.drw_outline=function(s)
	 if s.phase~=0 and s.phase<=2then
	  if s.phase==2 and not s.alive then
	   pal(2,1)pal(4,5)
	  end
	  spr(35,s.x,s.y)
	  pal()
	 end
 end
 add(hblobs,hb)
 return hblobs
end

transition={}
transition.init=function(s)
 transition.active=false
 transition.t=0
	transition.call=nil
	transition.screenpos={}
	transition.phase=0
end
transition:init()
function set_new_hive(hive_func,typ)
 transition.call=hive_func
 transition.active=true
 transition.screenpos=hives_screen_pos
end
transition.upd=function(s)
 if s.phase==0 then
	 local spd=.1+s.t*.2
	 for i,v in pairs(hives_screen_pos) do
	  local dx=abs(v[1])-64
	  local dy=abs(v[2])-64
	  local dist=sqrt(dx+dy)
	  local a=atan2(dx,dy)
	  a+=.13
	  v[1]+=cos(a)*spd
	  v[2]+=sin(a)*spd
	 end
	 if s.t==40 then --load new hive
	  //honeyjar:leak()
	  s.phase=1 
	  if(s.call)s.call()
	  --copy values
	  for i,v in pairs(hives_screen_pos)do
	   s.screenpos[i]={v[1],v[2]}
	   v[1]=64 v[2]=64
	  end
	  s.t=0
	 end
 else
  for i,v in pairs(hives_screen_pos)do
	  local target=s.screenpos[i]
	  
	  local dx=abs(target[1]-64)
	  local dy=abs(target[2]-64)
	  local dist=sqrt(dx+dy)
	  local a=atan2(dx,dy)
	  
	  local amt=.1+((dist/64)+a)*.1
	  v[1]=lerp(v[1],target[1]
	  ,amt)
	  v[2]=lerp(v[2],target[2]
	  ,amt)
	 end
	 if s.t>=40 then
	  --finalise positions
	  for i,v in pairs(hives_screen_pos)do
	   local target=s.screenpos[i]
	   v[1]=target[1]
	   v[2]=target[2]
	  end
	  --deactivate
	  s.active=false
	  s:init()
	 end
 end
 s.t+=1
end
-->8
--ui + misc

function lerp(a,b,z)
 return a+(b-a)*z
end

--mouse_icon="\^:0103070305000000"
--flag_icon="\^:0707070404000000"
--clock_icon="\^:0e151d110e000000"
--function header()end
function ui_draw()color(7)
 --str=#flags
 --str=all_bees
 local tx=1 ty=1
	sspr(4,8,3,5,tx,ty)tx+=4
	local ox=print(all_bees-#flags,tx,ty)
	ox+=2
	local length=72
	for i,p in pairs(players) do
	 //local ox=0+(i/#players)*72
	 --local ox=8+i*12
	 if(i==5)ox=0 ty+=8
	 local ol=0
	 pal(6,cols[p.c])
	 pal(13,cols_shade[p.c])
	 spr(17,ox,ty)
	 pal()
	 scr=menu.mode=="vs"and p.pips
	 or p.clicks
	 ol=print(scr,ox+6,ty)
	 ox=ol
	end
	--print(flag_icon..all_bees-#flags)
 //if  then ct=(start and flr(time())-start) or "0:00"
 //else ct=game_length or"0:00"end
 ct=(t_end and game_length)or
 (game_length==0 and flr(time()-t_start))
 or "0"
 str=ct
 l=print(str,0,-128)
 print(str,128-l,ty)
 local to=
 not t_end and t_start and((flr(1+time()-t_start)%4)*4)or 0
 sspr(0,16+to,5,5,128-l-6,ty)
 if honeyjar.ui_pos then
  honeyjar.x=128-l-15
  honeyjar.y=0
 end
 honeyjar:drw()
end
-->8
--player code

function set_powerup(pup,v,e)
 if type(e)=="string" then
  --is class
  for en in all(ents)do
   if en.class==e or en.name==e then
    set_powerup(pup,v,en)
   end
  end
 elseif type(e)=="table"then
  --is entity
  get_powerup(e,pup,v)
 end
end

function add_plr(i)
	local plr=add_obj(1) plr.class="plr"
	plr.x,y=64,64 plr.alive=true
	plr.pl=i-1
	plr.c=i
	plr.first_call=true
	plr.cooldown=0
	plr.mouse=false
	plr.side=ceil(rnd(1))==1 and true
	plr.hin=0plr.vin=0
	plr.prev_hin=plr.hin
	plr.last_hin=plr.hin
	plr.a=btn(🅾️,plr.pl)plr.b=0plr.ap=0plr.bp=0
	plr.no_inp=false
	plr.pressing=nil
	plr.togo=plr.id
	plr.prev_a,plr.prev_b=0,0
	plr.noflag=-1
	plr.clicks=0 plr.scr=0 plr.pips=0
	plr.wt=0
	plr.get_input=function(s)
	 if s.no_inp then
	 return end
	 s.hin=tonum(btn(➡️,s.pl))-tonum(btn(⬅️,s.pl))
	 s.hinp=tonum(btnp(➡️,s.pl))-tonum(btnp(⬅️,s.pl))
	 s.vin=tonum(btn(⬇️,s.pl))-tonum(btn(⬆️,s.pl))
	 s.vinp=tonum(btnp(⬇️,s.pl))-tonum(btnp(⬆️,s.pl))
	 
	 if(s.dizzy)s.hin*=-1 s.vin*=-1s.hinp*=-1 s.vinp*=-1
	 
	 s.prev_hin,s.prev_vin=s.hin,s.vin
	 plr.prev_a,plr.prev_b=s.a,s.b
 
	 s.ap=btnp(🅾️,s.pl)and not s.prev_a s.bp=btnp(❎,s.pl)
	 s.a=btn(🅾️,s.pl)s.b=btn(❎,s.pl)
	 
	 if s.mouse then
	  s.a=stat(34)==1or stat(34)==4
	  s.ap=s.a and not s.prev_a
	  s.b=stat(34)==2
	  s.bp=s.b and not s.prev_b
	  if(s.a)s.pressing=s.id
	  local atcell=false
	  local mx,my=stat(32),stat(33)
	  for i,v in pairs(hives_screen_pos)do
		  if(mx>=v[1] and mx<v[1]+8
		  and my>=v[2] and my<v[2]+8)then
  	  if s.a and s.pressing~=i then
  	   get_cell(s.pressing).pressing=nil
  	   get_cell(i).pressing=true
  	   s.pressing=i
  	  end
  	  s.id=i
  	  s.togo=i atcell=true break
  	 end
  	end
  	if not atcell then
 	  s.id=nil s.togo=nil
 	  get_cell(s.pressing).pressing=nil
 	 end
	 end
	end
	plr.upd=function(s)
	 --get controls
		--s:get_input()

	 if(s.ap)sfx(14,1)
	 
	 local a_released=s.prev_a and not s.a
	 if a_released then
	  if s.pressing~=nil then
	   if(s.id)hives_screen_pos[s.id].pressing=false
	   s.pressing=nil
	  end
	 end
	 
	 if s.hin==0 and s.vin==0 then
	 	s.wt=s.wt>0 and s.wt-1 or 0
	 elseif s.wt<8then
	  s.wt+=1
	 end
	 if s.cooldown==0 and not s.mouse then --move speed
	  --local cl=8
	 	local adj=neighbours(s.id)

	 	local dir=(
	 	s.vin==1 and(--down
	 	 (s.hin==1and "br")or
	 	 (s.hin==-1and "bl")or
	 	 (s.hin==0and "d"))or
	 	s.vin==-1 and(--up
		 	(s.hin==1and "tr")or
			 (s.hin==-1and "tl")or
			 (s.hin==0and "u"))or
	 	s.vin==0 and
	 	 (s.hin==1and "r")or
	 	 (s.hin==-1and "l")
	 	)or ""
	 	
	 	if s.vin==0 then
		 	if(s.hin==1)s.side=true
		 	if(s.hin==-1)s.side=false
	 	end
	 	
	 	if s.wt>3 then--wait to confirm any diagonals
	 		move_ent(s,dir)
	 	end
	 	
		else
		 if(s.cooldown>=1)s.cooldown-=1
		end
		--set cell to pressed
		if s.ap and s.id then
		 hives_screen_pos[s.id].pressing=true
		 s.pressing=s.id
		end
		if s.id~=s.togo then --moved
		 local cl=10
		 if s.noflag then
		  if noflag==0 or s.noflag==-1 then
		   cl=8
		  end
		 end
		 --s.pressing=nil
		 if s.pressing and hives_screen_pos[s.togo]then
	   hives_screen_pos[s.id].pressing=nil
	   s.pressing=s.togo
	   hives_screen_pos[s.togo].pressing=true
		 end
		 s.cooldown=(s.togo~=s.id)and cl or s.cooldown
		end
		
		--interactions
		if s.alive then
			if(a_released) and revealed[s.id]==false and flagfield[s.id]==nil then
			 open_cell(s.id,s) s.clicks+=1
			 
			 if s.broom then
				 s.broom-=1
			  --print("\ai6c1")
			  sfx(6,3,5,1)
			  if(s.broom==0)then
			   s.broom=nil
			   sp_part(28,s.x,s.y,
			   .3,-1,false,60)
			  end
		  end
		  
			 if s.noflag then
				 if s.noflag>0then
				  s.noflag-=1
				  if s.noflag==0 then
				   --noflag activated
				   sfx(6,3,8,8)
				  end
				 end
			 end
		 elseif (s.a or a_released)and revealed[s.id]==true then--activate neighbours if flags-bee is met
			 chord_cell(s.id,a_released,s)
			 
			 if a_released then
			  if s.broom then
					 s.broom-=1
				  print("\ai6c1")
				  if(s.broom==0)then
				   s.broom=nil
				   sp_part(28,s.x,s.y,
				   .3,-1,false,60)
				  end
			  end
			  if s.pot then
			   //print("\ai1c3e2e1")
			   s.pot-=1
			   shockwave(s.id,4)--,set_t,loops,ic,stun_time)
			   if(s.pot==0)then
				   s.pot=nil
				   sp_part(28,s.x,s.y,
				   .3,-1,false,60)
				  end
			  end
		  end
		  
			elseif s.bp and revealed[s.id]==false then
			 flag_cell(s.id,s)
			 if s.noflag then
			  if(s.noflag==0)sfx(6,3,16,8)
			  s.noflag=8
			 end
			end
			
			if a_released then
			 if s.pressing then
			  get_cell(s.pressing).pressing=nil
			  s.pressing=nil
			 end
		  --s.pressing=nil
		  --hives_screen_pos[s.id].pressing=nil 
		 end
	 end
	 if a_released then--special buttons should still work when dead
	  perform_act(s.id)
	 end
		--update last non-zero horizontal input
	 s.last_hin=s.hin~=0and s.hin or s.last_hin
		s.prev_a=s.a
		s:move()
	end
	plr.move=function(s)
	 s.id=min(s.id,#hives_screen_pos)
		if not s.mouse then
			local cell=hives_screen_pos[s.id]
			s.x+=((cell[1]+3)-s.x)*.35 //.4
			s.y+=((cell[2]+3)-s.y)*.35 //.7
		else
		 s.x=stat(32) s.y=stat(33)
		end
	end
	plr.drw=function(s)
	 pal(6,cols[s.c])
	 pal(13,cols_shade[s.c])
	 local id=17
	 --if(s.pressing~=nil)id=18
	 if(s.a)id=18
	 id=s.winner and id+4 or
	 (s.alive and id or id+2)
	 if s.mouse==true then
	  --ghost at actual mouse postiion
	  spr(id+(s.alive and 2 or 0),stat(32),stat(33))
	 end
	 spr(id,s.x,s.y)
	 color(cols[s.c])
	 if s.first_call==true or first_call then
	  spr(33,s.x,s.y)
	 end
	 drw_powerups(s)
	 //print("\#2"..s.id.." "..s.cooldown)
	 //print("\#2"..s.hin.." "..s.vin)
	end----[[
	plr.die=function(s)
	 if s.bubble then
   s.bubble=nil
   sfx(6,-1,3,2)
   return
  end
  s.alive=false
  winlose()
	end--]]--
	return plr
end
-->8
--objects

function check_ents(s,class)
	for e in all(ents)do
  if e~=s and e.id==s.id 
  and(e.class==class or class==nil)then
   --is occupying an entity
   return e
  end
	end
end

function check_powerups(s)
 local e=check_ents(s,"powerup")
 if e then
  get_powerup(s,e.name)
	 e:got(s)
	end
end

function check_enemies(s)
 local e=check_ents(s,"enemy")
 if e then
  if s.name=="bee" and e.name=="bee"then
   s.togo=s.prev_id
   --e.togo=nil
   return
  end
 	e:die()
 end
end

function check_players(s)
 local e=check_ents(s,"plr")
 if e then e:die()end
end


function get_powerup(e,name,v)
 if name=="bubble"then
  e.bubble=v or -1--60*10
 elseif name=="broom"then
  e.broom=v or 6
 elseif name=="pot"then
  e.pot=v or 6
 elseif name=="no_inp"then
  e.no_inp=v
 end
end
function debuff(e)
 e.bubble,e.broom,e.pot
 =nil
end

function drw_powerups(e)
 if(e.bubble)spr(27,e.x-2,e.y)
 if e.broom then
  spr(28,e.x,e.y+2,1,1,
  e.broom%2==0 and true or false)
  if e.broom<-4 then
   e.broom+=2
  end
 end
 if e.pot then
  local oy=0
  if e.class=="plr"then
   oy=3
  end
  spr(29,e.x,e.y+oy)
 end
 if e.stun or e.dizzy then
 	local id=e.stun and 30 or 31
 	local tick=e.stun or e.dizzy
  pal(1,0)
  local _flip=tick%30<15
  spr(id,e.x+sin(tick/40)*3,
  e.y+sin(tick/30)*2,1,1,
  _flip,_flip)
  pal()
 end
 if(e.no_inp)spr(47,e.x,e.y)
end

function add_obj(id)
 local e={id=id,togo=id,t=0,pips=0}
 if hives_screen_pos then
  e.x,e.y=
  hives_screen_pos[e.id][1],hives_screen_pos[e.id][2]
 end
 e.move=function(s)
  if(s.id>=#hives_screen_pos)s:die()return
  if s.id then
	  local cell=hives_screen_pos[s.id]
	  s.x,s.y=
	  lerp(s.x,cell[1],.35),lerp(s.y,cell[2],.35)
		end
 end
 e.die=function(s)
  if s.bubble then
   s.bubble=nil
   end_powerup("bubble")
   return
  end
  if s.name then
   local corpse=sp_part(e.sp,s.x,s.y,
   rrnd(1.5),-1.5,false)
   --corpse.recol={{11,8}}
   corpse.flicker=5
   corpse.t=30
   
   if s.class=="powerup"then
    corpse.id=0
    corpse.t=5
    corpse.gx,corpse.gy=0,0
    corpse.dx,corpse.dy=0,0
    if(s.name=="bubble")corpse.id=40
   end
  end
  if s.class~="plr"then
   del(ents,e)
		else
		 winlose(true)
		end
 end
 add(ents,e)
 return e
end

function end_powerup(pup)
 if(pup=="bubble")sfx(6,-1,3,2)
 --pup
end

function add_powerup(id,name,sp)
 local e=add_obj(id)
 e.class="powerup"
 e.name,e.sp=name,sp
 e.got=function(s)
  sfx(5,3)
  s:die()
 end
 e.upd=function(s)
  e.t+=1
 end
 e.drw=function(s)
  spr(s.sp,s.x,s.y+sin(s.t/90))
 end
 return e
end

function add_bubble(id)
 return
 add_powerup(id,"bubble",27)
end

function add_broom(id)
 return 
 add_powerup(id,"broom",28)
end

function add_pot(id)
 return
 add_powerup(id,"pot",29)
end

function add_star(id)
 local e=add_obj(id)
 e.t=e.y
 e.upd=function(s)
  s.t-=1
  if s.t==0then
   first_call=true
   open_cell(s.id,nil)
   set_powerup(no_inp,false,"plr")
   s:die()
   timer_start()
   for e in all(players)do
	   e.no_inp=false
	   e.pips=0
	  end
  end
 end
 e.drw=function(s)
  spr(33,s.x+sin(s.t/30)*6,s.y-s.t)
 end
end

function add_hopper(id)
 local e=add_obj(id)
 e.class,e.name="enemy","hopper"
 e.side=ceil(rnd(1))==1
 e.hopped_from=e.id
 e.move=function(s)
		local cell=hives_screen_pos[s.hopped_from]
		
		if(s.togo==s.id)then --staning
		 s.x=lerp(s.x,cell[1],.35) //.4
		 s.y=lerp(s.y,cell[2],.35) //.4
	 else --hopped
	  local togo=hives_screen_pos[s.togo]
	  local ti=s.t/30
	  s.y=(sin(ti/2)*16)
	  +lerp(cell[2],togo[2],ti)
	  s.x=lerp(cell[1],togo[1],ti)
	  if ti>=1 then --landed
	   s.t=0 sfx(6,0,1,1)
	   s.id=s.togo s.hopped_from=s.id
	   check_powerups(s)
	   if check_enemies(e)
	   or check_players(e)then
	    s.t=revealed[s.id]and 236 or 86 
	   end
	   if(s.pot)shockwave(s.id,8,2,nil,60)
	  end
	 end
	end
 e.upd=function(s)
  e:move()
  s.t+=1
  if s.id==s.togo then
   if s.t<4 or s.t>86 then
    hives_screen_pos[s.id].temp_press=true
   end
	  if((revealed[s.id] and s.t>=240)or
	  not revealed[s.id] and s.t>=90)then --hop
	   local adj=neighbours(s.id,2)
	   s.togo=mid(1,rnd(adj),#hives_screen_pos)
	   if s.id~=s.togo then
	    s.t=0 --hop
	    s.side=hives_screen_pos[s.togo][1]>hives_screen_pos[s.id][1] and 1 or 0
	    sfx(6,0,0,3)
	    s.hopped_from=s.id s.id=nil
	   else
	    s.t=0
	   end
	  end
	 end
 end
 e.drw=function(s)
  local oy=is_pressed(s.id)
  pal(1,0)
  spr(s.id~=s.togo and 57 or 56,
  s.x,s.y+oy,1,1,s.side==0 and true)
  pal()
  drw_powerups(s)
 end
 return e
end

function add_beetle(id)
 local e=add_obj(id)e.prev_id=id
 e.dir_offset=rnd({-1,1})
 e.class="enemy"e.name="beetle"
 e.dir_i=flr(rnd(6))
 e.t=10+rnd(60)
 e.ct=10+rnd(10)
 e.sp=58
 e.holding=nil
 e.upd=function(s)
  s:move()
  s.t-=1 --timer
  if s.t<=0then
   s.t=s.ct
   --move forward
   s.togo=transpose(s.id,dirs[1+s.dir_i])
   if not s.holding then
    s.holding=check_ents(s)
   end
	  --if same spot or invalid spot
	  if s.togo==s.id or s.togo==nil then
	   if s.holding then
	    --chomp
	    s.holding:die()
	    s.holding=nil
	   else
		   --turn around
		   s.dir_i=(s.dir_offset+s.dir_i)%6
	   end
	   s.togo=s.id
	  end
	  s.y-=1
		 s.id=s.togo
		 if s.holding then
		  s.holding.stun=8
		  s.holding.togo=s.id
		  s.holding.id=s.id
		 end
	 end
 end
 e.drw=function(s)
  local oy=is_pressed(s.id)
  pal(1,0)pal(5,1)
  spr(s.sp,
  s.x,s.y+oy,1,1,
  ((s.dir_i+2) % 6<3)and true)
  pal()
  drw_powerups(s)
  --print(s.dir_i,s.x,s.y,7)
  --print(s.id.." "..(s.togo or " "))
 end
 return e
end

function add_bee(id)
 local e=add_obj(id)
 e.dir_offset=rnd({-2,2})
 e.class="enemy"e.name="bee"
 e.dir_i=flr(rnd(6))
 e.t=10+rnd(60)
 e.ct=10+flr(rnd(10))
 e.sp=8 e.flutter=false
 e.upd=function(s)
  s:move()
  s.t-=1 --timer
  if(s.t%8==0)s.flutter=not s.flutter
  if s.t<=0then
   s.t=s.ct
--   --move forward
--   s.togo=transpose(s.id,dirs[1+s.dir_i])
--	  --if same spot or invalid spot
--	  if s.togo==s.id or s.togo==nil then
--	   --turn around
--	   s.dir_i=(s.dir_offset+s.dir_i)%6
--	   s.togo=s.id
--	   sfx(2,0,8,16)
--	  end
	  s.y-=1
		 check_powerups(s)
		 check_enemies(s)
		 s.prev_id=s.id
		 s.id=s.togo or s.id
	 end
 end
 e.drw=function(s)
  local oy=sin(s.t/s.ct)*1
  pal(1,0)pal(5,1)
  spr(s.sp+tonum(s.flutter),
  s.x,s.y+oy,1,1,
  ((s.dir_i+2) % 6<3)and true)
  pal()
  drw_powerups(s)
  --print(s.dir_i,s.x,s.y,7)
  --print(s.id.." "..(s.togo or " "))
 end
 return e
end
-->8
function validate_moves(ents,skip)
 for i,plr in pairs(players)do
  --if player moved
  plr.togo=plr.togo or plr.id
  if plr.togo~=plr.id then
   --todo:add a bounds check
   if plr.togo<1 and plr.togo>(hexs) then
    --plr.togo=plr.id
   end
   for j,oplr in pairs(players)do
    --if both plrs going to same spot
    local oplr=players[j]
    if i~=j and oplr.togo==plr.togo then
     --cancel both movements
     oplr.togo=oplr.id
     plr.togo=plr.id
    end
   end
  end
 end
 --last pass, apply verified moves
 local move_sfx=false
 for i,plr in pairs(players)do
  if(plr.id~=plr.togo)then
   move_sfx=true
   plr.id=plr.togo
   check_powerups(plr)
  end
 end
 if(move_sfx)sfx(8,0,flr(rnd(4)),1)
end

function move_ent(e,dir)
 if dir=="u"then
  dir=(e.side and "tr"or"tl")
  e.side=not e.side
 elseif dir=="d"then
  dir=(e.side and "br"or"bl")
  e.side=not e.side
 end
 --if its diagonal
 if(#dir==2)then
  if transpose(e.id,dir)==nil then
   e.togo=transpose(e.id,flip_dirs_h(dir))
  end
 end
 
 e.togo=transpose(e.id,dir)
end

function flip_dirs_h(dir)
 return (dir=="tl"and"tr")
 or dir=="tr"and"tl"
 or dir=="bl"and"br"
 or dir=="br"and"bl"
end
-->8
menu_lvls={5,8,13,21,34,55,89,144,233,377}
function new_lvl_menu()
 set_new_hive(function()
  new_hive(1,menu_lvls[level],nil,
	 32,32)
	 new_titlecard("level "..level,40,0)
	end)
end

regular_lvls=--[[
{
function()new_hive(4,4)end,
function()new_hive(5,5)end,
function()new_hive(7,7)end,
function()new_hive(8,8)end,
function()new_hive(9,5)end,
function()new_hive(12,9)end,
function()new_hive(13,10)end,
function()new_hive(14,12)end,
function()new_hive(15,14)end,
}]]--
"4,4, 5,5, 7,7, 8,8, 9,5, 12,9, 13,10, 14,12, 15,14"
function new_lvl_regular()
 local data=split(regular_lvls)
 local hx=data[-1+level*2]
 local hy=data[level*2]
 set_new_hive(
  function()new_hive(hx,hy)end
 ,1)
 --regular_lvls[level],1)
 if(level==1)new_titlecard("regular",90)
	new_titlecard("level "..level,40,0)
end

function new_lvl_classic()
 set_powerup("broom",-1,"plr")
 set_new_hive(
 function()new_hive(10,10)end
 ,1)
 if(level==1)new_titlecard("classic",90)
	new_titlecard(level,40,0)
end

function new_lvl_vs()
 local hx=7+flr(rnd(#players))
 local hy=6+flr(rnd(#players))
 set_new_hive(
 function()new_hive(hx,hy)
 add_star(ceil(rnd(#hives_screen_pos)))
 end
 
 ,1)
 --if(level==1)new_titlecard("vs",90)
	
	--new_titlecard("round "..level,40,0)
	new_titlecard("round "..level,40,0)
end
__gfx__
00000000000900000001000000000000000000000009000000000000000000000077770077770000000000000000000000000000000000000000000000000000
0000000009f9990001101100000000000070700009999900000100000d6d6000007777007766000000aaaa000000000000000000000000000050050000000000
007007009f99999010011010000100007000007099f9f9900011110006d66200006666000011aa000aaaaaa00050050000500500005005000500005000000000
0007700099999992101111100011100000aaa0009ff9ff92011010100d6d62000011aa000a11aa110aaaaaa00000000000000000050000500000000000000000
0007700099999992101111100011100070aaa0709ff9ff9201110110002262000a11aa111a11aa110aaaaaa00050050000055000000550000050050000000000
007007009999999210111110000100000000000099f9f99201101010000666001a11aa110a11aa110aaaaaa00005500000055000005005000005500000000000
00000000099999220111110000000000070007000999992500111100000022200a11aa110011aa0000aaaa000000000000000000000000000000000000000000
00000000000922000001000000000000000700000009250000010000000000000011aa0000000000000000000000000000000000000000000000000000000000
60006d60600000006d000000600000006d00000006606600066066000001000000777700200000028787878700777700000000400000000000a00000c0c00000
6600d6d06d000000666d00006d00000060dd000060160160610d106101112200007777001210012112100121070000700000040100000000a7aaa0000c010000
66606d6066d000006666610060d00000d6666000610d1061d6f666d1112222200066660020007702200077027077000700004010000000000aaa0100c0c00c00
6d006000666d000001611100600d000000600000d6f666d1066f6610112020200011aa002000000220000002707700070442010022222222aa0aa0a0010100c0
606060006666d00000d100006000d00000d000000ddddd1100111110112202200a11aa112000000220000002700000076d441000111111110110110a0000000c
000000006666610000000000d66660000000000006f6661000000000112020201a11aa1120000002200000027000000706d41000022222200000000900000005
00000000016111000000000000600000000000000011111000000000012222000a11aa1110000001100000010700007000611000022222200000000900000005
0000000000d100000000000000d00000000000000000000000000000000200000011aa000122221001222210007777000001000001222210000000a1000000c1
0666000000000000000000000004200060006000066660002009002000000000a00000a0700000a0000000000000000070070070000000000000000000007660
66d66000009aa9000009900000222400660661006d66d600099999000000000009000900000000000000001100000000071707000000000000000000000060d1
66dd600000a77a000099a900022222200666d10066666d009979799000000000000000000000000000015555000000000177700000000000000000000000aa91
6666600000a77a00009999000222224066d660000666d0009779779200000000000000000000000015555510000000007770777000000000000000000000aa91
06660000009aa9000009900000222200601060000066000097797792000000000000000000000000555500000000000000777100000000000000000000000111
66d660000000000000000000000220000100010000dd000099797992000000000a00090000000000555555510000000007001700000000000000000000000000
66d6600000000000000000000000000000000000000000000999992500000000900000a0a0000070105011550000000070777070000000000000000000000000
66d66000000000000000000000000000000000000000000020092500000000000000000000000000101010010000000000070000000000000000000000000000
066600000006000000060000000600000009000000090020000000000004000000000b00000bb0bb000000000000000000000000000000000000000000000000
66d660000666660006666600066666000999990009a99900000100000949490000000b0000000bbb000000110000000000000000000000000000000000000000
6dd66000665666606656656066665660999999909a9999900011110094949490b00001bb3bbb0bb1000155550000000000000000000000000000000000000000
666660006555566d6666666d6655556d99999992999999920110101049494942bb000bbbb3bbb110155555101115551000000000000000000000000000000000
066600006656656d6656656d6566566d999999929999999201110110949494921bbb0bb1b1111b00555500005555555100000000000000000000000000000000
66d660006666666d6665566d6666666d99999992999999920110101049494942b3bbb1103b000b00555555515555555500000000000000000000000000000000
66d66000066666dd066666dd066666dd099999200999992200111100049494201b111bb00b00b100105011551010100000000000000000000000000000000000
666660000006dd000006dd000006dd000009200000092200000100000009200001bb011bb00b1000101010011010100000000000000000000000000000000000
06660000111111000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000
00000000111111099901111111111111111111111111111111111111111111111111111111111100000111111111111111111111000000000000000000000000
00000000111110999901111110011111111111111111111111111111111111111111111111111099940111111111111111111111000000000000000000000000
00000000111110909901111109911111111111111111111111111111111111111111111111110999990111100111111111111111000000000000000000000000
00000000111110299201111099911111111000110001100011111111100111000001110000010990990110099011110011111111000000000000000000000000
00000000111110099011111099411000111490109940099901110001090110999901109999009900990104999900009901111111000000000000000000000000
00000000111110292011111000000990111990099990999990010901090109999901099999009900990049909900499940001111000000000000000000000000
00000000111110990111111111199990111990990990990990900901090099009900990099009904990099009400999999901111000000000000000000000000
00000000111100940990110999094090109900900990999010900900990090009900900099009909990299099010990099901111000000000000000000000000
00000000111109499999004999000090109009904990099900900940940990499409904994009999900999990110990100001111000000000000000000000000
00000000111109990299010099011094094109999901049990902990901999999009999990109999010990001110990111111111000000000000000000000000
00000000111109920099010290111099090109000010000990949994901900000009000000109900110990110010990111111111000000000000000000000000
00000000111099901099010990111099990109000909900990999299901900009009000090109901110999009909940111111111000000000000000000000000
00000000111099200990009940111099401109999909999990999099901999999009999990109901111099999909901111111111000000000000000000000000
00000000111099010999009901111024011110494010499900040049011049940110499401199401111104994019901111111111000000000000000000000000
00000000111000010000100011111000111111000110000011101100111100000110000011199011111110000110011111111111000000000000000000000000
00000000000000000900000009000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009000000090000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009990900099900900099009000900009000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009000909090009090900000009090090000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009090909090909090900090009090090000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009900990099000900900090009909090000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000200000000000
07670770000700000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001210012100666007770
067600700007600007070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020007702066d6607070
076700700007760007070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000002066dd607070
07000070000777600707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000206666607070
07000777000777760777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000200666007770
00000000000777771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000100000000000
00000000000017111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000122221000000000000
00000000000006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000009999000000000000000000000000000000000000000000000000000000000000999400000000000000000000000000000000000000
00000000000000000000009099000000099000000000000000000000000000000000000000000000000009999900000000000000000000000000000000000000
00000000000000000000002992000000999000000000000000000000000000000000000000000000000009909900000990000000000000000000000000000000
00000000000000000000000990000000994000000004900099400999000000000900009999000099990099009900049999000099000000000000000000000000
00000000000000000000002920000000000009900009900999909999900009000900099999000999990099009900499099004999400000000000000000000000
00000000000000000000009900000000000999900009909909909909909009000900990099009900990099049900990094009999999000000000000000000000
00000000000000000000009409900009990940900099009009909990009009009900900099009000990099099902990990009900999000000000000000000000
00000000000000000000094999990049990000900090099049900999009009409409904994099049940099999009999900009900000000000000000000000000
00000000000000000000099902990000990000940940099999000499909029909009999990099999900099990009900000009900000000000000000000000000
00000000000000000000099200990002900000990900090000000009909499949009000000090000000099000009900000009900000000000000000000000000
00000000000000000000999000990009900000999900090009099009909992999009000090090000900099000009990099099400000000000000000000000000
00000000000000000000992009900099400000994000099999099999909990999009999990099999900099000000999999099000000000000000000000000000
00000000000000000000990009990099000000240000004940004999000400490000499400004994000994000000049940099000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000990000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000600000777070007770707000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000066666000707070007070707000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000666666600777070007770777000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000006666666d0700070007070007000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000006666666d0700077707070777000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000006666666d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000066666dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000006dd060000007707770777077700770770007700000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000006666600070707070070007007070707070000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000066666660070707770070007007070707077700000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000006666666d070707000070007007070707000700000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000006666666d077007000070077707700707077000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000006666666d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000066666dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000090006dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000009f999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000009f9999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999799920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999769aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000099977a77a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000009977a77a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000779aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000777770900000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000096099992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000009999922000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000900092200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000009f999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000009f9999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000099999220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000922090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000009f99900000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000009f999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000009999922000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000900092200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000009f999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000009f9999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000099999220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000922090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000009f99900000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000009f999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000009999922000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000900092200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000009f999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000009f9999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000099999220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000922090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000009f99900000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000009f999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000099999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000009999922000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000092200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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

__sfx__
011900001e14500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000101501b000140001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000c0450b115136340b620000000000000000000001b1101a1101b1101a1201b1201a1201b1301a1301b1201a1201b1201a1101b1101a1101b1101a1100000000000000000000000000000000000000000
050100000d110251102b110131201c12015120161200b11016110141101311012120121201213012140121301213015140161401a1401b1401a140191401a1401a1401c1401c1401a14017120151201413012140
01020000200102201023020230202303006040060501d050130300d03000000000000000000000000000c0300e040170501a05018050140500e0300d02000000220502205012050120500a0500a0500a05000000
01020000230451e050230501e052230521e0422804521050280502105228052210520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060000117141c712237152d1553b05118615007000070013645180241f03426144007000070000700007000c6441a024131340c144007000070000700007000070000700007000070000700007000000000000
0103000027045220501f050180522905224042220451d0502b05026052240521d052000000000000000000002e0502905027050220502c0502705025050200502a05025050200501805000000000000000000000
0107000010045150450e04513045000000e00000000000001e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001613019620116101e12006610201100261004620046200d60000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200000a1200362017130076200a6200a1100562011110026100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000241501f140191401013009120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9103000027140221401d1401714027120221201d1201712027110221101d110171100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
91020000136501b1100c6200365016120000000000000000181250e63005120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9003000013610141200c6200362019020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001e050160551b0501e0551d05014055190501d0551c05012054170551b0521c0521b052170521305512055000001205517050000001c0411c0511b0551705512050000000000000000000000000000000
010e00001e1311e14016140161201b1301b1421e1551b1001d1511d130181521813019130191421d155120001c1501c1450010000100001000010000100001001c1501c135001001c1551c1551c1150010000100
010e00000f150001001e1211e12016120161201b1201b12211150121001d1211d1201812018120191201912214150001001c1101c1150d1500010000100121001b1561b165121001216512166061520610012100
010e00001605000000000000000000000000000000000000140500000000000000000000000000000000000017050000000000000000000000000000000000001605516045000001605516050000000000000000
010e00000070000700007000070000700007000070000700007000070000700007000070000700007000070012770007000070000700007000070000700007001b7541b7501c7501b75019750197520070000700
0110000012150001001215517152171321b1041c1511b132171551215012145121201211500100171301f1311f135171101f1111f115001000010000100001000010000100001000010000100001000010000100
011000000b1300b1020d1250c1400c142171120d1440d1321c1111015010142000000b1500b142000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000f150000000f15014150141520b1001615016145000001415014145000000f1500f140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001063500000106351065500000000001062510645106351065500000000001065500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001355416555165541b5551855012555115520f5551355416555165541b555185500050000500005001355416555165541b5551855012555115520f55518555005000e555005000f555005000050000500
011e00001355416555165541b5551855012555115520f5551355416555165541b555185500050000500005001e554165551b5541e5551d55018555195521d5551c55500500165550050017555005000050000500
010c0000120501205012050150501205012050120501505000000000000c010100101805718057180501c0501805018050180501c0500000000000000001a0500000000000000000000000000000000000000000
01060000171201f13519130211451a140231551c140251551d150261551f150281652116029175231402b155171551c155151551a15513155181551d155000000000000000000000000000000000000000000000
010900001405000000140251405019050000000b05019025000000b025140501405019051190521e050190251d0501e025190501d025120501405212051120501605000000160251605019050000001505019025
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001362500000000001f62500000136250062500000006250000000000000001362500000000001f62500000136250062500000000000000000000000001362500000000001f62500000136250062500000
011000000b050000001b0501e055000002005506050000001b0501e055000002005523051000000000020050080001e0001e056080001b055000000000006055040500000020050230550b000250452505604000
01100000230501f055000001e0551705000000000000000000000120500d05500000000001205500005000000b050000001b0501e055000002005506050000001b0501e055000002005523051080000000020050
0110000021050200501e056080001b055000000000006055040500000020050230550b000250452505604000270502305500005250501505500000000000e05500000000000f0550000000000160550000000000
011000002505025055230502505500000000002305500000000001405500000000002505025055230502505512050000002305500000000001405500000000002305000000000002205000000000002005521050
010f0000200501e055000001e0550605000000000000c05000000000000b050000001b0501e055000002005523051060002505423055000001e0542805028052270550000023050000001e050000000000023050
010f00000000000000000000000000000000000000000000000000000000000000000000003050000000000004050000000000005050000000000008050000000d0500d0550805014000190361c036220351b050
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000018d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 10111213
04 14151617
01 205f4344
00 215f4344
00 22424344
00 23424344
00 24254344

