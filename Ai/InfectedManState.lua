require "Ai/State"

InfectedManAttackState = class("InfectedManAttackState", function() return State.new() end)

function InfectedManAttackState:create()
	local s = InfectedManAttackState.new()
	return s
end

function InfectedManAttackState:handle(man)
	--如果死了，就死了
	if man:isDied() then return end

	local dist, dir, enemy = man:checkAround()
	if enemy == nil or enemy:isInfected() then		--如果敌人消失了，巡逻（死了或者尸化了）
		man:changeAIState(InfectedManPatrollState:create())
		man:randomPatroll()
	elseif dist <= 1 then
		man:attack()
	else 											--否则追踪
		man:follow(dir)
	end	
end

InfectedManPatrollState = class("InfectedManPatrollState", function() return State.new() end)

function InfectedManPatrollState:create()
	local s = InfectedManPatrollState.new()
	return s
end

function InfectedManPatrollState:handle(man)
	--如果死了，就死了
	if man:isDied() then return end

	local dist, dir, enemy = man:checkAround()
	if enemy == nil or enemy:isInfected() then		--如果敌人消失了，巡逻（死了或者尸化了）
		--查找和主角的距离
		local zombiedir = man:lookingForZombie()
		if zombiedir ~= nil then man:follow(zombiedir)
		else	man:randomPatroll() end
	elseif dist <= 1 then
		man:changeAIState(InfectedManAttackState:create())
		man:attack()
	else 											--否则追踪
		man:changeAIState(InfectedManAttackState:create())
		man:follow(dir)
	end	
end