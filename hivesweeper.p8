pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
 set_plrs(4)
 new_hive(15,10)
 poke(0x5f2d, 1) --mouse mode
 --debug=true
end

function setchr(s,i,c)
 return sub(s,1,i-1)..c..sub(s,i+1)
end
num_cols={12,11,8,12,14,13,5}
cols={8,9,10,11,12,13,14,15,6,7}
cols_shade={4,2,9,3,5,5,4,4,13,6}

function set_flag(id,plr)
 fl={}fl.dying=false fl.from=plr
 fl.x=hives_screen_pos[id][1]
 fl.y=hives_screen_pos[id][2]
 fl.dx=0 fl.dy=0 fl.id=id
 sfx(9)
 if flagfield[fl.id]then
  flagfield[fl.id]+=1
 else
  flagfield[fl.id]=1
 end
 fl.upd=function(s)
  if s.dying then
   s.x+=s.dx s.y+=s.dy
   s.dx*=.9s.dy+=.2
   if s.y>128 then
    del(flags,s)
   end
  end
 end
 fl.drw=function(s)
  if(s.from)then
   pal(7,cols[s.from+1])
   pal(6,cols_shade[s.from+1])
  end
  spr(7,s.x,s.y)pal()
 end
 fl.remove=function(s)
  sfx(10)s.dying=true
 	s.dx=4-rnd(8)
 	s.dy=-3-rnd(1) 
  if(flagfield[s.id])then
   flagfield[s.id]=(flagfield[s.id]>1 and flagfield[s.id]-1) or nil
  else
   --flagfield[s.id]=nil
  end
  s.id=nil
 end
 add(flags,fl)
 return fl
end

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
	 	if s.ap and revealed[s.id]==false and flagfield[s.id]==nil then
	 	 local check=mark_hex(s.id,5)
  	 check.t=0
  	 check:set()
  	end
  	--flag a cell
  	if s.bp and revealed[s.id]==false then
  	 --is a flag already there?
  	 local occupied=false
  	 for j=1,#flags do
  	  local fl=flags[j]
  	  if fl.id==s.id then
  	   occupied=true
  	   --delete own flag
  	   if fl.from==s.pl then
  	    fl:remove()
  	   end
  	  end
  	 end
  	 if not occupied then--free cell
  	  set_flag(s.id,s.pl)
  	 end
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

function new_hive(wi,hi,bees)
 mines={} sz=wi hi=hi or wi
	beehive="" hive_size=sz
	hive_wi=wi or 8
	hive_hi=hi or wi
	hexs=wi*hi
	for i=1,wi*hi do --map
	 beehive=beehive.."#"
	 mines[i]=false
	end
	mines[wi*hi]=false
	
	bees_left=bees or sz*2 --add bees to map
	while bees_left>0 do
	 local id=flr(rnd(wi*hi))
	 if beehive[id]=="#" then
	  beehive=setchr(beehive,id,"b")
	  mines[id]=true
	  bees_left-=1
	 end
	end
	revealed={} --cells shown
	reveal_que={} --cells to be shown
	for i=1,wi*hi do
	 revealed[i]=false
	end
	flags={} --cells flagged
	flagfield={}
	numbers={} --no. of adjacents
	numbers=load_bees()
	
	--generate hive position on screen
	hives_screen_pos={}
	local x_os=64-(hive_wi*4)
	local y_os=64-(hive_hi*4)
	for i=0,hexs-1 do 
  offset=0
  y=flr(i/hive_wi)
  if(y%2==1)offset=.5
 	x=((i+offset)%hive_wi)
 	
 	add(hives_screen_pos,
 	{x_os+(x*8),y_os+(y*8)})
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
 
 if(mressed)then mressed=false
 else if stat(34)==2 and mreld~=2 then
  mressed=true
  end
 end
 mreld=stat(34)
 
 --update plr inputs
 for i=1,#players do
  local plr=players[i]
  plr:upd()
 end
 --validate plr movements
 for i=1,#players do
  local plr=players[i]
  --if player moved
  plr.togo=plr.togo or plr.id
  if plr.togo~=plr.id then
   --todo:add a bounds check
   if plr.togo<1 and plr.togo>(hexs) then
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
  --local mx=plr.x local my=plr.y
  //use id instead?
  if(mx>=cell[1] and mx<cell[1]+8
  and my>=cell[2] and my<cell[2]+8)then
  	selecting=i
  	if(mpressed) and revealed[i]==false and flagfield[i]==nil then
  	 local check=mark_hex(i,5)
  	 check.t=0
  	elseif(mressed) and revealed[i]==false then
	    --is a flag already there?
  	 local occupied=false
  	 for j=1,#flags do
  	  local fl=flags[j]
  	  if fl.id==i then
  	   occupied=true
  	   --delete own flag
  	   if fl.from==nil then
  	    fl:remove()
  	   end
  	  end
  	 end
  	 if not occupied then--free cell
  	  set_flag(i,nil)
  	 end
    --set_flag(i,nil)
   end
  end
 end
 --update flags
 for i=#flags,1,-1 do
  local fl=flags[i]
  fl:upd()
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
   local txt=(beehive[i]~="b" and numbers[i]) or ""
	  print(txt,cell[1]+2,cell[2]+1,
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
 	 hilight(hives_screen_pos[adj[i]])
 	end
 end
 //?"\#1"..#reveal_que
 //?"\#5"..#players
 for i=1,#reveal_que do
  reveal_que[i]:drw()
 end
 for i=1,#flags do
  local fl=flags[i]
  fl:drw()
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
 n_id<=hexs) then
  ty=((os=="tl"or os=="tr")and -1
  or((os=="bl"or os=="br")and 1
  or 0))+y_
  if ceil((n_id)/hive_wi)==ty then
   return n_id
  end
 end
 --return id
