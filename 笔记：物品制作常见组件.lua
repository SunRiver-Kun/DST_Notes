一键GLOBAL:		GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

常见判断{
	--没死
	not (inst.components.health:IsDead() or inst:HasTag("playerghost"))
	--实体可见
	inst.entity:IsVisible()
	--在有效地面上
	inst:IsOnValidGround()
	--联通且不被阻拦
	TheWorld.Map:IsPassableAtPoint(pos:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pos) 
	--是否主机
	if not TheNet:GetIsServer() then return end
}
搜索{
	FindWalkableOffset(pt, theta, radius, 12, true)		--pos表，角度范围，半径，
	TheSim{
		:FindFirstEntityWithTag("tag")
		:FindEntities(x,y,z,radius,musttags,notags)
	}
}

--------------------------------------------------------------------------------------------------
初始化
--参考代码： modutil.lua   entityscript.lua    entityreplica
--modutil中env.postinitfns.XXX，在mods.lua中 ModManager:GetPostInitData("XX", key)
--不想要的直接覆盖掉，或者保存到另一个函数备用，可以在modmain外面用但必须modimport在modmain到里 
AddPrefabPostInit("prefabsname",function(inst) end)	--函数的参数只有inst，表示这个物品；使用API无法修改目标文件的局部函数，局部定义
AddPlayerPostInit(fn)  --初始化客机玩家，可用GLOBAL.ThePlayer  fn参数为inst
AddComponentPostInit(component, postfn) --components（组建）修改,postfn的参数是(self)
AddComponentAction(typename, component, fn)	--fn参数是component除self后的参数+自己定义的参数
AddReplicableComponent("组件名")	--设置replica
AddStategraphPostInit(stategraph, postfn) --SG修改（联机版要对wilson和wilson_cient两个sg都进行state绑定）,状态图（动作）,设置动作触发时播放的动画等 actionhandler，
AddClassPostConstruct(class,postfn(self)) --普通class修改，注意逗号	playerhud  controls  修改UI用到
AddGlobalClassPostConstruct(GlobalClass, classname, postfn) --全局的class修改
AddBrainPostInit(brain, fn)  
AddSimPostInit(函数名)	--添加到世界诞生目录
AddSkinnableCharacter(prefab)
AddGameMode()
AddGamePostInit()
AddRoomPreInit(name,function(room) end)
AddTaskPreInit()  

注意：大部分初始化只在主机上!  TheNet:GetIsServer()  或者直接用 inst:ListenForEvent 也可以
if not TheWorld.ismastersim	then	return inst end --一般写在prefabs里的,TheWorld在modmain里面好像不加载

AddPrefabPostInit('axe', function(inst) 
	if not TheNet:GetIsServer() then return end 
	inst:AddComponent('tradable') 
	...
 end) 
-----------------------------------------------------------------------------------------------
物品： 
--	代码参考：recipe.lua  recipes.lua  recipes_filter.lua
first：	GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end}) 
																--CHARACTER_INGREDIENT.SANITY/HEALTH
[1] local myprefab = AddRecipe("prefabname or sanity与health", {Ingredient("材料物品代码名", 数量, new_atlas.xml),...}, RECIPETABS.（物品栏编号）, TECH.科技编号 , 
isneedplayer,mininterval,isneedlock,num,tag,"xml","tex",testfn)		--返回一个recipe表，内含sortkey ,最后两个参数可省略,testfn是检测函数，满足才能建立  
--是否有placer  最小间隔  科技锁(远离无法制作)  制作的数量（改成2就可以一次做两个） 需要的标签（比如女武神的配方需要女武神的自有标签才可以看得到）  填nil也可
--物品栏编号：RECIPETABS.（TOOLS LIGHT SURVIVAL FARM SCIENCE WAR TOWN SEAFARING REFINE MAGIC DRESS ANCIENT FISHING）  
--科技编号：TECH.NONE TECH.SCIENCE_ONE TECH.SEAFARING_TWO
[2] myprefab.sortkey = AllRecipes["物品代码名（可c_give那个）"].sortkey + 1	
[3]设置独有的制作栏(也是写在modmain里的)
例子：Asset( "IMAGE", "images/sollyztab.tex" ),-------------------------专属科技图片
    Asset( "ATLAS", "images/sollyztab.xml" )
