-1.动画部分

A:建个prefab
local assets =
{	Asset("ANIM", "anim/xxx.zip"), }


local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()		--返回值等于inst.AnimState
 
	inst.AnimState:SetBank("inscml")	--里面
    inst.AnimState:SetBuild("scmlname")
    inst.AnimState:PlayAnimation("animname")


	inst.Transform:SetScale(1, 1, 1)  --这里可以改变预设物大小,x,y,z ; y为高
	inst:DoTaskInTime(2.595, inst.Remove) --这里是播放多长时间后，移除它
	return inst
end

return Prefab("xxx", fn, assets)
B:生成特效
	local xxx = SpawnPrefab("xxx")	xxx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	
参考代码：特效(全)fx.lua    scml中是毫秒，inst:DoXXXTime是秒
cane_ancient_fx  cane_victorian_fx  cane_candy_fx  cane_sharp_fx  --手杖特效
lighterfire  lighterfire_haunteddoll		--鬼火特效
lightning		--闪电
lavaarena_portal_player_fx、spawn_fx_medium  --换皮肤
ice_projectile(螺旋丸)  ice_puddle(融合后的水)	ice_splash(水泡)   
deer_ice_burst  deer_ice_charge   deer_ice_circle	 deer_ice_flakes    deer_ice_fx		--冰鹿特效
deer_fire_burst  deer_fire_charge   deer_fire_circle	 deer_fire_flakes    	--火鹿特效
tree_petal_fx_chop   
green_leaves green_leaves_chop  red_leaves  red_leaves_chop   orange_leaves   orange_leaves_chop   purple_leaves  purple_leaves_chop

人物动画
1. 画图
2. 在人物的scml中，设置锚点；
3. 复制粘贴人物的scml，删除多余的图，选择参考图，框选图，调节x，y	  方二：把人物scml的entityname改为wilson，新建个动画也行！
4. 在第一帧删除不需要的图片，之后无法再删除
5. 若需删除，找张透明贴图，长按图片切换到透明贴图
5. _down, _side, _up，也可以不要后缀
6. 动画打包后，只需要里面的anim，其他的文件会影响换皮肤		方二的不用删
7. 更改动画之后，要重启游戏，不能用c_reset()
8. 非png文件会影响打包，导致缺失某些图片，需删除anim中的zip重新生成

循环模式，是否最后一帧逐渐转为第一帧
新的图，命名要和官方的统一，不能太大！
timeline id不能少，不能空！

下面是饥荒！！不支持！！的Sprite功能
帧设置（不支持！！）(instant ，只能是linear)
骨动画（不支持！！）

	
2.自定义动作
参考代码：playercontroller.lua（输入）（input.lua） playeractionpicker（处理） actionhandler（实现） bufferedaction.lua（继承此类）  actions.lua（参考动作写法）   componentactions.lua（动作收集器）
【1】用到的MOD API（modutil）：	--动作在GLOBAL.ACTION全局表里，参见actions.lua
AddAction = function( id, str, fn ) 		--向游戏注册一个动作，定义ACTION的具体函数
AddStategraphActionHandler = function(stategraph, handler) --将一个动作与state绑定,即用来播放动画，根据ACTIONS.XXX播放动画，并在合适时间调用ACTION的具体函数
AddComponentAction = function(actiontype, component, fn) --将一个动作与component绑定，判断并插入ACTIONS.XXX

AddStategraphState = function(stategraph, state)
AddStategraphEvent = function(stategraph, event)
AddStategraphPostInit = function(stategraph, fn)

actions：具体效果，server   AddAction
componentactions：判断和插入ACTION，client  AddComponentAction
stategraph：动画，回应componentactions，并调用actions的具体效果     AddStategraphActionHandler

【2】动作类型：
"SCENE"(自可点,拖动,物品栏)，"POINT"(多:唯一地面,手持,拖动)，"USEITEM"(鼠标拖动)，"EQUIPPED"(装备特殊物品)，"INVENTORY"(物品栏)		
【3】动作state：官方自带的，还有很多，看SGwilson
"dostandingaction"(给予)="give"(给予),"doshortaction"(捡东西),"dolongaction"(采集),"book"(阅读),"dojostleaction"(攻击(变))
【4】写法：见于actions.lua
一：只是定义时候的写法
local XXX = Action()		--继承类
XXX.id="ID"			--唯一大写，ACTIONS表中对应的KEY值
XXX.str="name"			--在可以实施这个动作时显示
XXX.fn = function (act)	---- act相对于bufferedaction.lua里的self	
		act.doer ... 
	end
