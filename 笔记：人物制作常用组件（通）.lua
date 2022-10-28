entityscript:
OnSave(self, data)
OnPreLoad(data, newents)
OnLoad(data, newents)
OnLongUpdate(dt)
OnLoadPostPass(newents, savedata)
OnBuiltFn(builder)
OnRemoveEntity()

player:  --player_common.lua
master_postinit()  -->  这里可以直接写的有OnNewSpawn、OnPreLoad、OnLoad、OnSave、OnDespawn，而OnSleepIn和OnWakeUp用DoTaskInTime改

inst.OnSleepIn = OnSleepIn
inst.OnWakeUp = OnWakeUp

inst._OnSave = inst.OnSave
inst._OnPreLoad = inst.OnPreLoad
inst._OnLoad = inst.OnLoad
inst._OnNewSpawn = inst.OnNewSpawn
inst._OnDespawn = inst.OnDespawn
inst.OnSave = OnSave
inst.OnPreLoad = OnPreLoad
inst.OnLoad = OnLoad
inst.OnNewSpawn = OnNewSpawn
inst.OnDespawn = OnDespawn

components:
OnSave()
OnPreLoad()
OnLoad(data)
OnBuilt(builder)
OnRemoveEntity()
OnUsedAsItem(action, doer, target)
OnLoadPostPass(newents, savedata)
OnLoad(data, newents)
LongUpdate(dt)
--update.lua
--StaticComponentUpdates  
OnUpdate()
--RegisterStaticComponentLongUpdate(classname, fn)  --独立线，换世界等长时间时的
OnWallUpdate()	--独立线


网络：netvar    SendModRpcHandler/AddModRPCHandler
网络通信好像就这两个，在组件里面是会自动找 _replica的，而这里面是处理netvar数据的

steam DST Tool自动打包：有修改重新生成
.png文件 -> tex, xml	
exported -> 里面是一个个动画文件夹，每个文件夹包含贴图和scml，自动打包成放到anim文件夹内(没创建文件夹自动创建)



控制台命令： --参考代码:mainfunction  cosolecommand   debugcommands(内有debug key快捷键设置)  
c_reset()  --出现加载代码，动画不行
c_save()  --保存
c_spawn("prefab",num or 1)  --local prefab = SpawnPrefab(name,skin,skin_id=nil,creator_id)	prefab.Transform:SetPosition(inst.Transform:GetWorldPosition())
c_give("prefab",num or 1)  -->   player:GiveItem(prefab)	||  player.components.inventory:GiveItem(prefab, nil, pos)
c_select():Remove() -->   inst:DoTaskInTime(time,inse.Remove)	inst:Remove() <--> inst.Remove(inst)					
c_remote(fnstr)
c_despawn(player=ThePlayer) -->重新选人

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
	TheWorld{	--world.lua		worldstate.lua
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

		minimap{  --参考代码：widgets/screen	mapscreen   maowidget
			MiniMap{
			:IsVisible() 
			:RebuildLayer(ground, x, y)  --小地图直接rebuild旧层和新层
			:ShowArea(x,y,z,r)  
			:EnableFogOfWar(bool)  --一键全图不是？
			:ContinuouslyClearRevealedAreas(bool)  --持续清理探索过的区域。会清空探索过的区域地图
			:SetEffects( shader_filename, fs_shader ) -- 	local shader_filename = "shaders/minimap.ksh"		local fs_shader = "shaders/minimapfs.ksh"		 
			:WorldPosToMapPos(x,y,z)
			:MapPosToWorldPos(x,y,z)	--MapScreen:GetCursorPosition()
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

-- 各种Make		standardcomponents.lua
MakeInventoryFloatable(inst, "med", 0.05, {0.8, 0.4, 0.8}, true, -12, {sym_build = "swap_sr_fishingrod"})--,sym_name = "swap_fishingrod",bank="reskin_tool"})	--可以飘在水上,  参考代码：components/floater.lua
MakeSnowCoveredPristine(inst)	--可被雪覆盖
if not TheWorld.ismastersim then return inst end
MakeHauntableLaunch(inst)		--可被作祟
MakeHauntableLaunchAndPerish(inst)	--可被作祟和腐败
MakeLargeBurnable(inst)			--可烧
MakeMediumPropagator(inst)		--火焰传播，和Burnable一起出现
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
	时间：phase,clocktick	--worldstate.lua
	UI：screenflash
	是否在洞穴：TheWorld:HasTag("cave")
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

说话（较短的，不是检查）：
GetString(inst, "ANNOUNCE_KILLEDPLANT")		--可以返回speech里对应的字符串，可以是个{}里的随机
inst.components.talker:Say("Level : ".. (inst.level))	--“..”是字符串连接符
TheNet:Say(str)  --服主说话

声音名字设置：	--SGwilson.lua  soundsname or prefab
inst.soundsname = "willow"	--薇洛

地图标志：
inst.MiniMapEntity:SetIcon( "sollyz.tex" )	--”文件名”一般把地图标志放在images/map_icons

人物动画
inst.customidleanim = "idle_webber"

人物基本属性设置：
inst.components.hunger.max=
inst.components.health.maxhealth =
inst.components.sanity.max =
inst.components.locomotor.walkspeed =	
inst.components.locomotor.runspeed=
--inst.components.eater:SetOnEatFn(函数名)		如果吃东西有效果就加，没有就忽略

计时：参考代码：entityscript.lua
--Delay one frame	task::Cancel()	
inst:DoPeriodicTask(time, fn, initialdelay, ...)	--间隔时间，fn，初始延迟
inst:DoTaskInTime(time, fn, ...)	--秒
inst:DoStaticTaskInTime(time, fn, ...)	--世界暂停时继续更新
inst:DoStaticPeriodicTask(time, fn, initialdelay, ...)	--世界暂停时继续更新
inst:CancelAllPendingTasks()	--取消上面所以的定时任务

大小：
modicon: 128x128
inventoryimage: 64x64
screen: 1280x720


跳转世界：
重新生成prefab，但是upvalue不变，当心！


保存和加载
inst.persists = false	--不自动保存数据
OnSave() -> ghost = self.ghost ~= nil and self.ghost:GetSaveRecord() or nil
OnLoad(data) -> ghost = SpawnSaveRecord(data.ghost)		
--util, mainfunction.lua
