SollyzTab = AddRecipeTab(STRINGS.SOLLYZ,234(还是511不清楚), "images/sollyztab.xml", "sollyztab.tex", "tag")
--AddRecipe(...,SollyzTab,THCH.SCIENCE_TWO,...)
AddRecipe2(name, ingredients, tech, config, filters)
AddCharacterRecipe(name, ingredients, tech, config, extra_filters)
[4]地图图标 
AddMinimapAtlas("images/map_icons/photon_cannon.xml")
[5]设置placer，一般写在最后的return inst 上面
MakePlacer(name, bank, build, anim, onground, snap, metersnap, scale, fixedcameraoffset, facing, postinit_fn)
--name一般取prefab_placer,		是否在地面(t/f),nil,与墙有关(nil),缩放比例,固定偏移,朝向(在AnimState里也要调)									
 -----------------------------------------------------------------------------------------------
护甲与武器:
 --  代码参考：armor.lua  armor_wood.lua  ||  weapon.lua   nightstick.lua  ||combat ||dragonskin
 
inst:AddComponent("armor")	--防御组件	,添加耐久和吸收伤害百分
inst.components.armor:InitCondition(2*TUNING.ARMOR_FOOTBALLHAT, TUNING.body_power*TUNING.ARMOR_FOOTBALLHAT_ABSORPTION/--8)

inst.components.equippable.dapperness = TUNING.head_power	--设置回san值
owner.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.tail_power, nil)		--设置百分比伤害加成，与大力士本身的伤害加成不冲突
--SetModifier用于components里有SourceModifierList的地方，参数(inst/owner,value,tag)

 装备:
 --  代码参考：equippable.lua  inventory.lua
 EQUIPSLOTS.HANDS
 EQUIPSLOTS.HEAD	
 EQUIPSLOTS.BODY
if player.components.inventory.euipslots then instname = player.components.inventory.euipslots.hands/head/body end
if inst.replica.inventory ~= nil and inst.replica.inventory:EquipHasTag("golden_hat_mk") then end  --客户端
--------------------------------------------------------------------------------------------------

-- 建立一个物品
--UI原点在左下，右x上y
--世界坐标系，原点地图中心，右手系
----------------------------Entity组件，必须下在network上面的
参考代码： mainfunctions.lua    entityscript.lua    prefabs.lua

local inst = CreateEntity()
-- for k,v in pairs(getmetatable(ThePlayer.AnimState).__index) do print(k,v) end
Transform：变换组件，控制Entity的位置、方向、缩放等等	
--[[  														   y
	位置:	y是高，常为0										| 	
	inst.Transform:GetWorldPosition()	--返回x,y,z			   /.->x    右手系（OpenGL ?）
															  z \θ		
   local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))	--封装成3维矢量(x,y,z),x,0,z, angle
   local spawn_point = pt + offset	--矢量坐标相加
   player:GetDistanceSqToPoint(x, y, z) < 4 	--玩家距离一点的距离的平方（有Sq的，基本是距离的平方）

	inst:GetPosition():Get()	--inst:GetPosition()返回对象Vector3，后面加入的:Get()可以获取x,y,z
	inst.Transform:GetPredictionPosition()		--得到客机预判的x,y,z，减低网络延迟影响
	inst.Transform:GetLocalPosition()			--对Entity来说和GetWorldPosition没有区别。但实体不止可以表示Entity，也可以表示UI组件。这个方法一般是用在UI组件上
	inst.Transform:SetPosition(x, y, z)	--设置位置

	角度：-180° ~ 180° ， 超过会自动转换
	inst.Transform:GetRotation()
	inst.Transform:SetPosition(degree)

	缩放:默认为1,1,1； x,y决定缩放比例，z与x,y的比决定左右、上下方向的速度
	inst.Transform:GetScale()
	inst.Transform:SetScale(x, y, z)

	face: 设置动画时脸的朝向
	inst.Transform:SetNoFaced() --设置无面，始终只有一个动画形态
	inst.Transform:SetTwoFaced() --2面，只有下、右
	inst.Transform:SetFourFaced() --4面，上下左右
	inst.Transform:SetSixFaced() --6面，上下左右+左下、右上
	inst.Transform:SetEightFaced() --8面，上下左右+四个斜向]]
