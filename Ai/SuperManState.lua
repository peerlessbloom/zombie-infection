require "Ai/State"
require "Ai/InfectedManState"

SuperManAttackState = class("SuperManAttackState", function() return State.new() end)

function SuperManAttackState:create()
	local s = SuperManAttackState.new()
	return s
end

function SuperManAttackState:handle(man)
	--cclog("[super man attack state]")
	--������ˣ�������
	if man:isDied() then return end
	--���ʬ���ˣ���ʬ��Ѳ��
	if man:isInfected() then
		man:changeAIState(InfectedManPatrollState:create())
		man:infect()
		man:randomPatroll()
		return 
	end
	
	
	local dist, dir, enemy = man:checkView(4)
	if enemy == nil or enemy:isDied() then		--���������ʧ�ˣ�Ѳ�ߣ����ˣ�
		--cclog("call patroll")
		man:changeAIState(SuperManPatrollState:create())
		man:patroll()
	elseif dist <= 1 then 		--�������̫�����ͽ��̹���
		--cclog("call attack")
		man:attack()
	elseif dist <= 3 then						--����Զ�̹���
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
	--������ˣ�������
	if man:isDied() then return end
	--���ʬ���ˣ���ʬ��Ѳ��
	if man:isInfected() then
		man:changeAIState(InfectedManPatrollState:create())
		man:infect()
		man:randomPatroll()
		return 
	end
	
	
	local dist, dir, enemy = man:checkView(4)
	if enemy == nil then		--���������ʧ�ˣ�Ѳ�ߣ����ˣ�
		--cclog("call patroll")
		man:patroll()
	elseif dist <= 1 then 		--�������̫�����ͽ��̹���
		--cclog("call attack")
		man:changeAIState(SuperManAttackState:create())
		man:attack()
	elseif dist <= 3 then 						--����Զ�̹���
		--cclog("call attackFar")
		man:changeAIState(SuperManAttackState:create())
		man:attackFar()
	else
		man:follow(dir)
	end
end