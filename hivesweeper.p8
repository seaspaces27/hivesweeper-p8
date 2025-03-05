pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
 set_plrs(1)
 poke(0x5f2d, 1) --mouse mode
 debug=false--true
 unopened=0 total_bees=0
 titlecards={}
 plrs={1,0,0,0,0,0,0,0}
 init_menu()
end

function init_menu()
	menu={}menu.mode="menu"
	menu.screen=0 menu.offset=0 
	--menu.tiles={"play","options"}
	menu.history={}
 menu.active=true
 menu.reset=function(s)
  s.mode="menu"
		s.screen=0 s.offset=0
	 s.active=true s:init()
 end
 menu.init=function(s)
  if s.screen==0 then
   s.tiles={"play","options","tutorial"}
   for p in all(players)do
    p.no_inp=false
   end
   --players[1].no_inp=false
  end
  if s.screen==1 then
   s.tiles={"mouse (classic)","regular"}
  end
  new_hive(1,#menu.tiles+8,nil,
  32,32)
  for i=1,#menu.tiles do
	  hives_screen_pos[i].act=i
	 end
	 if(#players>0)players[1].id=3
  --gamerunning=false
  --end_bits()
 end
 menu.tut=function(s)
  new_hive(3,3,0)
  hidden[1]=true
  hidden[7]=true
  players[1].no_inp=true
  players[1].togo=1
  players[1].id=1
  s.tut_frame=0
  numbers[5]=1
  new_titlecard("get honey",90,-1)
 end
 menu.updtut=function(s)
  if(#titlecards==0)s.tut_frame+=1
  if s.tut_frame==60 then
   //players[1].hin=1
   players[1].id=2
   sfx(5)
  end
  if s.tut_frame==80 then
   //players[1].hin=1
   players[1].id=5
   sfx(7)
  end
  if s.tut_frame==90 then
   players[1].a=true
  end
  if s.tut_frame==100 then
   players[1].a=false
   music(2)
  end
  if s.tut_frame==110 then
   players[1].id=8
   music(2)
  end
  if s.tut_frame==200 and #titlecards==0 then
   new_titlecard("avoid bees",90,-1)
  end
  if s.tut_frame==230 then
   players[1].id=7
  end
  --players[1].hin=1
 end
 menu:init()
 menu.call=function(s,id)
  if not id or (id and id>s.offset and id<=#s.tiles+s.offset)then
	  s.mode=(id and s.tiles[id+s.offset])or s.mode
	  if(s.mode=="play")then
	  	menu.screen=1
	  	menu:init()
	  elseif(s.mode=="mouse (classic)")then
	  	menu.active=false
	  	set_plrs(0)
	   new_hive(10,10)
	   new_titlecard("classic")
	  elseif(s.mode=="regular")then
	  	menu.active=false
	   new_hive(15,10)
	   new_titlecard("regular")
	  elseif(s.mode=="tutorial")then
	   s:tut()
	  end
	  if not gamerunning then
	   --s.offset=#beehive
	  end
	 end
 end
 menu.upd=function(s)
  if s.mode=="tutorial"then
   s:updtut()
  end
  for p=0,8 do --join
   for b=0,6 do
    if btnp(b,p) then
     if s.mode=="tutorial"then
      s.mode="menu"
      menu.screen=0 music(-1)
	  	  menu:init()
      break
     end
     print(b, b*5 + 10, p*7, p+1)
     if plrs[p+1]==0then
      --input detected, plr join
      plrs[p+1]=1
      sfx(27,#players,
      -2+#players*2,2)
      
      local np=add_plr(p+1)
      np.id=3+p
      add(players,np)
     end
    end
   end
  end
 end
 menu.drw=function(s)
  if s.mode~="tutorial"then
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

function setchr(s,i,c)
 return sub(s,1,i-1)..c..sub(s,i+1)
end
num_cols={12,11,8,12,14,13,5}
--cols={8,9,10,11,12,13,14,15,6,7}
--cols_shade={4,2,9,3,5,5,4,4,13,6}
cols={7,6,13,5}
cols_shade={6,1,5,1}
function sp_part(id,x,y,dx,dy,ang_change)
 pa={}pa.tag=nil pa.id=id or 0
 pa.ang_change=ang_change pa.recol={}
 pa.x=x or 64 pa.y=y or 64
 pa.dx=dx or rnd(4)-8 pa.dy=dy or rnd(1)
 pa.gx=.94 pa.gy=.1
 pa.ang=0 pa.t=-1
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
  if s.recol then
   for i=1,#s.recol do
    pal(s.recol[i][1],s.recol[i][2])
   end
  end
  if flr(s.ang)%4==0 then
   spr(s.id,s.x,s.y)
  elseif flr(s.ang)%4==1 then
   sprot(s.x,s.y,8,8,s.id,0,1)
  elseif flr(s.ang)%4==2 then
   spr(s.id,s.x,s.y,1,1,true,true)
  elseif flr(s.ang)%4==3 then
   sprot(s.x,s.y,8,8,s.id,0,-1)
  end
  pal()
 end
 add(parts,pa)
 return pa
end
function set_flag(id,plr)
 fl={} fl.from=plr
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
 end
 fl.drw=function(s)
  if not s.dying then
  if(s.from)then
   pal(6,cols[s.from+1])
   pal(13,cols_shade[s.from+1])
  end
  local oy=(hives_screen_pos[s.id].pressing or hives_screen_pos[s.id].temp_press)and 1 or 0
  spr(7,s.x,s.y+oy)pal() end
 end
 fl.remove=function(s)
  local corpse=sp_part(7,s.x,s.y,
  rrnd(1.5),-1.5,true)
  if(s.from)then
   add(corpse.recol,{6,cols[s.from+1]})
   add(corpse.recol,{13,cols_shade[s.from+1]})
  end
  
  sfx(10)
 	s.dx=4-rnd(8)
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
  players[i]=plr
 end
end
function new_cell(i)i=i or #beehive+1
	beehive=beehive.."#"
	mines[i]=false
	revealed[i]=false
	hex_pos(i-1,x_os,y_os)
	return hives_screen_pos[#beehive]
end
function hex_pos(i)
 local offset=0local y=flr(i/hive_wi)
 if(y%2==1)offset=.5
	local x=((i+offset)%hive_wi)
	add(hives_screen_pos,
	{x_os+(x*8),y_os+(y*7)})
end
function new_hive(wi,hi,bees,x,y)
 honeyjar:init()
 mines={} sz=wi hi=hi or wi
	beehive="" hive_size=sz
	hive_wi=wi or 8
	hive_hi=hi or wi
	hexs=wi*hi
	
	hidden={} -- hidden cells
	revealed={} --cells shown
	reveal_que={} --cells to be shown
	--generate hive position on screen
	hives_screen_pos={}
	x_os=x or 64-(hive_wi*4)-3
	y_os=y or 64-(hive_hi*4)+6
	for i=0,hexs-1 do 
  --hex_pos(i,x_os,y_os)
 end
	for i=1,wi*hi do --map
	 new_cell(i)
	end
	mines[wi*hi]=false
	all_bees=0
	bees=bees or flr(hexs*.2)
	bees_left=min(bees,hexs-1) or sz*2 --add bees to map
	unopened=0 total_bees=bees_left
	while bees_left>0 do
	 local id=flr(rnd(wi*hi))
	 if beehive[id]=="#" then
	  beehive=setchr(beehive,id,"b")
	  mines[id]=true
	  bees_left-=1 all_bees+=1
	 end
	end
	
	for i=1,wi*hi do
	 revealed[i]=false unopened+=1
	end
	parts={} --particles
	if(flags)then
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
 first_call=true
 gamerunning=true
 timer_reset()
end

function _update60()
 --update mouse
 pm=mheld prm=mreld
 mx=stat(32)my=stat(33)
 if(mpressed)then mpressed=false
 else if stat(34)==1 and pm~=1 then
  mpressed=true
  end
 end
 mheld=stat(34)==1
 a_released=(pm and not mheld)
 
 if(mressed)then mressed=false
 else if stat(34)==2 and not prm then
  mressed=true
  end
 end
 mreld=stat(34)==2
 b_released=(prm and not mreld)
 --pm=stat(34)==1
 --prm=stat(34)==1
 --update plr inputs
 for i=1,#players do
  local plr=players[i]
  if #titlecards==0 then
  	plr:upd()
  else
   plr:move()
  end
 end
 --validate plr movements
 for i=1,#players do
  local plr=players[i]
  --if player moved
  plr.togo=plr.togo or plr.id
  if plr.togo~=plr.id then
   --todo:add a bounds check
   if plr.togo<1 and plr.togo>(hexs) then
    --plr.togo=plr.id
   end
   for j=1,#players do
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
 for i=1,#players do
  plr=players[i]
  if(plr.id~=plr.togo)then
   move_sfx=true
   plr.id=plr.togo
  end
 end
 if(move_sfx and #players<=2)sfx(5+rnd(4))
 
 --hive interaction
 --selecting=nil
 --if selecting then
  --hives_screen_pos[selecting].pressing=nil
 --end
 if #titlecards==0 then
 if a_released and selecting then
  --perform_act(selecting)
  release_cell(selecting,nil)
 end
 for i=1,#hives_screen_pos do
  local cell=hives_screen_pos[i]
  --local mx=plr.x local my=plr.y
  //use id instead?
  if(mx>=cell[1] and mx<cell[1]+8
  and my>=cell[2] and my<cell[2]+8)then
  	--selecting=i
  	--set cell to pressed
	 	if mpressed then
	 		if selecting then
  	  hives_screen_pos[selecting].pressing=nil
  	 else
  	  sfx(14)
  	 end
  	 
	 	 hives_screen_pos[i].pressing=true
	 	 --s.pressing=s.id
	 	 selecting=i
	 	end
	 	if false then --moved
	 	 s.pressing=nil
	 	 hives_screen_pos[s.id].pressing=nil
	 	end
	 	
	 	--moved from pressly-set cell
	 	--if s.pressing~=s.id and s.pressing~=nil then
	 	 --s.pressing=nil
	 	 --hives_screen_pos[s.id].pressing=nil
	 	--end
  	if(a_released) and revealed[i]==false and flagfield[i]==nil then
 	  open_cell(i,nil)
  	elseif(a_released or mheld)and revealed[i]==true then
  	 chord_cell(i,a_released)
  	elseif(mressed) and revealed[i]==false then
	   flag_cell(i,nil)
   end
   if a_released then
    perform_act(i)
 	  release_cell(i,nil)
 	 end
   break --dont want to select multiple at once
  end
 end
 end
 --update flags
 for i=#flags,1,-1 do
  flags[i]:upd()
 end
 --update particles
 for i=#parts,1,-1 do
  parts[i]:upd()
 end
 --update honeyblops
 --pal()
 for i=#hblobs,1,-1 do
  hblobs[i]:upd()
 end
 
 --menu
 if(menu.active)menu:upd()
 
 --update cells in reveal que
 if #reveal_que>=0 then
	 for i=1,#reveal_que do--#reveal_que,1,-1 do
	  local check=reveal_que[i]
	  if(check)then
	   check:upd()
	   if check.t==0 or check.done then
	    check:set()
	    //del(reveal_que,reveal_que[i])
	   end
	  end
	 end
 end
 
 --draw titlecard
 if #titlecards>0 then
  titlecards[1]:upd()
 end
end

function _draw()cls()
 originx=0 originy=0
 os=64-(hive_size*4)
 
 --draw cells
 for i=1,#hives_screen_pos do
  local cell=hives_screen_pos[i]
  local id=1
  if revealed[i]==true then
   id=2
  end
  if hidden[i]==true then
   id=3
  end
  --if debug
  if debug and beehive[i]=="b"then
   id=5
  end
  if revealed[i]and mines[i]==true then
   id=6
  end
  if cell.act then
   if(cell.act=="back")id=49
   if(cell.act=="again")id=50
   pal(1,5)
   pal(9,6)pal(2,13)pal(15,6)
  end
  local oy=0
  if cell.pressing then oy=1 end
  if cell.temp_press then oy=1cell.temp_press=nil end
  spr(id,cell[1],cell[2]+oy)pal()
  
  if debug or revealed[i]then
   local txt=(beehive[i]~="b" and numbers[i]) or ""
	  print(txt,cell[1]+2,cell[2]+1+oy,
	  num_cols[numbers[i]])
  end
  //print(beehive[i],cell[1],cell[2],7)
 end
 --highlight selected
 if revealed[selecting]==false then
 	//hilight(hives_screen_pos[selecting])
 	//print("\#1"..(selecting-1)%hive_size..","..ceil(selecting/hive_size)-1)
 	local adj=neighbours(selecting)
 	for i=1,#adj do
 	 --hilight(hives_screen_pos[adj[i]])
 	end
 end
 --menu
 if(menu.active)menu:drw()
 //?"\#1"..#reveal_que
 //?"\#5"..#players
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
  hblobs[i]:drw()
 end
 --draw ui
 ui_draw()
 --draw mouse
 pal(1,0)
 local id=17
 if(mheld)id=18
 spr(id,mx,my)
 if first_call==true then
  spr(33,mx,my)
 end
 for i=1,#players do
  local plr=players[i]
  plr:drw()
 end
 pal()
 --draw titlecard
 if #titlecards>0 then
  titlecards[1]:drw()
 end
end

function mark_hex(id,t)
 local mark={}
 mark.id=id
 mark.t=mark.full_t or t or 0
 mark.full_t=mark.full_t or t
 mark.done=false
 mark.lose_all=true
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
	  unopened-=1
	  s.done=true sfx(2)
	  honeyblob(s.id)
	  if gamerunning then
	   winlose(mines[s.id])
	  end
  end
	 hives_screen_pos[s.id].pressing=nil
	 del(reveal_que,s)
 end
 mark.upd=function(s)
  hives_screen_pos[s.id].pressing=nil
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

function relocate_bee(id)
	if mines[id]then
	 mines[id]=false
	 for i=1,#mines do --swap with earliest non-mine cell
	  if(i~=id and (mines[i]==nil or mines[i]==false))then
	   --move bee
	   mines[i]=true
	   beehive=setchr(beehive,id,"#")
	   beehive=setchr(beehive,i,"b")
	   --update number list
	   local adj=neighbours(id)
	   for j=1,#adj do
	    numbers[adj[j]]-=1
	    if(numbers[adj[j]]==0)numbers[adj[j]]=nil
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
 game_length=t_end-t_start
end
function winlose(gameover)
 if gameover then--unopened<(total_bees or 0) then
  --lost
 	sfx(3) gamerunning=false
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
 elseif unopened==total_bees then
  --win
  gamerunning=false
  if not menu.active then music(1)
  else sfx(20)end
 end
 if not gamerunning then
 	--menu.active=true
 	end_bits()
 	timer_end()
 end
end
function end_bits()
	new_cell().act="back"
	new_cell().act="again"
end

function neighbours(id)
 local dirs={"tl","tr","l","r","bl","br"}
 local adj={}
 for i=1,#dirs do
  add(adj,transpose(id,dirs[i]))
 end
 return adj
end
function transpose(id,os)
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
 n_id<=#beehive) then
  ty=((os=="tl"or os=="tr")and -1
  or((os=="bl"or os=="br")and 1
  or 0))+y_
  if ceil((n_id)/hive_wi)==ty then
   return n_id
  end
 end
 --return id
end

function open_cell(i,plr)
	if first_call then --first click is safe
  first_call=false sfx(12)
  relocate_bee(i)
  for i=1,#players do
   players[i].first_call=false
  end
  timer_start()
 else
  sfx(13)
 end
 local check=mark_hex(i,5)
 check.t=0
end

function chord_cell(i,perform)
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
		 	open_cell(nonflags[j],0)
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
	   if fl.from==plr then
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
 local cell=hives_screen_pos[id]
 if cell.act=="back"then
  menu:reset()--menu.call(menu,i)
 elseif cell.act=="again"then
  --menu:init()--menu.call(menu,i)
  menu.call(menu)
 elseif tonum(cell.act)then
  menu.call(menu,tonum(cell.act))
 end
end

function new_titlecard(title,t,sf)
 cs={}cs.t=t or 90cs.title=title or "h"
 sfx(-1)
 if(sf==nil)then sfx(15,-1,0,16)
 else sfx(sf)end
 cs.upd=function(s)
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

honeyjar={}
honeyjar.x=109
honeyjar.y=0
honeyjar.init=function(s)
 honeyjar.open=true
 honeyjar.pips=0
 honeyjar.pressed=10
end honeyjar:init()
honeyjar.drw=function(s)
 local id=26 local oy=s.pressed==0 and 0 or 1
 if(s.open)id=25
 
 local p=flr((s.pips/(#hives_screen_pos-total_bees))*4)
 if(s.pips>0)rectfill(s.x+2,s.y+oy+5-p,s.x+5,s.y+oy+5,9)
 if(p>=4)s.open=false id=25
 spr(id,s.x,s.y+oy)
 s.pressed=max(s.pressed-1,0)
end

hblobs={}
function honeyblob(id)
 local c=hives_screen_pos[id]
 local hb={}hb.x=c[1] hb.y=c[2]
 hb.phase=0 hb.t=0 hb.offset=0
 hb.id=id
 hb.upd=function(s)
  s.t+=1
  if s.t==3then
   if(mines[s.id]==true)del(hblobs,s)
   s.phase=1
   s.offset=s.x-16
   if(s.x>=64)s.offset=s.x+16
  end
  if s.phase==1then
   s.x=lerp(s.x,
   s.offset,.1)
   --s.y=lerp(s.y,honeyjar.y-4,.05)
   if(s.x==s.offset or s.t>8)s.phase=2s.offset=y
   s.y=lerp(s.y,s.y-3,.3)
  elseif s.phase==2then
   s.x=lerp(s.x,honeyjar.x,.12)
   s.y=lerp(s.y,honeyjar.y-9,--.05
   (abs(honeyjar.y-s.y)/64)*.2
   )
   --if(s.x==honeyjar.x)s.phase=3
  end
  if abs(s.y-honeyjar.y)<3 then
   honeyjar.pips+=1
   honeyjar.pressed=2
   del(hblobs,s)
  end
 end
 hb.drw=function(s)
	 if s.phase==0 then
	 	spr(40,s.x,s.y)
	 elseif s.phase<=2then
	  spr(34,s.x,s.y)
	 end
 end
 add(hblobs,hb)
 return hblobs
end
-->8
--ui + misc

function lerp(a,b,z)
 //s.x+=((cell[1]+3)-s.x)*.35
 return a+(b-a)*z
end

function sprot(dx,dy,h,w,mx,my,rot)
 --dx the x position of the sprite
 --dy the y position of the sprite
 --h the height of the sprite from the map
 --w the width of the sprite from the map
 --rot = 1 rotate 90 degrees anticlockwise
 --rot = -1 rotate 90 degrees clockwise
 rot = rot or 1
 if rot!=1 then
  dx+=8
 end
 for i=0,w-1 do
	 local nx=dx+(i*rot)
	 tline(nx,dy,nx,dy+h,mx,my+i/8)
 end
end

--mouse_icon="\^:0103070305000000"
--flag_icon="\^:0707070404000000"
clock_icon="\^:0e151d110e000000"
function header()
	
end
function ui_draw()color(7)
 str=#flags
 str=all_bees
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
	 ol=print(p.clicks,ox+6,ty)
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
 honeyjar.x=128-l-15
 honeyjar:drw()
end
-->8
--player code

function add_plr(i)
	local plr={}
	plr.id=1plr.pl=i-1plr.c=i plr.first_call=true
	plr.cooldown=0
	plr.x=64 plr.y=64
	plr.hin=0plr.vin=0
	plr.prev_hin=plr.hin
	plr.prev_hin=plr.hin
	plr.last_hin=plr.hin
	plr.a=btn(🅾️,plr.pl)plr.b=0plr.ap=0plr.bp=0
	plr.no_inp=false
	plr.pressing=nil
	plr.togo=plr.id
	plr.prev_a=0
	plr.powerups={}
	plr.powerups["noflag"]=-1
	plr.clicks=0
	plr.upd=function(s)
	 --get controls
	 if not s.no_inp then
		 s.hin=tonum(btn(➡️,s.pl))-tonum(btn(⬅️,s.pl))
		 s.hinp=tonum(btnp(➡️,s.pl))-tonum(btnp(⬅️,s.pl))
		 s.vin=tonum(btn(⬇️,s.pl))-tonum(btn(⬆️,s.pl))
		 s.vinp=tonum(btnp(⬇️,s.pl))-tonum(btnp(⬆️,s.pl))
		 s.prev_hin=s.hin
		 s.prev_vin=s.vin
		 plr.prev_a=s.a
	 
		 s.ap=btnp(🅾️,s.pl)and not s.prev_a s.bp=btnp(❎,s.pl)
		 s.a=btn(🅾️,s.pl)s.b=btn(❎,s.pl)
		 if s.ap then
		  sfx(14)
		 end
	 end
	 local a_released=(s.prev_a and not s.a)
	 if a_released then
	  if s.pressing then
	   hives_screen_pos[s.id].pressing=false
	   s.pressing=nil
	  end
	 end
	 if s.cooldown==0then --move speed
	  --local cl=8
	 	local adj=neighbours(s.id)
	 	if s.vin==1 then --down
	 	 s.togo=transpose(s.id,
		 	 (s.hin==1and "br")or
		 	 (s.hin==-1and "bl")or
		 	 (s.hin==0and
		 	  (s.last_hin==1and "br")or
		 	  (s.last_hin==-1and "bl")
		 	))
		 	--go to empty space
		 	if transpose(s.id,"br")==nil then
		 	 s.togo=transpose(s.id,"bl")
		 	end 
		 	if transpose(s.id,"bl")==nil then
		 	 s.togo=transpose(s.id,"br")
		 	end 
		 	--s.cooldown=(s.togo~=s.id)and cl or s.cooldown
	 	end
	 	if s.vin==-1 then --up
	 	 s.togo=transpose(s.id,
		 	 (s.hin==1and "tr")or
		 	 (s.hin==-1and "tl")or
		 	 (s.hin==0and
		 	  (s.last_hin==1and "tr")or
		 	  (s.last_hin==-1and "tl")
		 	))
		 	--go to empty space
		 	if transpose(s.id,"tr")==nil then
		 	 s.togo=transpose(s.id,"tl")
		 	end 
		 	if transpose(s.id,"tl")==nil then
		 	 s.togo=transpose(s.id,"tr")
		 	end 
		 	--s.cooldown=(s.togo~=s.id)and cl or s.cooldown
	 	end
	 	if s.vin==0then--left right
	 	 s.togo=transpose(s.id,
	 	  (s.hin==1and "r")or
	 	  (s.hin==-1and"l")
	 	 )
	 	 --s.cooldown=(s.togo~=s.id)and cl or s.cooldown
	 	end
		else
		 if(s.cooldown>=1)s.cooldown-=1
		end
		--set cell to pressed
		if s.ap then
		 hives_screen_pos[s.id].pressing=true
		 s.pressing=s.id
		end
		if s.id~=s.togo then --moved
		 local cl=10
		 if s.powerups["noflag"]then
		  if s.powerups["noflag"]==0 or s.powerups["noflag"]==-1 then
		   cl=8
		  end
		 end
		 --s.pressing=nil
		 if s.pressing then
		  hives_screen_pos[s.pressing].pressing=nil
		  s.pressing=s.togo
		  if hives_screen_pos[s.togo]then
		   hives_screen_pos[s.togo].pressing=true
		  end
		 end
		 s.cooldown=(s.togo~=s.id)and cl or s.cooldown
		end
		
		--interactions
		if(a_released) and revealed[s.id]==false and flagfield[s.id]==nil then
		 open_cell(s.id,s.pl) s.clicks+=1
		 if s.powerups["noflag"]then
		 if s.powerups["noflag"]>0then
		  s.powerups["noflag"]-=1
		 end
		 end
	 elseif (s.a or a_released)and revealed[s.id]==true then--activate neighbours if flags-bee is met
		 chord_cell(s.id,a_released)
		elseif s.bp and revealed[s.id]==false then
		 flag_cell(s.id,s.pl)
		 if s.powerups["noflag"]then
		  s.powerups["noflag"]=8
		 end
		end
		
		if a_released then
		 perform_act(s.id)
	  s.pressing=nil
	  hives_screen_pos[s.id].pressing=nil 
	 end
	 
		--update last non-zero horizontal input
	 s.last_hin=s.hin~=0and s.hin or s.last_hin
		s.prev_a=s.a
		s:move()
	end
	plr.move=function(s)
	 s.id=min(s.id,#hives_screen_pos)
		local cell=hives_screen_pos[s.id]
		s.x+=((cell[1]+3)-s.x)*.35 //.4
		s.y+=((cell[2]+3)-s.y)*.35 //.7
	end
	plr.drw=function(s)
	 pal(6,cols[s.c])
	 pal(13,cols_shade[s.c])
	 local id=17
	 if(s.pressing~=nil)id=18
	 spr(id,s.x,s.y)
	 color(cols[s.c])
	 if s.first_call==true or first_call then
	  spr(33,s.x,s.y)
	 end
	 //print("\#2"..s.id.." "..s.cooldown)
	 //print("\#2"..s.hin.." "..s.vin)
	end
	return plr
end
__gfx__
00000000000900000001000000000000000000000009000000000000000000007777000000000000000000000000000000000000000000000000000000000000
0000000009f9990001111100000000000070700009999900000100000d6d60007766000000aaaa00000000000000000000000000005005000000000000000000
007007009f99999011111110000100007000007099f9f9900011110006d661000011aa000aaaaaa0005005000050050000500500050000500000000000000000
0007700099999992111111100011100000aaa0009ff9ff92011010100d6d61000a11aa110aaaaaa0000000000000000005000050000000000000000000000000
0007700099999992111111100011100070aaa0709ff9ff9201110110001161001a11aa110aaaaaa0005005000005500000055000005005000000000000000000
007007009999999211111110000100000000000099f9f99201101010000666000a11aa110aaaaaa0000550000005500000500500000550000000000000000000
00000000099999220111110000000000070007000999992500111100000011100011aa0000aaaa00000000000000000000000000000000000000000000000000
00000000000922000001000000000000000700000009250000010000000000000000000000000000000000000000000000000000000000000000000000000000
60006d60600000006d00000000040000000000000000000000010000000000000077770010000001878787870000000000000000000000000000000000000000
6600d6d06d000000666d000009494900000000000000000001112200000000000077770011000011110000110000000000000000000000000000000000000000
66606d6066d000006666610094949490000100000000000011222220000000000066660010007701100077010000000000000000000000000000000000000000
6d006000666d00000161110049494942001910000000000011202020000000000011aa0050000005500000050000000000000000000000000000000000000000
606060006666d00000d1000094949492001910000000000011220220000000000a11aa1150000005500000050000000000000000000000000000000000000000
00000000666661000000000049494942000100000000000011202020000000001a11aa1150000005500000050099000000000000000000000000000000000000
00000000016111000000000004949420000000000000000001222200000000000a11aa1110000001100000010999000000000990000000000000000000000000
0000000000d100000000000000092000000000000000000000020000000000000011aa0001555510015555109999900990099999000000000000000000000000
0666000000000000000000000000000000000000000000000000000000000000a00000a0700000a0000000000000000000000000000000000000000000000000
66d66000009aa9000009900000000000000000000000000000000000000000000900090000000000000000000000000000000000000000000000000000000000
66dd600000a77a00009a790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666600000a77a00009aa90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06660000009aa9000009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66d66000000000000000000000000000000000000000000000000000000000000a00090000000000000000000000000000000000000000000000000000000000
66d6600000000000000000000000000000000000000000000000000000000000900000a0a0000070000000000000000000000000000000000000000000000000
66d66000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06660000000600000006000000090000000900200009005020090020000000000000000000000000000000000000000000000000000000000000000000000000
66d6600006666600066666000999990009a9990009a9990009999900000000000000000000000000000000000000000000000000000000000000000000000000
6dd660006656666066566560999999909a9999909a99999099797990000000000000000000000000000000000000000000000000000000000000000000000000
666660006555566d6666666d99999992999999929999999297797792000000000000000000000000000000000000000000000000000000000000000000000000
066600006656656d6656656d99999992999999929999999297797792000000000000000000000000000000000000000000000000000000000000000000000000
66d660006666666d6665566d99999992999999929999999299797992000000000000000000000000000000000000000000000000000000000000000000000000
66d66000066666dd066666dd09999920099999220999992509999925000000000000000000000000000000000000000000000000000000000000000000000000
666660000006dd000006dd0000092000000922000009250020092500000000000000000000000000000000000000000000000000000000000000000000000000
06660000111111000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000000000000000000000
00000000111111099901111111111111111111111111111111111111111111111111111111111100000111111111111111111111000000000000000000000000
00000000111110999901111110011111111111111111111111111111111111111111111111111099990111111111111111111111000000000000000000000000
00000000111110909901111109911111111111111111111111111111111111111111111111110999990111100111111111111111000000000000000000000000
00000000111110299201111099911111111000110001100011111111100111000001110000010990990110099011110011111111000000000000000000000000
00000000111110099011111099911000111990109990099901110001090110999901109999009900990109999900009901111111000000000000000000000000
00000000111110292011111000000990111990099990999990010901090109999901099999009900990099909900999900001111000000000000000000000000
00000000111110990111111111199990111990990990990990900901090099009900990099009909990099009900999999901111000000000000000000000000
00000000111100940990110999099090109900900990999010900900990090009900900099009909990999099010990099901111000000000000000000000000
00000000111109499999009999000090109009909990099900900900990990999909909999009999900999990110990100001111000000000000000000000000
00000000111109990299010099011099099109999901099990900990901999999009999990109999010990001110990111111111000000000000000000000000
00000000111109920099010990111099090109000010000990999990901900000009000000109900110990110010990111111111000000000000000000000000
00000000111099901099010990111099990109000909900990999099901900009009000090109901110999009909990111111111000000000000000000000000
00000000111099200990009990111099901109999909999990999099901999999009999990109901111099999909901111111111000000000000000000000000
00000000111099010999009901111099011110999010999900090099011099990110999901199901111109999019901111111111000000000000000000000000
00000000111000010000100011111000111111000110000011101100111100000110000011199011111110000110011111111111000000000000000000000000
00000000000000000900000009000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009000000090000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009990900099900900099009000900009000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009000909090009090900000009090090000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009090909090909090900090009090090000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009900990099000900900090009909090000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000009002000090020000900200009002000090020000900200009002000090020000900200009002000090020000900200009002000090020000900200000
000009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f999000000
00009f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999900000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00000999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220000
00000009220900292209002922090029220900292209002922090029220900292209002922090029220900292209002922090029220900292209002922090020
0000000009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f99900
000000009f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f999990
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992
00000000099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209999922
00000009002922090029220900292209002922090029220900292209002922090029220900292209002922090029220900292209002922090029220900292200
000009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f999000000
00009f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999900000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00000999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220000
00000009220900292209002922090029220900292209002922090029220900292209002922090029220900292209002922090029220900292209002922090020
0000000009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f99900
000000009f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f999990
00000000999999929999999299999992999999929998999299999992999999929999999299999992999999929999999299999992999999929999999299999992
0000000099999992999999929999999299999992999849aa99999992999999929999999299999992999999929999999299999992999999929999999299999992
000000009999999299999992999999929999999299988a77a9999992999999929999999299999992999999929999999299999992999999929999999299999992
000000000999992209999922099999220999992209988a77a9999922099999220999992209999922099999220999992209999922099999220999992209999922
0000000900292209002922090029220900292209002889aa90292209002922090029220900292209002922090029220900292209002922090029220900292200
000009f9990009f9990009f9990009f9990009f999088888090009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f999000000
00009f9999909f9999909f9999909f9999909f999990080009909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999900000
0000999999929999999299999992999999929999999294099992999999929999999299999992999999929999999299999992999999929999999299a999920000
000099999992999929aa99999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299a99aa90000
00009999999299999a77a9999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299aaa77a0000
00000999992209999a77a9999922099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209aaa77a0000
000000092209002999aa90292209002922090029220900292209002922090029220900292209002922090029220900292209002922090029220900aa9aa90020
0000000009f999099999090009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f999aaaaa09900
000000009f999990090009909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f999990a0009990
00000000999999929209999299999992999999929999999299999992999999929999999299999992999999929999999299b99992999999929999999290999992
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299b39aa9999999929999999299999992
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299bba77a999999929999999299999992
00000000099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209bba77a099999220999992209999922
00000009002922090029220900292209002922090029220900292209002922090029220900292209002922090029220900bb9aa9002922090029220900292200
000009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f999bbbbb0990009f9990009f999000000
00009f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f999990b00099909f9999909f9999900000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999923099999299999992999999920000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00000999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220000
00000009220900292209002922090029220900292209002922090029220900292209002922090029220900292209002922090029220900292209002922090020
0000000009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f99900
000000009f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f999990
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992
00000000099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209999922
00000009002922090029220900292209002922090029220900292209002922090029220900292209002922090029220900292209002922090029220900292200
000009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f999000000
00009f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999900000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00009999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999920000
00000999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220000
00000009220900292209002922090029220900292209002922090029220900292209002922090029220900292209002922090029220900292209002922090020
0000000009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f9990009f99900
000000009f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f9999909f999990
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992
00000000999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992999999929999999299999992
00000000099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209999922099999220999992209999922
00000000000922000009220000092200000922000009220000092200000922000009220000092200000922000009220000092200000922000009220000092200
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

__map__
0000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000101501b000140001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c0450b115136340b62000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040100000d110251102b110131201c12015120161200b11016110141101311012120121201213012140121301213015140161401a1401b1401a140191401a1401a1401c1401c1401a14017120151201413012140
01020000200102201023020230202303006040060501d050130300d03000000000000000000000000000c0300e040170501a05018050140500e0300d02000000220502205012050120500a0500a0500a05000000
010600001301500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000e01500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700001501500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700001001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001613019620116101e12006610201100261004620046200d60000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200000a1200362017130076200a6200a1100562011110026100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000241501f140191401013009120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9103000027140221401d1401714027120221201d1201712027110221101d110171100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
91020000136501b1100c6200365016120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010e0000171401f15519140211551a140231551c140251551d150261551f1502816521160291750000000000171551c155151551a15513155181551d155000000000000000000000000000000000000000000000
010900001405000000140251405019050000000b05019025000000b025140501405019051190521e050190251d0501e025190501d025120501405212051120501605000000160251605019050000001505019025
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 20424344
00 21424344
00 22424344
00 23424344
00 24254344

