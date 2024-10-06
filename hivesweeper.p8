pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
 set_plrs(4)
 new_hive(8)
 poke(0x5f2d, 1) --mouse mode
end

function setchr(s,i,c)
 return sub(s,1,i-1)..c..sub(s,i+1)
end
cols={8,9,10,11,12,13,14,15,6,7}
cols_shade={4,2,9,3,5,5,4,4,13,6}

function set_plrs(ppl)
 players={}
 for i=1,ppl do
  local plr={}
  plr.id=1plr.pl=i-1plr.c=i
  plr.cooldown=0
  plr.x=64 plr.y=64
  plr.hin=0plr.vin=0
  plr.prev_hin=plr.hin
  plr.prev_hin=plr.hin
  plr.last_hin=plr.hin
  plr.a=0plr.b=0plr.ap=0plr.bp=0
  plr.togo=plr.id
  plr.upd=function(s)
   s.hin=tonum(btn(➡️,s.pl))-tonum(btn(⬅️,s.pl))
   s.hinp=tonum(btnp(➡️,s.pl))-tonum(btnp(⬅️,s.pl))
	  s.vin=tonum(btn(⬇️,s.pl))-tonum(btn(⬆️,s.pl))
	  s.vinp=tonum(btnp(⬇️,s.pl))-tonum(btnp(⬆️,s.pl))
	  s.prev_hin=s.hin
	  s.prev_vin=s.vin
	  
	  s.a=btn(🅾️,s.pl)s.b=btn(❎,s.pl)
	  s.ap=btnp(🅾️,s.pl)s.bp=btnp(❎,s.pl)
	  
	  if s.cooldown==0then
	   local cl=4
	  	local adj=neighbours(s.id)
		 	if s.vin==1 then --down
		 	 s.togo=transpose(s.id,
			 	 (s.hin==1and "br")or
			 	 (s.hin==-1and "bl")or
			 	 (s.hin==0and
			 	  (s.last_hin==1and "br")or
			 	  (s.last_hin==-1and "bl")
			 	))
			 	s.cooldown=(s.togo~=s.id)and cl or s.cooldown
		 	end
		 	if s.vin==-1 then --up
		 	 s.togo=transpose(s.id,
			 	 (s.hin==1and "tr")or
			 	 (s.hin==-1and "tl")or
			 	 (s.hin==0and
			 	  (s.last_hin==1and "tr")or
			 	  (s.last_hin==-1and "tl")
			 	))
			 	s.cooldown=(s.togo~=s.id)and cl or s.cooldown
		 	end
		 	if s.vin==0then--left right
		 	 s.togo=transpose(s.id,
		 	  (s.hin==1and "r")or
		 	  (s.hin==-1and"l")
		 	 )
		 	 s.cooldown=(s.togo~=s.id)and cl or s.cooldown
		 	end
	 	else
	 	 if(s.cooldown>=1)s.cooldown-=1
	 	end
	 	--activate a hidden cell
	 	if s.ap and revealed[s.id]==false then
	 	 local check=mark_hex(s.id,10)
  	 check.t=0
  	end
  	--update last non-zero horizontal input
 	 s.last_hin=s.hin~=0and s.hin or s.last_hin
	 	
	 	local cell=hives_screen_pos[s.id]
	 	s.x+=((cell[1]+3)-s.x)*.4
	 	s.y+=((cell[2]+3)-s.y)*.7
  end
  plr.drw=function(s)
   pal(6,cols[s.c])
   pal(13,cols_shade[s.c])
   spr(17,s.x,s.y)
   color(cols[s.c])
   //print("\#2"..s.id.." "..s.cooldown)
   //print("\#2"..s.hin.." "..s.vin)
  end
  players[i]=plr
 end
end

