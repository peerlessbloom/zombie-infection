---------------------------------------------
--                 ����sprite����
--                 ��������Դ����Դ����Res��
--					������Դ��ִ����
---------------------------------------------
require "Res/GameRes"

CharacterSprite = class("CharacterSprite")

function CharacterSprite:init(characterRes)
	self.sprite = nil
end

-------------------��sprite�ķ�װ--------------
function CharacterSprite:setPosition(x, y)
	self.sprite:setPosition(x, y)
end

function CharacterSprite:getPosition()
	return self.sprite:getPosition()
end

function CharacterSprite:stopAllActions()
	self.sprite:stopAllActions()
	self.sprite:runAction(cc.FadeIn:create(0))
end

function CharacterSprite:reorder(other)
	local mapOrder = GameRes:getInstance().mapOrder
	
	if mapOrder[self.sprite] > mapOrder[other.sprite] then return end
	
	--��upperSprite.sprite�ȼ�����Ⱦ����self.sprite�������Ⱦ��
	cclog("reorder")
	local parent = self.sprite:getParent()
	parent:removeChild(self.sprite, false)
	parent:addChild(self.sprite, 1)
	
	mapOrder[self.sprite] = mapOrder["pos"]
	mapOrder["pos"] = mapOrder["pos"] + 1
end
------------------����һ������---------------

------------------���ж���--------------------