end

function neighbours(id)
 local dirs={"tl","tr","l","r","bl","br"}
 local adj={}
 for i=1,#dirs do
  add(adj,transpose(id,dirs[i]))
 end
 return adj
end

function mark_hex(id,t)
 local mark={}
 mark.id=id
 mark.t=mark.full_t or t or 0
 mark.full_t=mark.full_t or t
 mark.done=false
 mark.set=function(s)
  local to_reveal=true
  --if cell isnt already revealed
  if revealed[s.id]==false then
   --if cell has no bees near
   if ((numbers[s.id] or 0)==0 and (flagfield[s.id]==nil)) then
    to_reveal=true
    local m_adj=neighbours(s.id)
	   for i=1,#m_adj do
	    local n_id=m_adj[i]
	    if revealed[n_id]==false and (flagfield[n_id]==nil or flagfield[n_id]==0) then
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
  end
  --if to_reveal then
	  revealed[s.id]=true
	  s.done=true sfx(2)
	 --end
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
  //local cell=hives_screen_pos[s.id]
  //circfill(cell[1]+4,cell[2]+4,(1-(s.t/s.full_t))*8)
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
00000000000900000001000000000000000000002009002000010000000000007777000000000000000000000000000000000000000000000000000000000000
0000000009a99900011155000a0a0a000070700009999900011122000d7d70007766000000000000000000000000000000000000000000000000000000000000
007007009a99999011555550a07070a070000070997979901122222007d771000011aa0000000000000000000000000000000000000000000000000000000000
0007700099999992115555500700070000aaa00097797792112020200d7d71000a11aa1100000000000000000000000000000000000000000000000000000000
000770009999999211555550a07070a070aaa0709779779211220220000071001a11aa1100000000000000000000000000000000000000000000000000000000
0070070099999992115555500a070a00000000009979799211202020000777000a11aa1100000000000000000000000000000000000000000000000000000000
00000000099999200155550000a0a000070007000999992501222200000011100011aa0000000000000000000000000000000000000000000000000000000000
000000000009200000050000000a0000000700002009250000020000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600000006000000000040000000000000000000000000000000000000077770000000000000000000000000000000000000000000000000000000000
000000006d0000006d00000009494900000000000000000000000000000000000077770000000000000000000000000000000000000000000000000000000000
0000000066d00000d6d0000094949490000000000000000000000000000000000066660000000000000000000000000000000000000000000000000000000000
00000000666d00006d6d000049494942000000000000000000000000000000000011aa0000000000000000000000000000000000000000000000000000000000
000000006666d000d6d6d00094949492000000000000000000000000000000000a11aa1100000000000000000000000000000000000000000000000000000000
00000000666661006d6dd10049494942000000000000000000000000000000001a11aa1100000000000000000000000000000000000000000000000000000000
000000000161110001d1110004949420000000000000000000000000000000000a11aa1100000000000000000000000000000000000000000000000000000000
0000000000d1000000d1000000092000000000000000000000000000000000000011aa0000000000000000000000000000000000000000000000000000000000
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
000600000c0350b1150b1240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040100000d110251102b120131301c13015140161500b15016150141501315012150121401214012140121301213015140161401a1501b1501a150191501a1501a1501c1501c1501a14017120151201413012140
01020000200102201023020230202303006040060501d050130300d03000000000000000000000000000c0300e040170501a05018050140500e0300d02000000220502205012050120500a0500a0500a05000000
010700001301500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700000e01500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700001501500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700001001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001613019620116101e12006610201100261004620046200d60000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200000a1200362017130076200a6200a1100562011110026100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000241501f140191401013009120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