function new_hive(sz,bees)
 mines={}
	beehive="" hive_size=sz
	hexs=sz*sz
	for i=1,sz*sz do --map
	 beehive=beehive.."#"
	 mines[i]=false
	end
	mines[sz*sz]=false
	
	bees_left=bees or sz*2 --add bees to map
	while bees_left>0 do
	 local id=flr(rnd(sz*sz))
	 if beehive[id]=="#" then
	  beehive=setchr(beehive,id,"b")
	  mines[id]=true
	  bees_left-=1
	 end
	end
	revealed={} --cells shown
	reveal_que={} --cells to be shown
	for i=1,sz*sz do
	 revealed[i]=false
	end
	flagged={} --cells flagged
	numbers={} --no. of adjacents
	numbers=load_bees()
	
	--generate hive position on screen
	hives_screen_pos={}
	os=64-(hive_size*4)
	for i=0,hexs-1 do 
  offset=0
  y=flr(i/hive_size)
  if(y%2==1)offset=.5
 	x=((i+offset)%hive_size)
 	
 	add(hives_screen_pos,
 	{os+(x*8),os+(y*8)})
 end
 sfx(4)
end

function _update()
 --update mouse
 mx=stat(32)my=stat(33)
 if(mpressed)then mpressed=false
 else if stat(34)==1 and mheld~=1 then
  mpressed=true
  end
 end
 mheld=stat(34)
 
 --update plr inputs
 for i=1,#players do
  local plr=players[i]
  plr:upd()
 end
 --validate plr movements
 for i=1,#players do
  local plr=players[i]
  --if player moved
  if plr.togo~=plr.id then
   --todo:add a bounds check
   if plr.togo<1 and plr.togo>(hive_size*hive_size) then
    plr.togo=plr.id
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
  if(plr.id~=plr.togo)move_sfx=true
  plr.id=plr.togo
 end
 if(move_sfx)sfx(5+rnd(4))
 
 --hive interaction
 selecting=nil
 for i=1,#hives_screen_pos do
  local cell=hives_screen_pos[i]
  for j=1,#players do
   local plr=players[j]
   --local mx=plr.x local my=plr.y
   //use id instead?
	  if(mx>=cell[1] and mx<cell[1]+8
	  and my>=cell[2] and my<cell[2]+8)then
	  	selecting=i
	  	if(mpressed) and revealed[i]==false then
	  	 local check=mark_hex(i,10)
	  	 check.t=0
	  	end
	  end
	 end
 end
 
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
  --if debug
  if debug and beehive[i]=="b"then
   id=5
  end
  if revealed[i]and mines[i]==true then
   id=6
  end
  spr(id,cell[1],cell[2])
  
  if debug or revealed[i]then
	  print((beehive[i]~="b" and numbers[i]) or "",
	  cell[1]+2,cell[2]+1,7)
  end
  //print(beehive[i],cell[1],cell[2],7)
 end
 --highlight selected
 if revealed[selecting]==false then
 	//hilight(hives_screen_pos[selecting])
 	//print("\#1"..(selecting-1)%hive_size..","..ceil(selecting/hive_size)-1)
 	local adj=neighbours(selecting)
 	for i=1,#adj do
 	 hilight(hives_screen_pos[adj[i]])
 	end
 end
 //?"\#1"..#reveal_que
 //?"\#5"..#players
 for i=1,#reveal_que do
  reveal_que[i]:drw()
 end
 --draw mouse
 pal(1,0)
 local id=17
 if(mpressed)id=18
 spr(id,mx,my)
 for i=1,#players do
  local plr=players[i]
  plr:drw()
 end
 pal()
end
function transpose(id,os)
 local mod_x=id%hive_size
	--odd row or not
	local y_=ceil(id/hive_size)
	local odd=(y_%2==0) and 1 or 0
	--corner fixing
	if(mod_x==0 and y_%2==0)odd=1
	if(mod_x==0 and y_%2==1)odd=0
	--dir to id number conversion
	local n_id=
	os=="tl"and -hive_size-1+odd or
	//os=="u"and -hive_size-1+odd or
	os=="tr"and -hive_size+odd or
	os=="l"and -1 or
	os=="r"and 1 or
	os=="bl"and hive_size-1+odd or
	os=="br"and hive_size+odd or 0
 --get new position
 n_id+=id
 if (n_id>0 and 
 n_id<=hive_size*hive_size) then
  ty=((os=="tl"or os=="tr")and -1
  or((os=="bl"or os=="br")and 1
  or 0))+y_
  if ceil((n_id)/hive_size)==ty then
   return n_id
  end
 end
 return id
