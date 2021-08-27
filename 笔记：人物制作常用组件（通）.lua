一些特定的函数：
inst.OnSave	--保存函数
inst.OnPreLoad	--预加载函数

控制台命令： --参考代码:mainfunction  cosolecommand   debugcommands(内有debug key快捷键设置)  
c_reset()  --出现加载代码，动画不行
c_save()  --保存
c_spawn("prefab",num or 1)  --local prefab = SpawnPrefab(name,skin,skin_id=nil,creator_id)	prefab.Transform:SetPosition(inst.Transform:GetWorldPosition())
c_give("prefab",num or 1)  -->   player:GiveItem(prefab)	||  player.components.inventory:GiveItem(prefab, nil, pos)
c_select()c_sel():Remove -->   inst:DoTaskInTime(time,inse.Remove)	inst:Remove() <--> inst.Remove(inst)					

组件：
inst.components.xxx  --可以去看官scripts里的xxx.lua
inst:AddComponent(" ")		--标准添加组件，参数是components里面的文件名
inst:RemoveComponent(" ")

信息：
require("scripts/...")  --默认在官方scripts里找
GLOBAL.require("scripts/skills_sollyz.lua")  --默认在本mod里找

modimport("scripts/skills_sollyz.lua") 	--在modmain直接插入代码，和require的调用不同

GetModConfigData("namea")	--得到maininfo里面的configuration_options={ name = “namea”}里的信息的，只能用于modmain,外用可插入全局表
							
--全局表,无法用在AddModRPCHandler里
TUNING{  --游戏数值常量表
	GAMEMODE_STARTING_ITEMS{
		DEFAULT{  --初始化装备的贴图...
			SOLLYZ = { "cane_candycane", "cane_ancient", "cane_victorian","cane_sharp","myprefab" }
		}
		LAVAARENA
		QUAGMIRE
		myprefab =  {atlas = "images/inventoryimages/myprefab.xml", image = "myprefab.tex"}
	}
}  

