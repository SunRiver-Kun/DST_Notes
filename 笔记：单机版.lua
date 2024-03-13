#数学
R/G/B = xxx/255
Point(x,y,z)	--> Vector3
inst:GetDistanceSqToInst(otherinst)


#全局
--simutil.lua
GetPlayer()	--> ThePlayer 
GetWorld()	--> TheWorld world.lua	event: phasechange{newphase}
GetCeiling()
GetMap() --> GetWorld().Map
GetClock() --> GetWorld().components.clock
GetNightmareClock() --> GetWorld().components.nightmareclock
GetSeasonManager()  --> GetWorld().components.seasonmanager
GetMoistureManager()  --> GetWorld().components.moisturemanager

TheSim
TheInput
MapLayerManager

#数据获取
GetModConfigData(name)	--modinfo
ModInfoname(name)
GetModConfigData(optionname, modname)	--mods.lua
GetModConfigDataFn(modname)
GetModConfigDataFn(modname)
require(modname: string)	--没有modimport

#添加修改  --modutil.lua
AddClassPostConstruct("widgets/itemtile", fn(inst,args...))
AddComponentPostInit(component, fn)
AddGlobalClassPostConstruct(package, classname, postfn)

AddAction(action)
AddStategraphActionHandler(stategraph, handler)
AddStategraphState(stategraph, state)
AddStategraphEvent(stategraph, event)
AddStategraphPostInit(stategraph, fn)

AddPrefabPostInitAny(fn)	--添加到所有的
AddPlayerPostInit(fn(inst))
AddPrefabPostInit(prefab, fn)
AddGamePostInit(fn)
AddSimPostInit(fn)
AddRoomPreInit(roomname, fn

AddCookerRecipe(cooker, recipe)	--Recipe(...)
AddModCharacter(name)
AddMinimapAtlas( atlaspath )


#调试代码
--只有assert()和error

c_godmode()     
c_pos(inst)     
c_printpos(inst)    
c_give(prfab,count=1)
c_find(prefab, radius=9001, inst=ThePlayer)
c_findnext(prefab, radius=9001, inst=ThePlayer)
c_findtag(tag, radius=9001, inst=ThePlayer)
c_gonext(name)  --c_goto(c_findnext(name))
c_speed(speed)  --设置player移速
c_move(inst=c_sel())    --移动到鼠标位置
c_goto(destinst, inst=ThePlayer)   --移动inst到destinst的位置
c_simphase(phase)   --GetWorld():PushEvent("phasechange", {newphase = phase})
c_anim(animname, loop=false)  --c_sel().AnimState:PlayAnimation(animname, loop)