end
function neighbours(id)
 local mod_x=id%hive_size
	--odd row or not
	local y_=ceil(id/hive_size)
	local odd=(y_%2==0) and 1 or 0
	--corner fixing
	if(mod_x==0 and y_%2==0)odd=1
	if(mod_x==0 and y_%2==1)odd=0
	local adj={-hive_size-1+odd,-hive_size+odd,-1,1,hive_size-1+odd,hive_size+odd}
	local out={}
	for i=#adj,1,-1 do
	 local n_id=id+adj[i]
	 mod_ax=n_id%hive_size
	 --if in hive range
	 if (n_id>0 and n_id<=hive_size*hive_size 
	 and n_id%hive_size) then
	  --if neighbor on expected target y
	  ty=(i<=2 and -1 or (i>4 and 1 or 0))+y_
	  if ceil((n_id)/hive_size)==ty then
	   add(out,n_id)
	  else
	   add(out,id)
	  end
	 end
	end
	return out
end

function mark_hex(id,t)
 local mark={}
 mark.id=id
 mark.t=t or 0
 mark.full_t=t
 mark.done=false
 mark.set=function(s)
  --if cell isnt already revealed
  if revealed[s.id]==false then
   --if cell has no bees near
   if ((numbers[s.id] or 0)==0) then
    local m_adj=neighbours(s.id)
	   for i=1,#m_adj do
	    local n_id=m_adj[i]
	    if revealed[n_id]==false then
	     --put new mark for cell 
	     --on que, inherit stats
	     local new_mark=mark_hex(n_id)
	     for j,val in pairs(s) do
	      new_mark[j]=val
	     end
	     --reset delay as by now its 0
	     new_mark.id=n_id
	     new_mark.t=s.full_t
	    end
	   end
   end
  end
	 revealed[s.id]=true
	 s.done=true sfx(2)
	 del(reveal_que,s)
 end
 mark.upd=function(s)
  if s.t>1 then
   s.t-=1
  else
   s.set(s)
  end
 end
 mark.drw=function(s)
  local cell=hives_screen_pos[s.id]
  circfill(cell[1]+4,cell[2]+4,(1-(s.t/s.full_t))*8)
 end
 add(reveal_que,mark)
 return mark
end

--highlight
function hilight(cell)
 spr(3,cell[1],cell[2])
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
__gfx__
00000000000900000002000000000000000000002009002000010000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009999900022244000a0a0a00007070000999990001112200067670000000000000000000000000000000000000000000000000000000000000000000
007007009999999022444440a07070a0700000709979799011222220076771000000000000000000000000000000000000000000000000000000000000000000
0007700099999992224444400700070000aaa0009779779211202020067671000000000000000000000000000000000000000000000000000000000000000000
000770009999999222444440a07070a070aaa0709779779211220220000071000000000000000000000000000000000000000000000000000000000000000000
0070070099999992224444400a070a00000000009979799211202020000777000000000000000000000000000000000000000000000000000000000000000000
00000000099999200244440000a0a000070007000999992501222200000011100000000000000000000000000000000000000000000000000000000000000000
000000000009200000040000000a0000000700002009250000020000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006d0000006d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000066d00000d6d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666d00006d6d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006666d000d6d6d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666661006d6dd10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000161110001d1110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000d1000000d1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000200900200009002000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999000999990009999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999909999999099999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999929999999299999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999929999999299999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999929999999299999992000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999250999992209999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000200925000009220000092000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000101501b000140001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000c02521615216140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050100000d1001011011120131301413015140161501715016150141501315012150121401214012140121301213015140161401a1501b1501a150191501a1501a1501c1501c1501a14017120151201413012140
01020000200102201023020230202303006040060501d050130300d03000000000000000000000000000c0300e040170501a05018050140500e0300d02000000220502205012050120500a0500a0500a05000000
010700001301500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000e01500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700001501500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700001001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
