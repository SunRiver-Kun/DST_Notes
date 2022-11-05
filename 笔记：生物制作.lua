BrainManager -manger> brain -> behaviourtree -> nodes -> components -event> stategraph
brain.lua、behaviourtree.lua、stategraph.lua
--节点nodes  behaviourtree.lua
function BT:Update()
    self.root:Visit()
    self.root:SaveStatus()
    self.root:Step()
    self.forceupdate = false
end

SUCCESS = "SUCCESS"
FAILED = "FAILED"
READY = "READY"
RUNNING = "RUNNING"
BehaviourNode(self, name, children)		--基类
--修饰节点
DecoratorNode(self, name, child)	--BehaviourNode(self, name or "Decorator", {child})
NotDecorator(self, child)	--当child.status是SUCCESS或FAILED时翻转，其他一样
FailIfRunningDecorator(self, child)	--child:Visit(), status= child.status == RUNNING and FAILED or child.status
FailIfSuccessDecorator(self, child)	--child:Visit(), status= child.status == SUCCESS and FAILED or child.status

--叶子节点
ConditionNode(self, fn, name)	--status = fn() and SUCCESS or FAILED
MultiConditionNode(self, start, continue, name)	--false时start()，success时continue()
ConditionWaitNode(self, fn, name)  --status = fn() and SUCCESS or RUNNING
WaitNode(self, time)	--RUNNING -time> SUCCESS
ActionNode(self, action, name)	--action()  status = SUCCESS

--控制节点
SequenceNode(self, children)	--子节点RUNNING or FAILED时卡住，否则++index，访问完最后节点时SUCCESS，否则Ru or Fa
SelectorNode(self, children)	--子节点RUNNING or SUCCESS时卡住，否则++index，访问完最后节点时FAILED，否则Ru or Su
LoopNode(self, children, maxreps=nil)	--循环到maxreps时，SUCCESS
RandomNode(self, children)	--随机访问子节点，直到有不是FAILED的节点或遍历全部，下次直接遍历那个节点

--只运行分支period秒，之后尝试去切换到SUCCESS or RUNNING的分支
PriorityNode(self, children, period=1, noscatter=false) 
EventNode(self, inst, event, child, priority=0)


--ParallelNode和ParallelNodeAny不卡住，不修改SUCCESS的子节点
--Step()只重置SUCCESS的ConditionNode
--Visit()强制访问Reset后的ConditionNode，不访问SUCCESS的节点，RUNNING时继续跑下一个(SequenceNode直接停了)
--FAILED：任意子节点FAILED时
--RUNNING：有子节点RUNNING时，且没有FAILED的节点 
--SUCCESS：全部子节点READY或SUCCESS时
ParallelNode(self, children, name)	

--FAILED：任意子节点FAILED时
--RUNNING：全部子节点RUNNING时
--SUCCESS：任意子节点READY或SUCCESS时
ParallelNodeAny(self, children)

LatchNode(self, inst, latchduration, child)	--超过duration时才访问child

--function
--从头遍历，cond返false时结束，否则继续运行
WhileNode(cond, name, node)	--ParallelNode({ConditionNode(cond, name), node})
--cond返回false时卡住，否则继续运行
IfNode(cond, name, node)	--SequenceNode({ConditionNode(cond, name), node})
IfThenDoWhileNode(ifcond, whilecond, name, node)	--ParallelNode({MultiConditionNode(ifcond, whilecond, name), node})

--behaviours    继承自BehaviourNode     brain.inst
DoAction(inst, getactionfn, name, run, timeout)



--设置大脑
local brain = require "brains/koalefantbrain"
inst:SetBrain(brain)	--设置大脑，替换新大脑时需要手动ReStartBrain

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

























