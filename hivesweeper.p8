pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
 new_hive(8)
 poke(0x5f2d, 1) --mouse mode
end

function setchr(s,i,c)
 return sub(s,1,i-1)..c..sub(s,i+1)
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
	
	bees_left=bees or sz --add bees to map
	while bees_left>0 do
	 local id=flr(rnd(sz*sz))
	 if beehive[id]=="#" then
	  beehive=setchr(beehive,id,"b")
	  mines[id]=true
	  bees_left-=1
	 end
	end
	revealed={} --cells shown
	for i=1,sz*sz do
	 revealed[i]=false
	end
	flagged={} --cells flagged
	numbers={} --no. of adjacents
	
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
 
 --hive interaction
 selecting=nil
 for i=1,#hives_screen_pos do
  local cell=hives_screen_pos[i]
  if(mx>=cell[1] and mx<cell[1]+8
  and my>=cell[2] and my<cell[2]+8)then
  	selecting=i
  	if(mpressed) and revealed[i]==false then
  	 revealed[i]=true
  	 sfx(2)
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
  if beehive[i]=="b"then
   id=5
  end
  spr(id,cell[1],cell[2])
  //print(beehive[i],cell[1],cell[2],7)
 end
 --highlight selected
 if revealed[selecting]==false then
 	//hilight(hives_screen_pos[selecting])
 	print("\#1"..ceil(selecting/hive_size))
 	local adj=neighbours(selecting)
 	for i=1,#adj do
 	 hilight(hives_screen_pos[adj[i]])
 	end
 end
 
 --draw mouse
 pal(1,0)
 local id=17
 if(mpressed)id=18
 spr(id,mx,my)
 pal()
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
	  end
	 end
	end
	return out
end

--highlight
function hilight(cell)
 spr(3,cell[1],cell[2])
end
__gfx__
00000000000900200001000000000000000000002009002000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009999900011122000a0a0a00007070000999990000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007009999999011222220a07070a0700000709979799000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700099999992112222200707070000aaa0009779779200000000000000000000000000000000000000000000000000000000000000000000000000000000
000770009999999211222220a07070a070aaa0709779779200000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070099999992112222200a070a00000000009979799200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999220122220000a0a000070007000999992500000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000009220000020000000a0000000700002009250000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007d0000007d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077d00000ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077710000ddd1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007777d000ddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077777100ddddd10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000171110001d1110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000d1000000d1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000200900200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000200925000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000101501b000140001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000c01521615216140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050100000d1001011011120131301413015140161501715016150141501315012150121401214012140121301213015140161401a1501b1501a150191501a1501a1501c1501c1501a14017120151201413012140
01020000200102201023020230202303006040060501d050130300d03000000000000000000000000000c0300e040170501a05018050140500e0300d02000000220502205012050120500a0500a0500a05000000
