require "Ai/State"
require "Ai/InfectedManState"

ManPatrollState = class("ManPatrollState", function() return State.new() end)

function ManPatrollState:create()
	local s = ManPatrollState.new()
	return s
end

function ManPatrollState:handle(man)
	--cclog("[man patroll state]")
	--������ˣ�������
	if man:isDied() then return end
	--���ʬ���ˣ���ʬ��Ѳ��
	if man:isInfected() then
		man:changeAIState(InfectedManPatrollState:create())
		man:infect()
		man:randomPatroll()
		return 
	end
	--�������������
	--������ܣ������λ��
	local dist, dir, enemy = man:checkView()
	if dist == nil then	--��ȫ
		man:patroll()
	elseif dist <= 1 then 	--������Թ������͹���
		man:changeAIState(ManAttackState:create())
		man:attack()
	else --��������
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
	--������ˣ�������
	if man:isDied() then return end
	--���ʬ���ˣ���ʬ��Ѳ��
	if man:isInfected() then
		man:changeAIState(InfectedManPatrollState:create())
		man:infect()
		man:randomPatroll()
		return 
	end
	
	local dist, dir, enemy = man:checkAround()
	if dist == nil or enemy:isDied() then		--�����ȫ�ˣ��ͷ���Ѳ�ߵ�
		man:changeAIState(ManPatrollState:create())
		man:patroll()
	elseif dist <= 1 then 	--�������̫�����ͽ��̹���
		man:changeAIState(ManAttackState:create())
		man:attack()
	else --��������
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
	--������ˣ�������
	if man:isDied() then return end
	--���ʬ���ˣ���ʬ��Ѳ��
	if man:isInfected() then
		man:changeAIState(InfectedManPatrollState:create())
		man:infect()
		man:randomPatroll()
		return 
	end
	
	local dist, dir, enemy = man:checkView()
	if enemy == nil then		--���������ʧ�ˣ�Ѳ�ߣ����ˣ�
		--cclog("no enemy")
		man:changeAIState(ManPatrollState:create())
		man:patroll()
	elseif dist <= 1 then		--�����������
		--cclog("has enemy")
		man:attack()
	else
		man:changeAIState(ManEscapeState:create())
		man:escape(dir)
	end	
end