AnimState：动画组件，控制Entity的, 动画播完了不会自己移除的
--[[ 
	
	--设置build,bank  需要重新开服
	build.bin{	Build	引用scml名，描述图片信息
		name = scmlname.scml
		Symbol={
			name = filename,
			Frame = {
				framenum = 0, 
				duration = 1,
				image = filename-0,
				w, h,	--图片实际大小
				x,  --pivot_x = 0.5-x/w 	x = (0.5-pivot_x)*w
				y	--pivot_y = 0.5-y/h		y = (0.5-pivot_y)*h
			}
		}
	}
	atlas-0.tex  纯粹的一张图片。可以转png改了再转回来
	anim.bin{	Animas	索引build中的图，制作动画
		anim={
			name = idle,
			root = foldername,
			numframes = length,
			framerate = 40,
			frame = {
				idx = 0,	--time
				w, h,	--不是图片实际大小 
				x, y	--当位置在0,0时和build.bin中x,y同
				element = {
					name = ,
					layername = ,
					frame = 0,  --对应build中的framenum?
					z_index = 1,
					m_a,m_b,m_c,m_d,
					m_tx = 0,
					m_ty = 0
				}
			}
		}
	}
	inst.AnimState:SetBuild("scmlname") --scml名字自动打包成同名zip，同时也是这个参数
	inst.AnimState:SetBank("entityname")  --对应sprite里右下角的第一层名字
	inst.AnimState:PlayAnimation("idle")	--第一个参数是动画名，对应sprite里右下角的第二层名字；第二个是否重复播放(默认为false)
	inst.AnimState:AddOverrideBuild("player_hit_darkness")	--添加格外的动画scml
	sprite左边的x，y对应物体的坐标。改变图片的轴点，再把其x，y改回去，就可以在同一个地方显示。而旋转直接改变angle就行。

	inst.AnimState:GetBuild()  -->string

	--设置颜色(红绿蓝透) 范围0~1，即x/255	rgb对照表：https://tool.oschina.net/commons?type=3
	inst.AnimState:SetMultColour(r, g, b, l)	
	inst.AnimState:SetAddColour(r, g, b, l)	

	--设置bloom（开花）？
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:ClearBloomEffectHandle()


	--高级设置
	inst.AnimState:SetLayer(LAYER_WORLD)	--LAYER_BACKGROUND(人物后面),设置层级，会影响到多个物体重叠时的动画呈现（谁在最前面）
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)	--设置朝向，在设置Entity紧贴地面时会很有用，比如农场，池塘都是紧贴地面
	inst.AnimState:SetSortOrder(3)	--设置排序顺序，在层级相同时有影响
	inst.AnimState:SetFinalOffset(偏移值)	--一般只用到上面3个,1~3

	--播放/暂停/刷新动画
	inst.AnimState:PlayAnimation(anim)	--第一个参数是动画名，第二个是否重复播放(默认为false)
	inst.AnimState:PushAnimation("idle")	--play是直接打断来播放，push是等上一个放完了再放，参数同上play，一般是第一个是play后面都是push
 	inst.AnimState:SetBankAndPlayAnimation(bank, anim)

	inst.AnimState:Pause()
	inst.AnimState:Resume()

	--替换贴图、皮肤，小心重置   prefabskin.lua  skinsutils.lua   skinprefabs.lua  skin_assets
	inst.GUID
 	--一般只有物品有下面这两个
 	inst.skinname  
	inst:GetSkinBuild() 
	--prefabskin.lua	skinner.lua		skinprefabs.lua		CreatePrefabSkin()
	inst.AnimState:SetSkin(build_name, def_build)  --defualt_bulid，只能设置成自己有的皮肤。注意: willow_none的皮肤参数应该是 willow

	--自动打包生成在exported下的zip中的build.xml中有Symbol.name是foldername
	inst.AnimState:OverrideSymbol("symbol_old", "buildname", "symbol")	-- Symbol一般是文件夹名字，build一般是scaml名字
	inst.AnimState:ClearOverrideSymbol("swap_object")	--因为常替换的是人物的，所以写在物品的unequip时用owner代替inst，只有body需要这个
	inst.AnimState:OverrideItemSkinSymbol("swap_spear", old_skin_build, sym_name, inst.GUID, sym_build)  --换官方皮肤. sym_name一般等于sym_bulid  swap_prefab
	TheSim:ReskinEntity( target.GUID, target.skinname, re_skinname, nil, player.userid )  --只能根据player来换皮肤
	
	常见symbol:	{  文件夹名?x
		swap_spear：floater里用到，漂浮
		swap_hat：戴帽子
		swap_object：手上的物品
	}

	--展示/隐藏部位	大小写不敏感
	inst.AnimState:Show("ARM_carry")
	inst.AnimState:Hide("ARM_normal")

	inst.AnimState:Hide("back")
	inst.AnimState:Hide("front")

	--设置动画退出时间
	inst.AnimState:SetTime(94 * FRAMES)

	--判断动画时间
	inst.AnimState:IsCurrentAnimation("idle")
	inst.AnimState:GetCurrentAnimationLength()

	--暂停时继续播放
	inst.AnimState:AnimateWhilePaused(true)

	--SG 动画正常结束？
	inst.AnimState:AnimDone()

	--常用监视事件
	inst:ListenForEvent("animover", inst.Remove)	--动画放完会有个animover事件，当前动画播放完就移除它
	inst:ListenForEvent("animqueueover", inst.Remove)		--一个列表的动画播放完就移除它 ]]
