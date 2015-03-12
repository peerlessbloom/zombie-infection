require "Ai/State"
require "Ai/InfectedManState"

ManPatrollState = class("ManPatrollState", function() return State.new() end)

function ManPatrollState:create()
	local s = ManPatrollState.new()
	return s
end

function ManPatrollState:handle(man)
	--cclog("[man patroll state]")
	--如果死了，就死了
	if man:isDied() then return end
	--如果尸化了，就尸化巡逻
	if man:isInfected() then
		man:changeAIState(InfectedManPatrollState:create())
		man:infect()
		man:randomPatroll()
		return 
	end
	--如果遇到敌人了
	--检查四周，最近的位置
	local dist, dir, enemy = man:checkView()
	if dist == nil then	--安全
		man:patroll()
	elseif dist <= 1 then 	--如果可以攻击，就攻击
		man:changeAIState(ManAttackState:create())
		man:attack()
	else --否则逃跑
		man:changeAIState(ManEscapeState:create())
		man:escape(dir)
	end
end

ManEscapeState = class("ManEscapeState", function() return State.new() end)

function ManEscapeState:create()
	local s = ManEscapeState.new()
	return s
end

function ManEscapeState:handle(man)
	--cclog("[man escape state]")
	--如果死了，就死了
	if man:isDied() then return end
	--如果尸化了，就尸化巡逻
	if man:isInfected() then
		man:changeAIState(InfectedManPatrollState:create())
		man:infect()
		man:randomPatroll()
		return 
	end
	
	local dist, dir, enemy = man:checkAround()
	if dist == nil or enemy:isDied() then		--如果安全了，就返回巡逻点
		man:changeAIState(ManPatrollState:create())
		man:patroll()
	elseif dist <= 1 then 	--如果怪物太近，就近程攻击
		man:changeAIState(ManAttackState:create())
		man:attack()
	else --否则逃跑
		man:escape(dir)
	end	
end

ManAttackState = class("ManAttackState", function() return State.new() end)

function ManAttackState:create()
	local s = ManAttackState.new()
	return s
end

function ManAttackState:handle(man)
	--cclog("[man attack state]")
	--如果死了，就死了
	if man:isDied() then return end
	--如果尸化了，就尸化巡逻
	if man:isInfected() then
		man:changeAIState(InfectedManPatrollState:create())
		man:infect()
		man:randomPatroll()
		return 
	end
	
	local dist, dir, enemy = man:checkView()
	if enemy == nil then		--如果敌人消失了，巡逻（死了）
		--cclog("no enemy")
		man:changeAIState(ManPatrollState:create())
		man:patroll()
	elseif dist <= 1 then		--否则继续攻击
		--cclog("has enemy")
		man:attack()
	else
		man:changeAIState(ManEscapeState:create())
		man:escape(dir)
	end	
end