CONSTANTS  --颜色、输入等常量表
STRINGS  --检查表
PREFAB_SKINS  --皮肤
GROUND  --地板
GLOBAL{ --参考代码：main.lua里的东东都要加GLOBAL才能用。
	ThePlayer
	KnownModIndex{
		IsModEnabled(workshop-number)  --> bool  是否可用，不一样加载了
		GetModsToLoad()  --> table  看具体加载了哪些mods
	}
	
	TheSim{
		:FindFirstEntityWithTag("tag")
		:FindEntities(x,y,z,radius,musttags,notags)
		:GetScreenSize()  --> width,height
		:ReskinEntity( target.GUID, target.skinname, tool._cached_reskinname[prefab_to_skin], nil, tool.parent.userid )
	}
	TheInventory{
		:CheckClientOwnership(player.userid, PREFAB_SKINS[prefabname][index])
	}
	TheWorld{
		GroundCreep{
			:OnCreep(pt)   --> bool  地上有无鸟 
		}
	
		Map{  --y常为0,有时描述地面坐标时会把y看成z; pt可以代替x,y,z  参考代码：components/map.lua   map/terrain
		:IsVisualGroundAtPoint(x, 0, z)		--陆地是可视的，海是不可视的。不过要注意有没有平台
		
		:IsPassableAtPoint(x, y, z)		
		:IsGroundTargetBlocked(x,y,z) 
		:IsAboveGroundAtPoint(x,y,z)
		
		:IsOceanTileAtPoint(x,y,z)
		:IsSurroundedByWater(x, y, z, radius)
		:IsOceanAtPoint(x,y,z)
		:IsPointNearHole(x,y,z) 
		:CanDeployRecipeAtPoint(pt, recipe, rot)   --> bool
		:CanPlacePrefabFilteredAtPoint(x, y, z, prefab)
		:IsFarmableSoilAtPoint(x, y, z)  
		:CanTillSoilAtPoint(x,y,z) --能否填充土壤
		:CollapseSoilAtPoint(x,y,z)  --使土壤营养流失
		:GetPlatformAtPoint(x, z)   -- 常有钓鱼区域判断   TheWorld.Map:IsVisualGroundAtPoint(x, 0, z) or TheWorld.Map:GetPlatformAtPoint(x,z)~=nil
		:GetTileCenterPoint(x,y,z)	--is_on_water = TheWorld.Map:IsOceanTileAtPoint(target_x, 0, target_z) and not TheWorld.Map:IsPassableAtPoint(target_x, 0, target_z)
		:GetTileCoordsAtPoint(x,y,z)
		:GetSize() --w,h，一般等    一块的size,整个地图4x4块  x =[-2w,2w]
		:GetRandomPointsForSite(area.x, area.y, area.poly, 1)  --> table x, table y 
		:GetTile(_left, _top)  --> GROUND.IMPASSABLE  
		:GetEntitiesOnTileAtPoint(x,y,z)
		:CalcPercentOceanTilesAtPoint(x,y,z,r)  --计算百分比
		:SetClearColor(r,g,b,a)  --改变海的颜色,a好像没用。随phase刷新。晚上无光/不在视野内刷新无效   r,g,b,a ~ 0-1
		:SetTile(x, y, ground)  --一般先设置新层。  参考代码：scripts/debugcommands.lua
		:RebuildLayer(ground, x, y)  --再，rebuild旧层和新层
		}

		minimap{  --参考代码：widgets/screen
			MiniMap{
			:IsVisible() 
			:RebuildLayer(ground, x, y)  --小地图直接rebuild旧层和新层
			:ShowArea(x,y,z,r)  
			:EnableFogOfWar(bool)  --一键全图不是？
			:ContinuouslyClearRevealedAreas(bool)  --持续清理探索过的区域。会清空探索过的区域地图
			:SetEffects( shader_filename, fs_shader ) -- 	local shader_filename = "shaders/minimap.ksh"		local fs_shader = "shaders/minimapfs.ksh"		 
		}
	}

}
--debug，可以参考： require "debugcommands"	   "debugkeys"	"consolecommands"
TheInput:IsKeyDown(KEY_LCTRL)
TheInput:GetWorldEntityUnderMouse()
TheWorld 
TheSim
ThePlayer


--打印
GLOBAL.io		os.date("%Y-%m-%d_%H-%M-%S")
client_log.txt  --在这里看print的，不过有其他不想要的数据就是了
for k,v in pairs(ThePlayer.event_listeners) do print(k,v) end --在C:\Users\Administrator.SUNRIVER\Documents\Klei\DoNotStarveTogetherRail\client_log.txt 

-- 各种Make
MakeInventoryFloatable(inst, "med", 0.05, {0.8, 0.4, 0.8}, true, -12, {sym_build = "swap_sr_fishingrod"})--,sym_name = "swap_fishingrod",bank="reskin_tool"})	--可以飘在水上,  参考代码：components/floater.lua
MakeSnowCoveredPristine(inst)	--可被雪覆盖
if not TheWorld.ismastersim then return inst end
MakeHauntableLaunch(inst)		--可被作祟
MakeLargeBurnable(inst)			--自然
MakeMediumPropagator(inst)		--传播？
MakeSnowCoveredPristine(inst)   --被雪覆盖
MakeMediumBurnableCharacter(inst, "torso")	--"torso"是躯干   components.burnable
MakeLargeFreezableCharacter(inst, "torso")  -- components.freezable

--标签	重复添加标签或者删除不存在的标签都没有影响
inst:AddTag("标签名")	--人物制作时目标为
inst:HasTag("标签名")
inst:RemoveTag("标签名")

特殊效果的标签{
	NOBLOCK  NOCLICK   FX  是不能点击的物体
	show_spoilage：显示腐烂时间
	lightningtarget：闪电目标
	electricdamageimmune：电伤害免疫
	irreplaceable：无法替代，玩家离开世界自动掉落
	player、playerghost
}

-----------------------------------------------------------------------------------------------
--RPC(线程完整版):	按键是客机的，反应是在服务器的
--这些都要modimport在modmain里面才可以
--注意：widget的owner是客机的，event也是客机的；主机无法持有wiget；主客机之间只能用 TheNet与网络变量 
AddModRPCHandler("namespace", "light", function(player)		--定义，无法在里面SendModRpcHandler
	
end)

local function IsHUDScreen()	--判断是不是非输入界面,HUD就是screen
	local defaultscreen = false
	if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name and type(TheFrontEnd:GetActiveScreen().name) == "string" and TheFrontEnd:GetActiveScreen().name == "HUD" then
		defaultscreen = true
	end
	return defaultscreen
