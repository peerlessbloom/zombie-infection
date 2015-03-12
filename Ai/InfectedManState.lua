require "Ai/State"

InfectedManAttackState = class("InfectedManAttackState", function() return State.new() end)

function InfectedManAttackState:create()
	local s = InfectedManAttackState.new()
	return s
end

function InfectedManAttackState:handle(man)
	--������ˣ�������
	if man:isDied() then return end

	local dist, dir, enemy = man:checkAround()
	if enemy == nil or enemy:isInfected() then		--���������ʧ�ˣ�Ѳ�ߣ����˻���ʬ���ˣ�
		man:changeAIState(InfectedManPatrollState:create())
		man:randomPatroll()
	elseif dist <= 1 then
		man:attack()
	else 											--����׷��
		man:follow(dir)
	end	
end

InfectedManPatrollState = class("InfectedManPatrollState", function() return State.new() end)

function InfectedManPatrollState:create()
	local s = InfectedManPatrollState.new()
	return s
end

function InfectedManPatrollState:handle(man)
	--������ˣ�������
	if man:isDied() then return end

	local dist, dir, enemy = man:checkAround()
	if enemy == nil or enemy:isInfected() then		--���������ʧ�ˣ�Ѳ�ߣ����˻���ʬ���ˣ�
		--���Һ����ǵľ���
		local zombiedir = man:lookingForZombie()
		if zombiedir ~= nil then man:follow(zombiedir)
		else	man:randomPatroll() end
	elseif dist <= 1 then
		man:changeAIState(InfectedManAttackState:create())
		man:attack()
	else 											--����׷��
		man:changeAIState(InfectedManAttackState:create())
		man:follow(dir)
	end	
end