Phiysics：物理组件，控制Entity的物理行为，比如速度，碰撞类型等等。下面这些不能同时对一个实体里使用	--standardcomponents.lua
--[[
	参考代码：standardcomponents.lua  
	1.物品栏物品（各种可以放进物品栏的小物品）
	MakeInventoryPhysics(inst)
	特点：可以通过inst.Physics:SetVel(x,y,z)来提供初速度，并且遵循重力、摩擦、碰撞等物理规律。

	2.人物角色（人物，行走的生物）
	MakeCharacterPhysics(inst, mass, rad)
	其中，mass为质量，rad为碰撞半径，下面类似参数名也有同样含义。
	特点：无视摩擦力，无法越过障碍物（小型：浆果丛，一般：池塘、围墙）

	3.飞行生物（蚊子，蜜蜂）
	MakeFlyingCharacterPhysics(inst, mass, rad)
	特点：类似人物角色，但可以越过像池塘、浆果丛这样的障碍物。

	4.极小飞行生物（蝴蝶）
	MakeTinyFlyingCharacterPhysics(inst, mass, rad)
	特点：类似飞行生物，但不会和飞行生物发生碰撞（很多蝴蝶可以在同一个位置重叠，而蜜蜂不行）

	5.巨型生物（各大BOSS）
	MakeGiantCharacterPhysics(inst, mass, rad)
	特点：类似人物角色，但会越过浆果丛等小型障碍物。

	6.飞行巨型生物（龙蝇，蜂后）
	MakeFlyingGiantCharacterPhysics(inst, mass, rad)
	特点：类似巨型生物，但可以越过池塘这样的一般障碍物

	7.幽灵（阿比盖尔，蝙蝠，格罗姆，幽灵，玩家的灵魂）
	MakeGhostPhysics(inst, mass, rad)
	特点：类似人物角色，但无视障碍物

	8.障碍物（围墙，各种建筑，猪王等等）
	MakeObstaclePhysics(inst, rad, height)
	特点：无

	9.小型障碍物（浆果丛，尸骨）
	MakeObstaclePhysics(inst, rad, height)
	特点：无

	10.重型障碍物（各种可以背的石块）
	MakeHeavyObstaclePhysics(inst, rad, height)
	特点：类似障碍物，需要结合组件heavyobstaclephysics使用

	小型重型障碍物（knighthead，bishophead，rooknose）
	MakeSmallHeavyObstaclePhysics(inst, rad, height)
	特点：类似小型障碍物，需要结合组件heavyobstaclephysics使用

	通用的：
		inst.entity:SetPristine()	--物品初始化

	RemovePhysicsColliders(inst)	--无视碰撞,移除所有碰撞效果，自由穿梭

	inst.Physics:SetDontRemoveOnSleep(true)

	inst.Physics:Stop()	--停止运动,会将实体的速度设为0
	inst.Physics:SetMotorVel(x,y,z)		--设置各方向的初速度,该方法只对人物、生物类型有效。如果是延当前发现的话，y,z设置为0
	inst.Physics:GetMotorVel()	--获取实体的当前速度

	inst.Physics:Teleport(x, y, z)
	inst.Physics:SetVel(x,y,z)	--设置初速度，针对物品栏的物品，坐标系和世界坐标系对应,物品栏物品的运动会受到重力、摩擦力、弹力等影 ]]