end
//AddModRPCHandler(modname, "fnname", function(player,...)	
AddPlayerPostInit(function(inst)	--纯发送函数的
	inst:DoTaskInTime(0, function()		--定时任务,必须加上这个
		if inst == GLOBAL.ThePlayer and inst.prefab == "sollyz" then
			 TheInput:AddKeyDownHandler(KEY_H, function()
				local screen = GLOBAL.TheFrontEnd:GetActiveScreen()		--判断
            		local IsHUDActive = screen and screen.name == "HUD"	---是不是
            		if inst:IsValid() and IsHUDActive then				---IsHUDScreen()
						SendModRPCToServer(MOD_RPC[modname][fnname],...)	--给服务器信息
					end
			end)
		end
	end)
end)
-----------------------------------------------------------------------------------------------
--加载材料
local assets = {
	Asset( "SOUND", "sound/wilson.fsb" ),		--声音
	Asset( "ANIM", "anim/sollyz.zip" ),					--加载资源(”类型”, “位置与名字”),
	Asset( "ANIM", "anim/ghost_sollyz_build.zip" ), 
	Asset( "SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset( "ATLAS", "images/inventoryimages/nohat.xml"),	
	Asset( "SHADER", "shaders/minimapfs.ksh"),
}	

return MakePlayerCharacter("人物名称", prefabs, assets, common_postinit, master_postinit, start_inv)	  --返回数据，人物名，通用动作函数，（local）加载，声音与地标，
---------------------------------------------------------------------------------------------------
事件
--参考代码：EntityScript.lua
--函数常数一个是inst,data；不用到data定义时可以省略,data表示那个表		.prefab可以得到预设物名
--对了写函数时要改组件内容一个有个if inst.components.xxx then ... end 不然会报错的！
inst:PushEvent("事件",数据（表）)	--inst为发出者即source
inst:ListenForEvent("事件",函数 ,监视对象)	--监视对象为空则是监视自己
EventHandler("事件",函数) --监视对象默认是自己，常在StateGraph中被使用，用于转换prefab的State
inst:RemoveEventCallback("事件",函数,监视对象)	--有函数名好像就不报错，可在ListenForEvent前使用	

世界{
	玩家：playerexited(服/客),ms_playerleft,ms_newplayerspawned,ms_playerspawn(还没有prefab),ms_playerjoined,playerexited	
	植物：plantkilled,itemplanted
	时间：phase,clocktick
	UI：screenflash
}		
物品：		equipped, unequipped, onremove,  onclose, onopen, worked,ondropped,onpickup,percentusedchange,onlimbo,exitlimbo
建筑:		onbuilt		
人物{
	装备：equip,unequip
	攻击：onhitother(人物攻击),attacked
	物品：dropitem,gotnewitem,itemget,itemlose
	动作：working,finishedwork,picksomething,pickdiseasing,fishingstrain,trade,makerecipe,builditem,startmove,stopmove	
	数值：sanitydelta
	生死：death,killed,ms_becameghost,ms_respawnedfromghost,playeractivated,playerdeactivated,respawnfromghost,usereviver
	其他:firemelt,stopfiremelt
}						
-------------------------------------------------------------------------------------------------
监听世界：注意：src表示source, 
--------！！！！！！ myfn传入的参数(inst/player)必须与:前的名字一致，且定义的时候也是这样 ！！！！！！-------------

1.无法取消，不留接口，有inst无src,data，TheWorld是全局表（TheWorld.state.phase可直接在定义里用）
	myfn = function(inst) if TheWorld.state.phase=="day" then  print(inst) end end 
	inst:ListenForEvent("clocktick",function() myfn(inst) end, TheWorld)	-- 第一个function的参数是world,data，不过一般用不到（直接TheWorld.xxx就得了）
2.可以取消，不留接口，无inst/player有world,data
	myfn = function(src,data) print(data) end 
	inst:ListenForEvent("clocktick",myfn,TheWorld)		--myfn(src,data)  src实际也就是world
	inst:RemoveEventCallback("clocktick",myfn,TheWorld)
3.可以取消，留着接口，有inst(.前面的)有inst,src,data
	inst.myfn = function(src,data)	--只有这个必须这样写
			print(inst)	--注意:前面是inst才能打印出来，如果是player.myfn 的话只能打印player
		end
	inst:ListenForEvent("clocktick",inst.myfn,TheWorld)
	inst:RemoveEventCallback("clocktick",inst.myfn,TheWorld)
	
clocktick(世界时间)：对象TheWorld, data包括:cycle(过来多少天),isday/isdusk/isnight/iscaveday... 

inst:WatchWorldState("israining", function(inst) fn(inst) end)	--监视世界的更好办法
inst:WatchWorldState("phase", fn )	--fn的常数是inst
															
-------------------------------------------------------------------------------------------------
播放声音:
inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")	--”里面是路径”

计算：  mathutil.lua
--lua里^是幂，没有整数相除
*math{
	pi、huge
	max(a,b)
	min(a,b)	

	ceil(x)	 --向上取整
	floor(x)  --向下取整
	
	sin(x)	
	cos(x)
	tan(x)
	
	asin(x)  
	acos(x)
	atan(x)  --arctan(x)
	atan2(y,x)	--arctan(y/x)

	sinh(x)
	cosh(x)
	tanh(x)

	log(x)  --ln(x)
	log10(x)	--lg(x)	
	exp(x)	
	pow(x,y)  --Lua中可以直接x^y	

	randomseed(seed)  --set seed:number	
	random(a,b)  --如果a=b=nil,返回0-1的浮点数。否则返回a~b的整数	
		
	ldexp(x,y)  --return x*2^y	
	frexp(x)  --return m,y.  m*2^y = x	
	
	abs(x)
	sqrt(x)	
	
	fmod(a,b)  --返回a/b的余数。 while(a>b){a-=b;} return a; 	
	modf(x)  --返回	整数部分,小数部分
	
	deg(x)	 --return 180 * x / math.pi	
	rad(angle)  --return math.pi * angle/180	
	--饥荒追加
	clamp(num, min, max)    
}

*string{		--用 [[  ]]可返回生字符串，用..连接字符串与数字.
	--都是返回copy的string
	find(string,pattern)  --return from,to
	match(string,pattern[,from])	-->string | nil
	gmatch(string,pattern)  -->function, fuction()返回符合pattern的下一个子串或nil		for word in string.gmatch("Hello Lua user", "%a+") do print(word) end
	--[[
		格式：特殊字符包括 ^$()%.[]*+-? 
		%d,%x,%w  --单个数字，十六进数字，字母/数字
		%u,%l,$u  --大写，小写，空白字符
		%a,%c,%p,%w  --任意字母，控制字符(\n等)，标点,字母/数字
		. , %z    --任意字符，任意代表0的字符
		%特殊字符  --转义
		[]、[^]、^、$、()、*、+、?、. 同正则，  - 表示尽可能短，取代了正则的?x中的?
		%b()、%b[]、$b{}	--匹配括号
		%n	--第n个捕获物之后的子串
	]]	
	format("the value is %d",arg1,...)  -->string  同C的,追加：
	-- %q - 接受一个字符串并将其转化为可安全被Lua编译器读入的格式.如："%q","One\nTwo" 返回字符串 \"One\\换行Two\"
	-- %02d  - 表示占2位，前面补0或无效
	rep(string,n)  -->string  string..string.. 共n个string
	gsub(str,findstr,repstr[,num])  	
	len(str)  -->number	
	reverse(str) -->string	
	byte(string,from=1,to=1)  --字符转ASCII	
	char(number[,number2,...])	-->string ASCII转字符串	
	upper(str)	-->string
	lower(str)	-->string
	sub(string,from[,to])  -->string  from、to可以为负数(-10,-1)，表示从后面开始	
}

io{
	stdin、stdout、stderr : file	--userdata
	tmpfile()  -->file ，程序关闭删除临时文件
	lines(filename[,"format"]) --> function,  function()返回  strline或按格式返回		
	open(filename,mode)  -->file|nil [,errorstr]
	input(filename)	  -->file 只读
	output(filename)	-->file 只写
	--file
	:read(...)
	:write(...)	
	:flush()	
	:close()	
	:type()	
	
}

debug{
	debug()	--进入命令行模式
	setupvalue(f,upindex,value)  --> return upvalue_name or nil.   upvalue为f中调用的local全局变量出现的次序(1~huge)	
	getupvalue(f,upindex)	--> return upvalue_name,value or nil,nil

	getregistry() --> table{ ["FILE*"] = {} , _LOADED = {io,os,table,math,coroutine等}, _LOADLIB = {__gc:funcion}, _PRELOAD = {ffi:function} } 	
	traceback([thread,][,message[,level]])  -->string.  	
	getinfo([thread,]fn[,mode])	--> table, 返回函数信息，参数格式，书写位置，来源，是否参有...等，不过饥荒里的有些数据没有	
	--mode："S".what = C/main/?		"f".func	"n".namewhat
	
	setlocal(thread,level,local,value)	
	getlocal(thread,f,local)

	sethook(thread,hook,mask[,count])	-- mask='c'(每调用一个函数),'r'(每函数返回),'l'(每行). hook = function(str,line=nil(只有'l'时才有)) str="call","return","line"	
	gethook(thread) --> hook:function,mask:string,count:number	
	getmetatable(object)  --> table|nil 	注：_G.getmetatable ~= debug.getmetatable	
	setmetatable(object,table=nil)	-->设置userdata(或其他)的metatable.  5.2追加返回object
	setfenv(object,table)  --设置object的环境
	getfenv(object)  --返回object的环境  5.2弃用(deprecated)
	--饥荒追加
	getsize()
	
	--5.2
	setuservalue(userdata,table=nil)  -->return userdata. 设置userdata的metatable
	getuservalue(userdata)	--> return getmetatable(userdata)
	upvalueid(f,n)	--> userdata,常用来判断是否两函数同用个upvalue.	 ok = userdata1==userdata2
	upvaluejoin(f1,n1,f2,n2)  --让f1引用f2的upvalue	
}

os{
	execute(command:string)  --> bool[,string,number]   相对于C的system	
	exit(number)  --相对于C的exit(number).   Lua5.2, (number|bool[,close])	true/false -> SUCCESS/FAILURE, close:true-> close lua state before exiting
	setlocale(locale:string[,catagory:string])  --> name:string or nil.  locale="C"   catagory="all","time","numberic","ctype"等等	
	getenv(varname)  --> string or nil. varname不区分大小写：
	 --[[  varname 不区分大小写
		OS		操作系统的名称
		COMPUTERNAME	计算机的名称
		SystemRoot	系统根目录
		SYSTEMDRIVE		系统根目录的驱动器
		
		ALLUSERSPROFILE		所有“用户配置文件”的位置

		COMSPEC		命令行解释器可执行程序(CMD)的绝对路径
		
		HOMEDRIVE	连接到用户主目录的本地工作站驱动器号
		HOMEPATH	用户主目录的完整路径，无C:

		NUMBER_OF_PROCESSORS	安装在计算机上的处理器的数目
		PROCESSOR_LEVEL		计算机上安装的处理器的型号
		PROCESSOR_REVISION		处理器修订号的系统变量

		PATHEXT		连接到用户主目录的本地工作站驱动器号		
		TEMP		临时目录
	]]	
		
	clock()  --> sec:number. 返回大概CPU使用在本程序的时间，不是很准确而且会无效
	time(table=nil)  --> sec:number.  	table{	year,month,day = ... , hour=12,min=0,sec=0,isdst=nil} 只有year,month,day是必须的
	difftime(time1,time2)	--> 相差的秒数 return time1-time2(WINDOW/POSIX)
	date([format:string[,time:number]])	--> stirng or table. 全空->当前时间的str.  format: "*t"(return table), "%c"(locale格式)
	tmpname()	--> filename.   have to open and remove it, even if we don't use it!
	rename(oldname,newname)	 --> bool[,string,number].  rename file or directory of oldname to newname
	remove(filename)  -->bool[,string,number]
}

协程：Lua里没线程，不过可以把函数拆成几部分运行
coroutine{
	creat(fn) -->thread
	resume(fn,...)  -->true,...  |   false,strerror. start with ... or restart with old paragms/environment
	yield(...)  --挂起suspended. ...将作为resume的第二参数返回。其参数下次继续用.当然也可以写在非thread函数中，然后在thread中调用该函数
	running()  -->thread,bool.  返回真正运行的thread，bool为true表示主协程
	wrap(fn)  --> fuction, 创建个thread，每次调用function相对于resume，返回fn的结果或报错
	status(co:thread)  -->string: dead，suspended(挂起/未运行)，running,nomal(内部调用其他thread)
}

userdata: 一般是C/C++的数据类型
newproxy(bool|proxy) -->Creates a blank userdata with(bool)without an empty metatable,
 					 --or with the metatable of another proxy

表：
--index = number/string
--t[key]、t.str
--table[key]: key可以为非nil的任意类型！
--for k,v in pairs(table) do ... end   ipair只遍历num
--#table  最后的index(只记number的)
--[[
	metatable={
		--5.1
		__index = function(t,k)  end  or  table --table[k]时调用
		__nexindex = fuction(t,k,v)  end  --table[new_k]时调用
		__len = function(t) return length end  --返回#table的值 
		__call = function(t,...)  end	-- table(...)时调用此函数
		__tostring = function(t) return "string"  end  -- print(t)时调用
		__add = function(t1,t2) end  -- t1 + t2 时调用
		同上的还有，__sub(-)、__mul(*)、__div(/)、__mod(%)、__unm(-)、__concat(..)、__eq(==)、__lt(<)、__le(<=)
		__metatable = {...}  --调用 getmetatable时返回该值，无则返回metatable(大多数情况)
		--5.2
		__gc = function(t) ... end  --析构函数. 在5.1可以local proxy = newproxy(true)   getmetatable(proxy).__gc = function(t) ... end
	}
	
]]
*table
table.insert(name,[index,]value)
table.remove(table,index=#table)	--> 返回被删除的元素值
table.maxn(table) --最大的数字index
table.concat(table,seq="",begin=1,end=#table)  --table全是字符串或数字， table[1]..seq..table[2]...seq...table[end]
table.pack(...) --> table
table.unpack(table) --> table[1],..,table[#table]
table.sort(table,[function(a,b) return a<b end])
next(table,[index=initial index])  --> next_index,table[next_index]

rawget(table,index)  --get table.index. don't call any metatable 
rawset(table,index,value)
rawequal(a,b)
rawlen(table|string) --> return #table(number)、the length of string

setmetatable(table,metatable=nil) 
getmetatable(table)  -- nil or metatable or metatable.__metatable. 所以不一定是table or nil

getfenv(f)  --> table. f=function|number    num=1,call args.  num=0,global
setfenv(f,table)  --> f=function|number

pack(...) --> table
unpack(table) -->...
select(index,...) --> index=-1最后一个， or 第index个及以后的.	 print( select(1,1,2,3,4,5,6,7,8,9)) --return 1,..,9

*tostring(v)
*type(v) -- return string.  "number"、"string"、"table"、"userdata"、"boolean"、"function"、"nil"
*pairs/ipairs/
tonumber(v)


assert(bool,...) --> true return ..., false error
error(message,[level=1])  --终止最后一个protected function and return message
xpcall(f,msgh~=nil,...)  --safe mode call f. success: return true,f(...)  failure:false, msgh(error)
pcall(f,...) --safe mode call f. success:return true,f(...)  failure: return nil,errorstring
module(name[,...]) --name:string   package or global里叫name的table is a module. 及之后只能使用module里的成员

*require(modname) --在package.loaded里找，不见在 package.path里找	cpath里是dll等
load(ld:func|str[,source:string,mode:string,env:table]) --return function,errorstring; 
loadfile(filename[,mode:string[,env:table]])  --return function,errorstring; 
loadstring(filename[,chunkname]) --return function,errorstring;   assert(loadstring(string))() --safe ok
dofile(filnename)  -->...   not safe call. filename=nil then return the values of stdin

--newproxy、gcinfo
type_table: math、table、io、os、string、debug、arg(main函数参数)、jit(即使编译)、bit(位运算函数)、package(加载路径等)、_G
value: _VERSION   --饥荒是 Lua 5.1
_G：global table，以上都是for k,v in pairs(_G) do print(k,v) end

说话（较短的，不是检查）：
GetString(inst, "ANNOUNCE_KILLEDPLANT")		--可以返回speech里对应的字符串，可以是个{}里的随机
inst.components.talker:Say("Level : ".. (inst.level))	--“..”是字符串连接符
TheNet:Say(str)  --服主说话

声音名字设置：
inst.soundsname = "willow"	--薇洛

地图标志：
inst.MiniMapEntity:SetIcon( "sollyz.tex" )	--”文件名”一般把地图标志放在images/map_icons

人物基本属性设置：
inst.components.hunger.max=
inst.components.health.maxhealth =
inst.components.sanity.max =
inst.components.locomotor.walkspeed =	
inst.components.locomotor.runspeed=
--inst.components.eater:SetOnEatFn(函数名)		如果吃东西有效果就加，没有就忽略

--计时，参考代码：entityscript.lua
inst:DoPeriodicTask(time, fn, initialdelay, ...)
inst:DoTaskInTime(time, fn, ...)
--组件 
--ctor 里调用后来定义的函数，用self.xxx
function OnLoad(data) {...}
function OnSave() {return {} }
--StaticComponentUpdates  RegisterStaticComponentUpdate(classname, fn)
function OnUpdate()

RegisterStaticComponentLongUpdate(classname, fn)  --独立线，换世界等长时间时的
function OnWallUpdate(){}	--独立线

		StaticComponentLongUpdates