AddAction(XXX)

二：
---------------------------文件SGXXX.lua，但注册的时候都不带SG
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(ACTIONS.ID, "动作state"))	--sg设置，联机版要两个都加 wilson，wilson_client
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(XXX, "动作state"))--这个函数是用来给指定的SG添加ActionHandler的。

AddComponentAction("动作类型", "挂名组件名", function(inst, doer, actions, right)	--动作类型，挂名组件，在playeractionpicker中执行的判断函数
    if right then	--right表示的是右键
        if not inst:HasTag("...") then  --doer.replica.health
            table.insert(actions, GLOBAL.ACTIONS.id)
            ----满足判定条件后，就用table.insert函数将你想要添加的动作插入到actions表中。
        end
    end
end)
3.StateGraph(sg)介绍：
参考代码：stategraphs
--EventHandler("equip"  SG_wilson.lua
      SG_wilson  player_actions_item
类型    State    Anim 
带帽子：
item_hat    
item_in
item_out

--需要用到AnimState,有时还用到Physics等
--[[ AnimState：动画组件，控制Prefab的材质（scmlname）(Build)，动画集合(Bank)和动画播放(Animation)，Symbol表示某实物可以被替换的部分,动画播完了不会自己移除的
inst.AnimState:SetBuild("scmlname")		--转入官方代码的这两个省略，直接inst.AnimState:PlayAnimation("xxx")
inst.AnimState:SetBank("anim")

inst.AnimState:SetLayer(LAYER_WORLD)	--LAYER_BACKGROUND(人物后面),设置层级，会影响到多个物体重叠时的动画呈现（谁在最前面）
inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)	--设置朝向，在设置Prefab紧贴地面时会很有用，比如农场，池塘都是紧贴地面
inst.AnimState:SetSortOrder(3)	--设置排序顺序，在层级相同时有影响
inst.AnimState:SetFinalOffset(偏移值)	--一般是做特效时用

inst.AnimState:PlayAnimation("idle")	--第一个参数是动画名，第二个是否重复播放(默认为false)
inst.AnimState:PushAnimation("idle")	--play是直接打断来播放，push是等上一个放完了再放，参数同上play，一般是第一个是play后面都是push

inst.AnimState:SetMultColour(r/255, g/255, b/255, 1)	--设置颜色和透明度

inst.AnimState:OverrideSymbol("swap_object", "scmlname", "foldername")	--用其它动画的某个Symbol来覆盖当前Prefab的Symbol，要覆盖的Symbol名，覆盖用的Build名，覆盖用的Symbol名
inst.AnimState:ClearOverrideSymbol("swap_object")	--因为常替换的是人物的，所以写在物品的unequip时用owner代替inst，只有body需要这个

inst.AnimState:Show("ARM_carry")
inst.AnimState:Hide("ARM_normal")

inst.AnimState:AnimDone()
inst.AnimState:SetTime(94 * FRAMES)


inst:ListenForEvent("animover", function() inst:Remove() end)	--动画放完会有个animover事件，当前动画播放完就移除它
inst:ListenForEvent("animqueueover", function() inst:Remove() end)		--一个列表的动画播放完就移除它
--AnimState]]
--[[ Phiysics：物理组件，控制Prefab的物理行为，比如速度，碰撞类型等等。下面这些不能同时对一个prefab里使用
参考代码：standardcomponents.lua  
1.物品栏物品（各种可以放进物品栏的小物品）
MakeInventoryPhysics(inst)
特点：可以通过inst.Physics:SetVel(x,y,z)来提供初速度，并且遵循重力、摩擦、碰撞等物理规律。
通用的：
	inst.entity:SetPristine()	--比较特殊的引用方法

RemovePhysicsColliders(inst)	--无视碰撞,移除所有碰撞效果，自由穿梭
inst.Physics:Stop()	--停止运动,会将实体的速度设为0
inst.Physics:SetMotorVel(x,y,z)		--设置各方向的初速度,该方法只对人物、生物类型有效。如果是延当前发现的话，y,z设置为0
inst.Physics:GetMotorVel()	--获取实体的当前速度

inst.Physics:SetVel(x,y,z)	--设置初速度，针对物品栏的物品，坐标系和世界坐标系对应,物品栏物品的运动会受到重力、摩擦力、弹力等影响

--Phiysics]]
--[[ SoundEmitter：声音组件，控制Prefab的声音集合和播放
	inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/attack_LP", "angry")	--播放声音
	inst.SoundEmitter:KillSound("angry")		--停止声音
--SoundEmitter]]
--[[ Others，除特殊注释外，一般写在states里的onenter
inst.components.health:IsDead()		
inst.components.health:SetInvincible(true)		--无敌
inst.components.locomotor:Stop()
inst.Physics:Stop()

inst.components.playercontroller:EnableMapControls(false)	--能否打开地图
inst.components.playercontroller:Enable(false)		--能否控制
inst:ShowActions(false)		--隐藏动作名
inst.components.inventory:Close()	--关闭物品栏
inst.components.inventory:Hide()	--效果应该和上面那个一样
              
inst.sg.statemem.action = inst:GetBufferedAction()	--得到缓存动作
inst:PerformBufferedAction()		--播放缓存动作		  
inst:ClearBufferedAction()		--清理缓存动作

inst.sg.statemem ={...}		--有时用来判断，不过我打印出来就只有个ignoresandstorm,应该可以自己加进去
	if inst.sg.statemem.actionmeter then
                StopActionMeter(inst, false)
    end
    if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
    end

inst:PushEvent("ms_closepopups")	--关闭弹出窗口
inst:PushEvent("ms_closewardrobe")	--关闭衣柜
--]]
require("stategraphs/commonstates")	--定位到官方代码
EventHandler("事件名", function(inst) PlayAnimation ... inst.sg:GoToState("hit") end)	--通过事件来连接到其他state,返回{...}
ActionHandler(ACTIONS.UNWRAP,function(inst, action)	--通过动作来连接state,返回的字符串对应states里的name,可以直接写字符串来代替fn，写在actionhandlers
    return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
end)		
inst.sg:HasStateTag("dancing")	--sg标签
inst.sg:GoToState("hit",其他参数)	--跳转动画，可以加入其他参数（方便转入state的onenter调用）,常见参数: pushanim(""),data({...})
inst.sg:SetTimeout(23 * FRAMES)
--FRAMES(帧) = 1/30 定义在constants里，用于动画时间轴定位, FPS(Frames Pre Second,一秒刷新图片的张数,例如:FPS = 30帧就是1秒刷30张图)
--scml里的TimeLine里时间单位是毫秒, /1000就变成秒,例如:1200表示1.2秒