Light：光照组件，添加该组件可使得Entity成为一个光源
--[[
	inst.entity:AddLight()
		inst.Light:SetRadius(6)	--设置半径,过低会被查理打，
		inst.Light:SetFalloff(.6)	--设置衰减强度0~1,
		inst.Light:SetIntensity(0.6)  --设计强度0~1,越接近1光线越集中于中心	
		inst.Light:SetColour(234/255,234/255,234/255)  --设计颜色,红绿蓝
		inst.Light:Enable(false)

	inst.Light:IsEnabled() --> bool	
	inst.Light:GetRadius() 		--可以获取半径		
	inst.Light:GetFalloff()		--可以获取衰弱强度
	inst.Light:GetIntensity()  	--可以获取强度
	inst.Light:GetCalculatedRadius()	--获取实际照明范围
	inst.Light:GetColour()		--获取颜色 ]]	
Network：网络组件，添加与否决定了一个Entity在主机上生成时，是否会被客户端“看”到。
--[[ 
	参考代码：playerstatusscreen.lua    networkclientrpc.lua   netvars.lua
		inst.entity:AddNetwork()		--像大多数的客户端mod都不加网络组件的，这样别人就看不见了
	
	--自我检查的  components/skinner
	inst.Network:SetPlayerSkin( self.skin_name or "", self.clothing["body"] or "", self.clothing["hand"] or "", self.clothing["legs"] or "", self.clothing["feet"] or "" )

	使用TheNet
		TheNet:GetServerGameMode()  --游戏模式, "survival"/"quagmire"/"endless"
		TheNet:GetIsServer() -- 判断是否是主机（创建游戏者） <--> TheWorld.ismastersim
		TheNet:GetIsClient() -- 判断是否是客机（加入游戏者）
		TheNet:IsDedicated() -- 判断是否是服务器
		TheNet:Announce(message) -- 发送服务器公告，典型例子是XX死于XXX
		TheNet:Say(message, whisper) -- 在聊天框里显示信息，如果whisper的值为true，则这个消息只会被附近的人看到   实际上是玩家说
		TheNet:GetClientTableForUser(inst.userid)
		TheNet:AnnounceDeath(announcement_string, inst.entity)
		
	定义与使用网络变量
		ReferenceName = NetvarType(entity.GUID, "UniqueName", "DirtyEvent") 

		netvar:set(x)--只能在主机端调用这个函数，会自动同步客机的数据（在一个新的同步周期开始时）。如果这个函数确实改变了netvar的值，会在主机和客机上都触发相应的dirty事件。
		netvar:value()--可以在主机和客机上调用这个函数，读取当前网络变量的值。
		netvar:set_local(x)--可以在主机或客机上调用，改变相应的值但不触发数据同步或dirty事件。但当主机下一次调用set函数时，无论变量的值是否发生了改变，都会同步一次数据。

	注意:网络变量必须要在主机和客机中都有声明，也就是说，
	如果你想给人物添加一个网络变量，必须要写在common_init函数里。
	写在其它prefab里，则要在TheWorld.ismastersim的判断语句块之前写。
	如果要写在组件里，则必须要保证组件也在客机上存在（否则你应该写在replica里)]]
