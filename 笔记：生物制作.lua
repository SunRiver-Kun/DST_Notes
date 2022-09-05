BrainManager -manger> brain -> behaviourtree -> nodes -> components -event> stategraph
brain.lua、behaviourtree.lua、stategraph.lua

--设置大脑
local brain = GLOBAL.require "brains/koalefantbrain"
inst:SetBrain(brain)	--设置大脑

--注册一个预设物,第一个参数是prefab名,只会识别到最后一个/后的nohat而已,第二个是描述函数,第三个是加载资源表
Prefab("common/inventory/nohat", fn, assets)

--加入世界初始化
function SpawnCreature(player)
	local x, y, z = player.Transform:GetWorldPosition()	--得到玩家的位置, y轴是高！！！！！
	local creature = GLOBAL.SpawnPrefab("forest/animals/beefalo")
	creature.Transform:SetPosition( x, y, z )	--给此生物设置位置
end
AddSimPostInit(SpawnCreature)	--理论上不用玩家位置就可以在玩家进来前诞生完成


--Brain
判断：
TheWorld.Map:IsVisualGroundAtPoint(x, 0, z)		--水中可，路上加not 表示可用
TheWorld.Map:IsPassableAtPoint(x, y, z)		--是否可通过
TheWorld.GroundCreep:OnCreep(pt)  --地上有无鸟  pt: pos table

寻位：
local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)		--12是attampts，尝试次数吧
        local spawn_point = pt + offset
        return ground.Map:IsPassableAtPoint(spawn_point:Get()) and not ground.GroundCreep:OnCreep(spawn_point:Get())
    end)

if result_offset then
	return pt+result_offset
end

