--[[4.界面类
参考代码：sollyzwheel.lua

widget（单位）\screen（整体）			--自己写的widget附在controls上就可以了（玩家操作界面的物品栏，制作栏，状态栏等等）
local Widget = require "widgets/widget"
local XXX = require "widets/xxx"
local Hello = Class(Widget, function(self)
	Widget._ctor(self, "Hello")
	self.hello = AddChild(Widget("hello"))
	self.hello.xxx = self:AddChild(XXX(...))	--self.xxx就相当于return那玩意了,同组件一样用法
	...
end)
return Hello

到modmain里面
local Hello = GLOBAL.require("scripts/widgets/Hello.lua")
local function hello(self)
	self.hello = AddChild(Hello(...))
	self.hello:SetHAnchor(0) -- 设置原点x坐标位置，0、1、2分别对应屏幕中、左、右
    self.hello:SetVAnchor(1) -- 设置原点y坐标位置，0、1、2分别对应屏幕中、上、下
    self.hello:SetPosition(70,-50,0) -- 设置hello widget相对原点的偏移量，70，-50表明向右70，向下50，第三个参数无意义。
end
AddClassPostConstruct("widgets/controls", addHelloWidget) -- 这个函数是官方的MOD API，用于修改游戏中的类的构造函数。第一个参数是类的文件路径，根目录为scripts。第二个自定义的修改函数，第一个参数固定为self，指代要修改的类。
--]]


--材质
fx:SetMaterial("wood")






