MiniMapEntity：地图实体组件，使用该组件可以为Entity在小地图上创建一个图标。	
--[[  
	参考代码：components/maprevealable.lub
	inst.MiniMapEntity:SetIcon("twiggy.png")
	inst.MiniMapEntity:SetPriority(-1) 		-1背景	0普通  1火堆	4冰箱	5科技	效果不是很明显 
	inst.MiniMapEntity:SetEnabled(true)  --是否在地图上显示,没SetIcon无法显示
	inst.MiniMapEntity:SetCanUseCache(false)  --能否运用缓存
	inst.MiniMapEntity:SetDrawOverFogOfWar(true)
	inst.MiniMapEntity:SetRenderOnTopOfMask(bool)  --顶级渲染
	inst.MiniMapEntity:SetRestriction(tag) --只有用于tag才能显示，自动切换]]
MiniMap：c side renderer，一般用在生成地图
--[[  
	--参考代码：prefabs/minimap.lua   
	--resolvefilepath(file) 强制搜索到文件
	inst.MiniMap:SetEffects( shader_filename, fs_shader )
	inst.MiniMap:AddAtlas( ".xml" )
	inst.MiniMap:AddRenderLayer(
            MapLayerManager:CreateRenderLayer(
                "map_edge",
                resolvefilepath("levels/tiles/" .. name .. ".xml"),
               	resolvefilepath("levels/tiles/" .. name .. ".tex"),
                resolvefilepath("levels/textures/ocean_noise.tex")
            )
        )]]
SoundEmitter：声音组件，控制Entity的声音集合和播放	
--[[ 
	RemapSoundEvent( "dontstarve/characters/sora/hurt", "sora/characters/hurt" )
	inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/attack_LP", "angry")	--播放声音
	inst.SoundEmitter:KillSound("angry")		--停止声音 ]]
Follower:  inst.Follower:FollowSymbol(parent.GUID, "fxname", x, y, z)

--[[ Others:
xxx.entity:SetParent(inst.entity)
--]]
添加方法： 	inst.entity:AddXXX()	--例如:inst.entity:AddTransform()
使用方法：	inst.XXX:YYY()			--例如： inst.Transform:SetPosition(0, 0, 0)

--------------------------------------- 描述函数 -----------------------------------
... 一些定义在外部的函数
local function fn() -- 描述函数
    local inst = CreateEntity() -- 创建实体
    -- 在网络代码往上的这部分代码，会在所有主机和客户端上都运行
    -- Entity组件（主客机都会运行），(Tag和网络变量  也可写在common_)
    -- 主客机通用Component（如用于处理说话的talker）	talker,transparentonsanity,playercontroller, 和playeractionpicker
    -- 主客机通用自定义处理，如某些组件的标签
    
    -------------- 网络代码 -----------------
    inst.entity:AddNetwork()
	inst:AddTag("_named")
    inst.entity:SetPristine()  --初始化，客户端根据_component，寻找并添加组件component_repica
    if not TheWorld.ismastersim then	--客机到这就没了，毕竟客机那没那么多组件，运行后面的会蹦
        return inst						--如果主机运行组件的函数时，客机的replica有同名的也会一起调用
    end									--客机调用组件等是replica  classified
										--客机通过发送RPC码向主机发出要求,主机则改变netvar(参考netvar.lua)的值来向客机传递数据（大多数被储存在了classified中）
	-------------- END 网络代码 -------------
	--Remove these tags so that they can be added properly when replicating components below
	inst:RemoveTag("_named")
	inst:AddComponent("named")	--自动寻找_replica，并添加对应标签_named
    -- 从这里往下的代码，只会在主机上运行。
    -- 大多数Component
    -- sg和brain
    -- 主机端自定义处理
    
    
    return inst
