require "Ai/State"
require "Ai/InfectedManState"

SuperManAttackState = class("SuperManAttackState", function() return State.new() end)

function SuperManAttackState:create()
	local s = SuperManAttackState.new()
	return s
end

function SuperManAttackState:handle(man)
	--cclog("[super man attack state]")
	--如果死了，就死了
	if man:isDied() then return end
	--如果尸化了，就尸化巡逻
	if man:isInfected() then
		man:changeAIState(InfectedManPatrollState:create())
		man:infect()
		man:randomPatroll()
		return 
	end
	
	
	local dist, dir, enemy = man:checkView(4)
	if enemy == nil or enemy:isDied() then		--如果敌人消失了，巡逻（死了）
		--cclog("call patroll")
		man:changeAIState(SuperManPatrollState:create())
		man:patroll()
	elseif dist <= 1 then 		--如果怪物太近，就近程攻击
		--cclog("call attack")
		man:attack()
	elseif dist <= 3 then						--否则远程攻击
		--cclog("call attackFar")
		man:attackFar()
	else
		man:follow(dir)
	end
end

SuperManPatrollState = class("SuperManPatrollState", function() return State.new() end)

function SuperManPatrollState:create()
	local s = SuperManPatrollState.new()
	return s
end

function SuperManPatrollState:handle(man)
	--cclog("[super man patroll state]")
	--如果死了，就死了
	if man:isDied() then return end
	--如果尸化了，就尸化巡逻
	if man:isInfected() then
		man:changeAIState(InfectedManPatrollState:create())
		man:infect()
		man:randomPatroll()
		return 
	end
	
	
	local dist, dir, enemy = man:checkView(4)
	if enemy == nil then		--如果敌人消失了，巡逻（死了）
		--cclog("call patroll")
		man:patroll()
	elseif dist <= 1 then 		--如果怪物太近，就近程攻击
		--cclog("call attack")
		man:changeAIState(SuperManAttackState:create())
		man:attack()
	elseif dist <= 3 then 						--否则远程攻击
		--cclog("call attackFar")
		man:changeAIState(SuperManAttackState:create())
		man:attackFar()
	else
		man:follow(dir)
	end
end