end
--------------------------------------- end 描述函数  -----------------------------------

------------------------------检查与介绍方面的

--NOHAT，对应我们的预设物 nohat， SOLLYZ对应我们人物的预设物名
STRINGS.NAMES.NOHAT = "猫妹子的发夹"
STRINGS.CHARACTERS.SOLLYZ.DESCRIBE.NOHAT = "那是来着姐姐的礼物"		--特定人物检查时说的话
STRINGS.CHARACTERS.GENERIC.DESCRIBE.NOHAT = "多么可爱，多么迷人"

STRINGS.RECIPE_DESC.NOHAT = "伴有淡淡花香的发夹" 	--物品栏上的介绍文字


--物品腐烂
参考代码：perishable.lua
	inst:AddTag("show_spoilage")	--加这个就有保鲜度动画
        inst:AddComponent("perishable")	--腐烂的
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
        inst.components.perishable:StartPerishing()
        --inst.components.perishable:SetOnPerishFn(inst.Remove)
		inst.components.perishable.onperishreplacement = "spoiled_food"

--可食用
参考代码：ebile.lua

	inst:AddComponent("edible")         
	inst.components.edible.healthvalue = 6 		--回复三围的数值
    inst.components.edible.hungervalue = 30
    inst.components.edible.sanityvalue = 5

--可叠加
参考代码： stackable.lua

	inst:AddComponent("stackable")          
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM		--最大叠加数目，直接写数字也可以
	
--物品判断主人/物品栏
参考代码：inventoryitem.lua

inst.components.inventoryitem.owner --不过owner里面没有inventory.euipslots，无法套娃了
owner.components.inventory.equipslots.hands (hands/body/head)

--机器

local function lightson(inst)		--light_debug
    inst.components.machine.ison = true
    inst.Light:Enable(true)
end
local function lightsoff(inst)
    inst.components.machine.ison = false
    inst.Light:Enable(false)
end

local fn(inst)
	inst:AddComponent("machine")
    inst.components.machine.turnonfn = lightson
    inst.components.machine.turnofffn = lightsoff
end	

--可烹饪食物
参考代码：cooking.lua、preparedfoods.lua、prefabs/preparedfoods.lua		_warly
组件：edible、perishable
--其他食物
参考代码：veggies.lua	meats.lua
组件：cookable、dryable、edible、perishable
	
--UI
--widgets/   screens/
--UI初始化时可能没加repica组件，所以用prefab判断最保险
RESOLUTION_X	RESOLUTION_Y
widget: scale默认是1,1,1. 即整个屏幕大小	
Anchor: 左上角在父窗口边界的位置
y
|->x	

SetHAnchor(ANCHOR_MIDDLE)
SetVAnchor(ANCHOR_MIDDLE)
SetScaleMode(SCALEMODE_RTIONAPROPOL)
SetScale(Vector3)	
GetScale()
SetPosition(Vector2)
GetPosition()

TheSim:GetScreenSize()	
widget默认是在屏幕中央的，而且轴心在中心

ImageButton:ScaleToSize(x,y)
Image:SetHRegPoint() ScaleToSize() --这个可以自定义轴心
Text:SetHAlign(0/1/2) SetRegionSize

Button: ForceImageSize
	
	
	